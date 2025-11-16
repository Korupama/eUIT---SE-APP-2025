import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // TODO: Switch to flutter_secure_storage for production secret storage.
  static const String _tokenKey = 'auth_token';

  Future<String> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    // Fake logic: accept any username if password is exactly "password"
    if (password == 'password') {
      final token = 'fake_token_${DateTime.now().millisecondsSinceEpoch}';
      await saveToken(token);
      return token;
    }
    // Use a stable error code that the UI can localize instead of a hard-coded message.
    throw Exception('invalid_credentials');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
