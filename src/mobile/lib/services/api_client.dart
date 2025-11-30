import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API client with token management and error handling
class ApiClient {
  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _cachedToken;

  /// Get base URL from environment
  String get baseUrl {
    String effectiveBase;
    try {
      final base = (dotenv.isInitialized ? dotenv.env['API_URL'] : null)
          ?.trim();
      effectiveBase = (base != null && base.isNotEmpty)
          ? base
          : 'http://localhost:5128';
    } catch (_) {
      effectiveBase = 'http://localhost:5128';
    }

    // Android emulator localhost remap
    if (Platform.isAndroid) {
      try {
        final parsed = Uri.parse(effectiveBase);
        if (parsed.host == 'localhost' || parsed.host == '127.0.0.1') {
          effectiveBase = parsed.replace(host: '10.0.2.2').toString();
        }
      } catch (_) {
        // keep as-is
      }
    }

    return effectiveBase;
  }

  /// Build URI from path
  Uri buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final effectiveBase = baseUrl;

    // Ensure single slash between base and path
    String fullPath = path;
    if (effectiveBase.endsWith('/') && path.startsWith('/')) {
      fullPath = effectiveBase.substring(0, effectiveBase.length - 1) + path;
    } else {
      fullPath = effectiveBase + path;
    }

    final uri = Uri.parse(fullPath);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }

    return uri;
  }

  /// Get cached token or read from storage
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  /// Save token to storage and cache
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Delete token from storage and cache
  Future<void> deleteToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  /// Get headers with authorization if token exists
  Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
    bool isMultipart = false,
  }) async {
    final headers = <String, String>{};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (includeAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response and parse JSON
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Invalid JSON response', response.statusCode);
      }
    }

    // Handle error responses
    String message = 'Request failed';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        message = (decoded['error'] ?? decoded['message'] ?? message)
            .toString();
      }
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : message;
    }

    throw ApiException(message, response.statusCode);
  }

  /// GET request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    try {
      final uri = buildUri(path, queryParameters: queryParameters);
      final headers = await _getHeaders(includeAuth: requireAuth);

      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e', 0);
    }
  }

  /// POST request
  Future<dynamic> post(
    String path, {
    dynamic body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = buildUri(path);
      final headers = await _getHeaders(includeAuth: requireAuth);

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e', 0);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String path, {
    dynamic body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = buildUri(path);
      final headers = await _getHeaders(includeAuth: requireAuth);

      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e', 0);
    }
  }

  /// DELETE request
  Future<dynamic> delete(String path, {bool requireAuth = true}) async {
    try {
      final uri = buildUri(path);
      final headers = await _getHeaders(includeAuth: requireAuth);

      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e', 0);
    }
  }

  /// POST multipart request (for file uploads)
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, String>? files,
    bool requireAuth = true,
  }) async {
    try {
      final uri = buildUri(path);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = await _getHeaders(
        includeAuth: requireAuth,
        isMultipart: true,
      );
      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = await http.MultipartFile.fromPath(
            entry.key,
            entry.value,
          );
          request.files.add(file);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e', 0);
    }
  }

  /// PUT multipart request (for file uploads)
  Future<dynamic> putMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, String>? files,
    bool requireAuth = true,
  }) async {
    try {
      final uri = buildUri(path);
      final request = http.MultipartRequest('PUT', uri);

      // Add headers
      final headers = await _getHeaders(
        includeAuth: requireAuth,
        isMultipart: true,
      );
      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = await http.MultipartFile.fromPath(
            entry.key,
            entry.value,
          );
          request.files.add(file);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e', 0);
    }
  }

  /// Download file
  Future<List<int>> downloadFile(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = buildUri(path, queryParameters: queryParameters);
      final headers = await _getHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }

      throw ApiException('Failed to download file', response.statusCode);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Download failed: $e', 0);
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isBadRequest => statusCode == 400;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => message;
}
