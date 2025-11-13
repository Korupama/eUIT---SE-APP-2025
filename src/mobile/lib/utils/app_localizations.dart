import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  // Simple key-value mock (normally use ARB & code-gen)
  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'login': 'Đăng nhập',
      'username': 'Tên tài khoản',
      'password': 'Mật khẩu',
      'forgot_password': 'Quên mật khẩu?',
      'empty_username': 'Vui lòng nhập tên tài khoản',
      'empty_password': 'Vui lòng nhập mật khẩu',
      'please_enter_username': 'Vui lòng nhập tên tài khoản',
      'please_enter_password': 'Vui lòng nhập mật khẩu',
      'invalid_credentials': 'Sai tên tài khoản hoặc mật khẩu',
      'logging_in': 'Đang đăng nhập...',
      'remember_me': 'Ghi nhớ tài khoản',
      'university_name': 'Trường Đại học Công Nghệ Thông Tin',
      'welcome_back': 'Chào mừng trở lại,',
      'next_schedule': 'Lịch trình tiếp theo',
      'starts_in': 'Bắt đầu trong',
      'view_full_schedule': 'Xem toàn bộ thời khóa biểu',
      'new_notifications': 'Thông báo mới',
      'student_card': 'Thẻ sinh viên',
      'gpa': 'GPA',
      'credits': 'tín chỉ',
      'quick_actions': 'Thao tác nhanh',
      'services': 'Dịch vụ',
      'search': 'Tra cứu',
      'home': 'Trang chủ',
      'schedule': 'Lịch trình',
      'settings': 'Cài đặt',
    },
    'en': {
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'empty_username': 'Please enter username',
      'empty_password': 'Please enter password',
      'please_enter_username': 'Please enter username',
      'please_enter_password': 'Please enter password',
      'invalid_credentials': 'Invalid username or password',
      'logging_in': 'Logging in...',
      'remember_me': 'Remember me',
      'university_name': 'University of Information Technology',
      'welcome_back': 'Welcome back,',
      'next_schedule': 'Next Schedule',
      'starts_in': 'Starts in',
      'view_full_schedule': 'View full schedule',
      'new_notifications': 'New Notifications',
      'student_card': 'Student Card',
      'gpa': 'GPA',
      'credits': 'credits',
      'quick_actions': 'Quick Actions',
      'services': 'Services',
      'search': 'Search',
      'home': 'Home',
      'schedule': 'Schedule',
      'settings': 'Settings',
    },
  };

  String t(String key) {
    final code = locale.languageCode;
    // Try exact match
    final exact = _localizedValues[code]?[key];
    if (exact != null) return exact;
    // Try primary subtag (e.g., 'vi_VN' -> 'vi')
    final primary = code.split(RegExp('[-_]'))[0];
    final primaryVal = _localizedValues[primary]?[key];
    if (primaryVal != null) return primaryVal;
    // Fallback to English if available
    final enVal = _localizedValues['en']?[key];
    if (enVal != null) return enVal;
    // Last resort: return the key so missing translations are visible
    return key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
