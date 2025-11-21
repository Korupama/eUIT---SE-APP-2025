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
      'profile_title': 'Hồ sơ chi tiết',
      'tuition': 'Học phí',
      'exams': 'Lịch thi',
      'events': 'Sự kiện',
      'link_open_failed': 'Không thể mở liên kết. Vui lòng thử lại sau.',
      'error_prefix': 'Lỗi: ',
      'password_changed': 'Mật khẩu đã được đổi.',
      'under_development': 'Đang phát triển...',
      // Settings & related
      'notifications': 'Thông báo',
      'account_security': 'Tài khoản & Bảo mật',
      'logout_title': 'Đăng xuất',
      'logout_confirm': 'Bạn có chắc chắn muốn đăng xuất không?',
      'confirm': 'Đồng ý',
      'feedback_subject': 'Phản hồi eUIT',
      'interface_language': 'Giao diện & Ngôn ngữ',
      'theme_mode_label': 'Chế độ giao diện',
      'light_mode': 'Sáng',
      'dark_mode': 'Tối',
      'system_mode': 'Hệ thống',
      'language': 'Ngôn ngữ',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'push_notifications': 'Nhận thông báo đẩy',
      'notification_customization': 'Tùy chỉnh thông báo',
      'change_password': 'Đổi mật khẩu',
      'logout': 'Đăng xuất',
      'about_app': 'Về ứng dụng',
      'version': 'Phiên bản',
      'send_feedback': 'Gửi phản hồi & Báo lỗi',
      'privacy_policy': 'Chính sách bảo mật',
      'student_name_placeholder': 'Nguyễn Văn A',
      'student_id_placeholder': 'MSSV: B1234567',
      'username': 'Tên tài khoản',
      'password': 'Mật khẩu',
      'forgot_password': 'Quên mật khẩu?',
      'empty_username': 'Vui lòng nhập tên tài khoản',
      'empty_password': 'Vui lòng nhập mật khẩu',
      'please_enter_username': 'Vui lòng nhập tên tài khoản',
      'please_enter_password': 'Vui lòng nhập mật khẩu',
      'invalid_credentials': 'Sai tên tài khoản hoặc mật khẩu',
      'network_error': 'Không thể kết nối đến máy chủ',
      'login_failed': 'Đăng nhập thất bại',
      'invalid_response': 'Phản hồi không hợp lệ từ máy chủ',
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
      // Added keys for new dialogs/cards
      'coming_soon': 'Sắp ra mắt',
      'close': 'Đóng',
      'digital_student_card_preview': 'Xem trước thẻ sinh viên số',
      'gpa_details_soon': 'Chi tiết GPA sẽ có trong bản cập nhật sau',
      'profile_preview_coming_soon': 'Xem trước hồ sơ sinh viên sẽ có trong bản cập nhật sau',
      'old_password_label': 'Mật khẩu cũ',
      'new_password_label': 'Mật khẩu mới',
      'old_password_required': 'Vui lòng nhập mật khẩu cũ',
      'new_password_min_length': 'Mật khẩu phải có ít nhất 6 ký tự',
    },
    'en': {
      'login': 'Login',
      'profile_title': 'Profile Details',
      'tuition': 'Tuition',
      'exams': 'Exams',
      'events': 'Events',
      'link_open_failed': 'Cannot open the link. Please try again later.',
      'error_prefix': 'Error: ',
      'password_changed': 'Password has been changed.',
      'under_development': 'Under development...',
      // Settings & related
      'notifications': 'Notifications',
      'account_security': 'Account & Security',
      'logout_title': 'Log out',
      'logout_confirm': 'Are you sure you want to log out?',
      'confirm': 'Confirm',
      'feedback_subject': 'eUIT Feedback',
      'interface_language': 'Appearance & Language',
      'theme_mode_label': 'Theme Mode',
      'light_mode': 'Light',
      'dark_mode': 'Dark',
      'system_mode': 'System',
      'language': 'Language',
      'vietnamese': 'Tiếng Việt',
      'english': 'English',
      'push_notifications': 'Push notifications',
      'notification_customization': 'Notification preferences',
      'change_password': 'Change password',
      'logout': 'Log out',
      'about_app': 'About app',
      'version': 'Version',
      'send_feedback': 'Send feedback & Bug report',
      'privacy_policy': 'Privacy policy',
      'student_name_placeholder': 'Nguyen Van A',
      'student_id_placeholder': 'Student ID: B1234567',
      'username': 'Username',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'empty_username': 'Please enter username',
      'empty_password': 'Please enter password',
      'please_enter_username': 'Please enter username',
      'please_enter_password': 'Please enter password',
      'invalid_credentials': 'Invalid username or password',
      'network_error': 'Cannot connect to server',
      'login_failed': 'Login failed',
      'invalid_response': 'Invalid server response',
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
      // Added keys for new dialogs/cards
      'coming_soon': 'Coming soon',
      'close': 'Close',
      'digital_student_card_preview': 'Digital student card preview',
      'gpa_details_soon': 'GPA details will be available in a future update',
      'profile_preview_coming_soon': 'Student profile preview will be available in a future update',
      'old_password_label': 'Old password',
      'new_password_label': 'New password',
      'old_password_required': 'Please enter old password',
      'new_password_min_length': 'Password must be at least 6 characters',
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
