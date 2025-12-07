import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// API client with token management and error handling
/// Delegates auth logic to the injected [AuthService].
class ApiClient {
  final AuthService _authService;

  ApiClient(this._authService);

  /// Get base URL from AuthService
  Uri buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    // We delegate the URI building to AuthService to share logic (env, emulator remapping)
    // Note: AuthService.buildUri only takes path, so we handle params here.
    final uri = _authService.buildUri(path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri;
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
      final token = await _authService.getValidToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Helper to retry request on 401 (token expired)
  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function(Map<String, String> headers) requestFn, {
    bool requireAuth = true,
  }) async {
    // 1. First attempt
    final headers = await _getHeaders(includeAuth: requireAuth);
    final response = await requestFn(headers);

    // 2. If 401 and we used auth, try to refresh
    if (response.statusCode == 401 && requireAuth) {
      final newToken = await _authService.refreshAccessToken();
      if (newToken != null) {
        // Retry with new token
        final newHeaders = await _getHeaders(includeAuth: true);
        return await requestFn(newHeaders);
      } else {
        // Refresh failed (or no refresh token) -> Logout or just return error
        // Current behavior: if refresh fails (returns null), proper action is usually logout.
        // We will let the caller handle the 401, but the refresh attempt ensures we tried our best.
        // Option: we could force logout here via _authService.logout() but that might be side-effect heavy for a client.
      }
    }

    return response;
  }

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
        message = (decoded['error'] ?? decoded['message'] ?? message).toString();
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

      final response = await _sendWithRetry((headers) {
        return http.get(uri, headers: headers);
      }, requireAuth: requireAuth);

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

      final response = await _sendWithRetry((headers) {
        return http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }, requireAuth: requireAuth);

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

      final response = await _sendWithRetry((headers) {
        return http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }, requireAuth: requireAuth);

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

      final response = await _sendWithRetry((headers) {
        return http.delete(uri, headers: headers);
      }, requireAuth: requireAuth);

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

      // We cannot easily retry multipart requests because stream is consumed.
      // So we generally don't retry locally for multipart unless we rebuild the request.
      // For now, simple implementation without auto-refresh retry for multipart.
      // Or we can check token validity *before* sending.
      
      // Attempt refresh if token looks expired? No, just run it.
      
      final request = http.MultipartRequest('POST', uri);
      final headers = await _getHeaders(includeAuth: requireAuth, isMultipart: true);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (files != null) {
        for (final entry in files.entries) {
          final file = await http.MultipartFile.fromPath(entry.key, entry.value);
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

  /// PUT multipart request (for updating resources with files)
  Future<dynamic> putMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, String>? files,
    bool requireAuth = true,
  }) async {
    try {
      final uri = buildUri(path);

      final request = http.MultipartRequest('PUT', uri);
      final headers = await _getHeaders(includeAuth: requireAuth, isMultipart: true);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (files != null) {
        for (final entry in files.entries) {
          final file = await http.MultipartFile.fromPath(entry.key, entry.value);
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

  /// Download a file as bytes. Returns raw bytes for consumers to save to disk.
  Future<List<int>> downloadFile(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    try {
      final uri = buildUri(path, queryParameters: queryParameters);

      final response = await _sendWithRetry((headers) {
        return http.get(uri, headers: headers);
      }, requireAuth: requireAuth);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }

      // Non-success: try to extract message
      String message = 'Request failed';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          message = (decoded['error'] ?? decoded['message'] ?? message).toString();
        }
      } catch (_) {
        message = response.body.isNotEmpty ? response.body : message;
      }

      throw ApiException(message, response.statusCode);
    } on SocketException {
      throw ApiException('Network error. Please check your connection.', 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Request failed: $e', 0);
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
