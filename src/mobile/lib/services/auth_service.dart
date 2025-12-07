import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:developer' as developer;
import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Notifier shared across all AuthService instances so providers and UI can
  // listen for token changes (login/logout) and react immediately.
  static final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);

  // Notifier shared for role
  static final ValueNotifier<String?> roleNotifier = ValueNotifier<String?>(null);

  static bool _initialized = false;

  AuthService();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _roleKey = 'auth_role'; // New key for user role
  static const String _loginPath = '/api/Auth/login';

  // Static storage instance for initialization
  static final FlutterSecureStorage _staticStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  FlutterSecureStorage? _storageInstance;
  FlutterSecureStorage get _storage {
    _storageInstance ??= const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    return _storageInstance!;
  }

  /// Initialize AuthService by loading saved token from secure storage.
  /// Must be called in main() before runApp() to ensure token is loaded
  /// before the UI is built.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final token = await _staticStorage.read(key: _tokenKey);
      tokenNotifier.value = token;
      final savedRole = await _staticStorage.read(key: _roleKey);
      roleNotifier.value = savedRole;
      developer.log('AuthService: initialized with token ${token == null ? 'null' : '***'} and role ${savedRole ?? 'null'}', name: 'AuthService');
    } catch (e) {
      developer.log('AuthService: Error during initialization: $e', name: 'AuthService');
      // Ensure notifiers are set even on error
      tokenNotifier.value = null;
      roleNotifier.value = null;
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
  /// Also persists both access and refresh tokens automatically.
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
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
          'userId': userId,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 15));
    } on Exception {
      try {
        client.close();
      } catch (_) {}
      clientClosed = true;
      throw Exception('network_error');
    } finally {
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
        final accessToken = (body['accessToken'] as String?) ?? (body['token'] as String?);
        final refreshToken = body['refreshToken'] as String?;

        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('invalid_response');
        }

        // AUTO-SAVE both tokens and role
        await saveTokens(accessToken, refreshToken, role: role);

        return accessToken;
      } catch (e) {
        developer.log('AuthService: login parse error: $e', name: 'AuthService');
        throw Exception('invalid_response');
      }
    }

    // Non-success: try to parse error
    String message = 'login_failed';
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        final m = (decoded['error'] ?? decoded['message']);
        if (m != null && m.toString().trim().isNotEmpty) {
          message = m.toString();
        }
      }
    } catch (_) {}

    if (res.statusCode == 401 || res.statusCode == 403 || message.toLowerCase().contains('invalid')) {
      throw Exception('invalid_credentials');
    }

    throw Exception(message);
  }

  /// Save access and refresh tokens securely, along with user role.
  /// Updates tokenNotifier if access token changes.
  Future<void> saveTokens(String accessToken, String? refreshToken, {String? role}) async {
    // Update in-memory notifiers IMMEDIATELY to prevent race conditions.
    tokenNotifier.value = accessToken;
    if (role != null) {
      roleNotifier.value = role;
    }

    try {
      await _storage.write(key: _tokenKey, value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }
      if (role != null) {
        await _storage.write(key: _roleKey, value: role);
      }
      developer.log('AuthService: Tokens and role saved to secure storage.', name: 'AuthService');
    } catch (e) {
      developer.log('AuthService: Error saving tokens to secure storage: $e', name: 'AuthService', error: e);
    }
  }

  // ... (code for saveToken and getToken remains the same) ...

  Future<String?> getToken() async {
    // First try to get from memory
    if (tokenNotifier.value != null) {
      return tokenNotifier.value;
    }

    // Then try storage
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        tokenNotifier.value = token;
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Get saved user role (student/lecturer/admin).
  /// Prioritizes in-memory notifier, then secure storage, then falls back to decoding JWT.
  Future<String?> getRole() async {
    // 1. Priority: In-memory notifier (fastest, avoids storage I/O)
    if (roleNotifier.value != null && roleNotifier.value!.isNotEmpty) {
      return roleNotifier.value;
    }

    // 2. Secure storage
    try {
      final storedRole = await _storage.read(key: _roleKey);
      if (storedRole != null && storedRole.isNotEmpty) {
        roleNotifier.value = storedRole; // Update notifier if it was out of sync
        return storedRole;
      }
    } catch (_) {
      // Ignore storage read errors
    }

    // 3. Fallback: Decode JWT access token and extract role claim
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> map = jsonDecode(decoded);

      // Common claim keys used by .NET Identity
      final possibleKeys = [
        'role',
        'roles',
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
      ];

      for (final k in possibleKeys) {
        if (map.containsKey(k)) {
          final v = map[k];
          if (v is String && v.isNotEmpty) {
            await _storage.write(key: _roleKey, value: v); // Persist the found role
            roleNotifier.value = v;
            return v;
          }
          if (v is List && v.isNotEmpty && v.first is String) {
            final firstRole = v.first as String;
            await _storage.write(key: _roleKey, value: firstRole); // Persist the found role
            roleNotifier.value = firstRole;
            return firstRole;
          }
        }
      }
    } catch (_) {
      // ignore JSON or base64 errors
    }

    return null;
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _roleKey); // Also delete role
      tokenNotifier.value = null;
      roleNotifier.value = null; // Clear role notifier
      developer.log('AuthService: tokens deleted', name: 'AuthService');
    } catch (e) {
      developer.log('AuthService: Error deleting tokens: $e', name: 'AuthService');
      tokenNotifier.value = null;
      roleNotifier.value = null;
    }
  }

  Future<void> logout() async {
    // Optionally call backend to revoke token if API exists
    // try {
    //   final rt = await getRefreshToken();
    //   if (rt != null) { ... call logout api ... }
    // } catch (_) {} 
    await deleteToken();
    developer.log('AuthService: User logged out', name: 'AuthService');
  }

  // Refresh access token using stored refresh token
  Future<String?> refreshAccessToken() async {
    try {
      developer.log('AuthService: Attempting to refresh access token', name: 'AuthService');
      
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        developer.log('AuthService: No refresh token found', name: 'AuthService');
        return null; // Cannot refresh without token
      }

      final uri = buildUri('/api/Auth/refresh');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}), 
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccessToken = body['accessToken'] as String?;
        final newRefreshToken = body['refreshToken'] as String?; // Backend rotates it

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await saveTokens(newAccessToken, newRefreshToken);
          developer.log('AuthService: Access token refreshed successfully', name: 'AuthService');
          return newAccessToken;
        }
      } else {
        // If refresh fails (401/403, expired, revoked), we should logout
        developer.log('AuthService: Refresh failed with status ${res.statusCode}', name: 'AuthService');
        // Optional: force logout if refresh fails
        // await logout(); 
      }
      
      return null;
    } catch (e) {
      developer.log('AuthService: Error refreshing token: $e', name: 'AuthService');
      return null;
    }
  }

  // --- Credential helpers ---
  Future<void> saveCredentials(String username, String password) async {
    try {
      await _storage.write(key: _savedUsernameKey, value: username);
      await _storage.write(key: _savedPasswordKey, value: password);
    } catch (_) {}
  }

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

  Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: _savedUsernameKey);
      await _storage.delete(key: _savedPasswordKey);
    } catch (_) {}
  }

  // --- Remember-me flag ---
  static const String _rememberMePrefKey = 'remember_me_enabled';

  Future<void> setRememberMe(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMePrefKey, enabled);
    } catch (_) {}
  }

  Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMePrefKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  // --- Transient in-memory last-logged username ---
  String? _transientLastUsername;

  void setTransientLastUsername(String? username) {
    _transientLastUsername = username;
  }

  String? getTransientLastUsername() => _transientLastUsername;

  void clearTransientLastUsername() {
    _transientLastUsername = null;
  }

  // Serialized refresh completer to avoid parallel refresh calls
  Completer<String?>? _refreshCompleter;

  /// Returns true if access token is expired or will expire within [marginSeconds].
  /// If token is not a valid JWT or `exp` cannot be parsed, treat as expired.
  static bool isAccessTokenExpired(String token, {int marginSeconds = 60}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true; // not a JWT
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> map = jsonDecode(decoded);

      final expRaw = map['exp'];
      if (expRaw == null) return true;

      final exp = expRaw is int ? expRaw : int.tryParse(expRaw.toString());
      if (exp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp <= now + marginSeconds;
    } catch (_) {
      return true;
    }
  }

  /// Internal: ensures only one refreshAccessToken() call runs at a time.
  /// Returns the new access token or null on failure.
  Future<String?> _refreshIfNeeded() async {
    // If a refresh is already in progress, await it
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    _refreshCompleter = Completer<String?>();
    try {
      final newToken = await refreshAccessToken();
      _refreshCompleter!.complete(newToken);
      return newToken;
    } catch (e) {
      if (!(_refreshCompleter?.isCompleted ?? true)) {
        _refreshCompleter!.completeError(e);
      }
      rethrow;
    } finally {
      // allow garbage collection and next refresh
      _refreshCompleter = null;
    }
  }

  /// Public helper: returns a valid access token, refreshing it if expired.
  /// Returns null if no token available or refresh fails.
  Future<String?> getValidToken({int marginSeconds = 60}) async {
    final token = await getToken();
    if (token == null) return null;

    // If token seems fine, return it
    if (!isAccessTokenExpired(token, marginSeconds: marginSeconds)) return token;

    // Otherwise try to refresh (serialized)
    try {
      final refreshed = await _refreshIfNeeded();
      return refreshed ?? await getToken(); // refreshed may be null, so try reading stored token
    } catch (e) {
      // refresh failed
      developer.log('AuthService: getValidToken refresh failed: $e', name: 'AuthService');
      return null;
    }
  }
}
