import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Storage key for the auth token
  static const String _tokenKey = 'auth_token';
  static const String _loginPath = '/api/Auth/login';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys for storing credentials securely
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';

  Uri buildUri(String path) {
    // Safely read API_URL; if dotenv not initialized or key missing, fallback.
    String effectiveBase;
    try {
      final base = (dotenv.isInitialized ? dotenv.env['API_URL'] : null)?.trim();
      effectiveBase = (base != null && base.isNotEmpty) ? base : 'http://localhost:5128';
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
        // keep as-is; parsing failed
      }
    }

    // Ensure single slash between base and path
    if (effectiveBase.endsWith('/') && path.startsWith('/')) {
      return Uri.parse(effectiveBase.substring(0, effectiveBase.length - 1) + path);
    }
    return Uri.parse(effectiveBase + path);
  }

  /// Calls backend login API and returns JWT token on success.
  ///
  /// Contract:
  /// - Inputs: userId, password; optional role defaults to 'student'.
  /// - Output: token string.
  /// - Errors: throws Exception with a stable key 'invalid_credentials' for authentication failures,
  ///   or other message keys like 'login_failed'/'invalid_response' for other cases.
  Future<String> login(String userId, String password, {String role = 'student'}) async {
    final uri = buildUri(_loginPath);

    http.Response res;
    try {
      res = await http.post(
        uri,
        // No required headers, but Content-Type helps most backends parse JSON.
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
          'userId': userId,
          'password': password,
        }),
      );
    } catch (e) {
      // Network/connection error
      throw Exception('network_error');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
        final token = body['token'] as String?;
        if (token == null || token.isEmpty) {
          throw Exception('invalid_response');
        }
        // Do not persist here to avoid double-write; caller may decide.
        return token;
      } catch (_) {
        throw Exception('invalid_response');
      }
    }

    // Non-success: try to parse error formats { error } or { message }
    String message = 'login_failed';
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        final m = (decoded['error'] ?? decoded['message']);
        if (m != null && m.toString().trim().isNotEmpty) {
          message = m.toString();
        }
      }
    } catch (_) {
      // keep default message
    }

    // Normalize common auth failures for the UI to localize
    if (res.statusCode == 401 || res.statusCode == 403 || message.toLowerCase().contains('invalid')) {
      throw Exception('invalid_credentials');
    }

    throw Exception(message);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- Credential helpers ---
  /// Save username and password securely. Password is stored in secure storage.
  Future<void> saveCredentials(String username, String password) async {
    try {
      await _storage.write(key: _savedUsernameKey, value: username);
      await _storage.write(key: _savedPasswordKey, value: password);
    } catch (_) {
      // ignore write errors; caller may handle UX
    }
  }

  /// Returns a map with 'username' and 'password' or null if none stored.
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final username = await _storage.read(key: _savedUsernameKey);
      final password = await _storage.read(key: _savedPasswordKey);
      if (username == null || password == null) return null;
      return {'username': username, 'password': password};
    } catch (_) {
      return null;
    }
  }

  /// Deletes stored credentials.
  Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: _savedUsernameKey);
      await _storage.delete(key: _savedPasswordKey);
    } catch (_) {
      // ignore
    }
  }
}
