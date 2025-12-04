import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Notifier shared across all AuthService instances so providers and UI can
  // listen for token changes (login/logout) and react immediately.
  static final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);

  AuthService() {
    // Initialize notifier with stored token once.
    _init();
  }

  // Storage key for the auth token
  static const String _tokenKey = 'auth_token';
  static const String _loginPath = '/api/Auth/login';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Read stored token at startup and update the notifier.
  Future<void> _init() async {
    try {
      final t = await _storage.read(key: _tokenKey);
      if (tokenNotifier.value != t) {
        tokenNotifier.value = t;
        developer.log('AuthService: initialized tokenNotifier with value ${t == null ? 'null' : '***'}', name: 'AuthService');
      }
    } catch (_) {
      // ignore read errors
    }
  }

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
  /// - Output: accessToken string. The backend now returns two keys: `accessToken` and `refreshToken`.
  ///   `accessToken` is treated the same as the old `token` and is returned. The `refreshToken` is
  ///   accepted if present but not persisted/used yet.
  /// - Errors: throws Exception with a stable key 'invalid_credentials' for authentication failures,
  ///   or other message keys like 'login_failed'/'invalid_response' for other cases.
  Future<String> login(String userId, String password, {String role = 'student'}) async {
    final uri = buildUri(_loginPath);

    http.Response res;
    // Use a per-request Client so we can close it to abort the underlying connection
    final client = http.Client();
    var clientClosed = false;
    try {
      res = await client
          .post(
        uri,
        // No required headers, but Content-Type helps most backends parse JSON.
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
          'userId': userId,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15)); // <-- 15s timeout
    } on Exception {
      // Ensure the client is closed to abort the underlying connection
      try {
        client.close();
      } catch (_) {}
      clientClosed = true;
      // Network/connection error (including TimeoutException)
      throw Exception('network_error');
    } finally {
      // Close client if not already closed (successful response still needs client closed)
      if (!clientClosed) {
        try {
          client.close();
        } catch (_) {}
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
        // New response format: { "accessToken": "...", "refreshToken": "..." }
        // Keep backward compatibility with old key 'token'.
        final accessToken = (body['accessToken'] as String?) ?? (body['token'] as String?);
        final refreshToken = body['refreshToken'] as String?;
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('invalid_response');
        }
        // We accept refreshToken but do not persist or use it yet; log presence for debugging.
        if (refreshToken != null && refreshToken.isNotEmpty) {
          developer.log('AuthService: received refreshToken (not persisted)', name: 'AuthService');
        }
        // Do not persist here to avoid double-write; caller may decide.
        return accessToken;
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
    try {
      // Notify listeners (e.g., providers) that a new token is available.
      tokenNotifier.value = token;
      developer.log('AuthService: saveToken called; token saved and notified', name: 'AuthService');
    } catch (_) {
      // ignore notifier errors
    }
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    try {
      tokenNotifier.value = null;
      developer.log('AuthService: deleteToken called; token removed and notified', name: 'AuthService');
    } catch (_) {
      // ignore
    }
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

  // --- Remember-me flag stored in SharedPreferences (non-sensitive)
  static const String _rememberMePrefKey = 'remember_me_enabled';

  /// Persist whether "remember me" was enabled. This flag is kept in
  /// SharedPreferences (non-sensitive) and indicates whether saved
  /// credentials in secure storage should be loaded at app start.
  Future<void> setRememberMe(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMePrefKey, enabled);
    } catch (_) {
      // ignore
    }
  }

  /// Returns whether "remember me" was enabled. Defaults to false.
  Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMePrefKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  // --- Transient in-memory last-logged username (not persisted)
  // Used to prefill username once immediately after logout, without
  // persisting it across app restarts.
  String? _transientLastUsername;

  /// Set a transient last-logged-in username (in-memory only).
  void setTransientLastUsername(String? username) {
    _transientLastUsername = username;
  }

  /// Get transient last username (may be null). Not persisted.
  String? getTransientLastUsername() => _transientLastUsername;

  /// Clear transient username.
  void clearTransientLastUsername() {
    _transientLastUsername = null;
  }
}
