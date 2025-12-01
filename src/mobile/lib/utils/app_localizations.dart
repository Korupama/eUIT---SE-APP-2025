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
      'id': 'MSSV',
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
      'room': 'Phòng',
      'lecturer': 'Giảng viên',
      'starts_in': 'Bắt đầu trong',
      'view_full_schedule': 'Xem toàn bộ thời khóa biểu',
      'view_all': 'Xem tất cả',
      'new_notifications': 'Thông báo mới',
      'student_card': 'Thẻ sinh viên',
      'gpa': 'GPA',
      'credits': 'Tín chỉ',
      'quick_actions': 'Thao tác nhanh',
      'services': 'Dịch vụ',
      'search': 'Tra cứu',
      'home': 'Trang chủ',
      'schedule': 'Lịch trình',
      'settings': 'Cài đặt',
      // Header for Navigation / Search screen
      'search_title': 'Tra cứu thông tin',
      'search_subtitle': 'Tìm kiếm thông tin sinh viên',
      // Added keys for new dialogs/cards
      'coming_soon': 'Sắp ra mắt',
      'close': 'Đóng',
      'digital_student_card_preview': 'Xem trước thẻ sinh viên số',
      'gpa_details_soon': 'Chi tiết GPA sẽ có trong bản cập nhật sau',
      'profile_preview_coming_soon': 'Xem trước hồ sơ sinh viên sẽ có trong bản cập nhật sau',
      // Services screen
      'services_description': 'Cung cấp các dịch vụ trực tuyến cho sinh viên',
      'waiting_integration': 'Đang chờ tích hợp dịch vụ',
      'old_password_label': 'Mật khẩu cũ',
      'new_password_label': 'Mật khẩu mới',
      'old_password_required': 'Vui lòng nhập mật khẩu cũ',
      'new_password_min_length': 'Mật khẩu phải có ít nhất 6 ký tự',
      // New keys for StudentIdCard header
      'vnu_name': 'ĐẠI HỌC QUỐC GIA THÀNH PHỐ HỒ CHÍ MINH',
      'uit_name': 'TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN',
      'card_title': 'Thẻ sinh viên',
      // Student confirmation screen
      'student_confirmation_title': 'Đăng ký giấy xác nhận sinh viên',
      'student_confirmation_reason_title': 'Lý do xác nhận',
      'student_confirmation_reason_military_defer': 'Tạm hoãn nghĩa vụ quân sự',
      'student_confirmation_reason_dorm_extend': 'Xin gia hạn ở Ký túc xá',
      'student_confirmation_reason_tax_reduction': 'Bổ sung hồ sơ giảm thuế thu nhập cá nhân cho gia đình',
      'student_confirmation_reason_military_education': 'Đăng ký học Giáo dục Quốc phòng',
      'student_confirmation_reason_other': 'Khác',
      'student_confirmation_reason_other_hint': 'Nhập lý do khác...',
      'student_confirmation_other_required': 'Vui lòng nhập lý do khác',
      'student_confirmation_reason_required': 'Vui lòng chọn lý do xác nhận',
      'student_confirmation_submit': 'Đăng ký giấy',
      'student_confirmation_success_title': 'Đăng ký thành công',
      'student_confirmation_serial_number': 'Số hiệu',
      'student_confirmation_expiry_date': 'Ngày hết hạn',
      // History / empty state for confirmation screen
      'student_confirmation_history_title': 'Lịch sử đăng ký',
      'no_history': 'Không có lịch sử',
      // Notes for student confirmation screen
      'student_confirmation_other_section_title': 'Lý do khác',
      'student_confirmation_other_section_instruction': 'Nhập theo mẫu bổ sung hồ sơ',
      'student_confirmation_other_section_example': 'Ví dụ mẫu: Bổ sung hồ sơ học bổng ở địa phương, ...',
      'student_confirmation_other_section_format_warning': 'Nếu sai mẫu này giấy xác nhận sẽ bị huỷ.',
      'student_confirmation_review_warning': 'Vui lòng kiểm tra thật kỹ thông tin trước khi yêu cầu.\nNếu sai liên hệ phòng CTSV để làm lại.',
      // Certificate confirmation / registration screen
      'certificate_registration_title': 'Đăng ký xác nhận chứng chỉ',
      'certificate_type_label': 'Loại chứng chỉ',
      'certificate_type_required': 'Vui lòng chọn loại chứng chỉ',
      'date_of_birth': 'Ngày sinh',
      'select_date': 'Chọn ngày',
      'date_of_birth_required': 'Vui lòng chọn ngày sinh',
      'id_number_label': 'CMND/CCCD (sinh viên dùng khi đăng ký dự thi)',
      'id_number_hint': 'Nhập số CMND/CCCD',
      'id_number_required': 'Vui lòng nhập CMND/CCCD',
      'total_score': 'Tổng điểm',
      'total_score_hint': 'Nhập tổng điểm',
      'exam_date': 'Ngày thi',
      'upload_file': 'Tải lên ảnh (jpg, png, gif, jpeg)',
      'choose_file': 'Chọn tệp',
      'no_file_selected': 'Chưa chọn tệp',
      'file_required': 'Vui lòng chọn tệp ảnh (jpg, png, gif, jpeg)',
      'invalid_file_type': 'Định dạng tệp không hợp lệ',
      'file_pick_error': 'Không thể chọn tệp. Vui lòng thử lại',
      'trf_number_label': 'Số TRF',
      'trf_number_hint': 'Nhập số TRF',
      // BCU-EPT fields
      'bcu_listening_label': 'Điểm Nghe (BCU-EPT)',
      'bcu_listening_hint': 'Nhập điểm Nghe',
      'bcu_reading_label': 'Điểm Đọc (BCU-EPT)',
      'bcu_reading_hint': 'Nhập điểm Đọc',
      'bcu_speaking_label': 'Điểm Nói (BCU-EPT)',
      'bcu_speaking_hint': 'Nhập điểm Nói',
      'bcu_writing_label': 'Điểm Viết (BCU-EPT)',
      'bcu_writing_hint': 'Nhập điểm Viết',
      'apply_uit_global_scholarship': 'Đăng ký xét Học bổng ngoại ngữ UIT Global',
      'view_regulations': 'Xem qui định',
      'save': 'Lưu',
      'saved_success': 'Đã lưu (mô phỏng). Đồng bộ với backend sau.',
      'choose_certificate_placeholder': '- Chọn loại chứng chỉ -',
      // JLPT specific fields
      'jlpt_level_label': 'Cấp độ JLPT',
      'jlpt_level_placeholder': '- Chọn cấp độ -',
      // TOEIC specific fields
      'toeic_listening_label': 'Điểm Nghe',
      'toeic_listening_hint': 'Nhập điểm Nghe',
      'toeic_reading_label': 'Điểm Đọc',
      'toeic_reading_hint': 'Nhập điểm Đọc',
      'invalid_number': 'Không hợp lệ',
      // REG / test place and TOEIC speaking/writing
      'reg_number_label': 'Số REG',
      'reg_number_hint': 'Nhập số REG',
      'test_place_label': 'Nơi thi',
      'test_place_hint': 'Nhập nơi thi',
      'toeic_speaking_label': 'Điểm Nói',
      'toeic_speaking_hint': 'Nhập điểm Nói',
      'toeic_writing_label': 'Điểm Viết',
      'toeic_writing_hint': 'Nhập điểm Viết',
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
      'id': 'Student ID',
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
      'room': 'Room',
      'lecturer': 'Lecturer',
      'starts_in': 'Starts in',
      'view_full_schedule': 'View full schedule',
      'view_all': 'View all',
      'new_notifications': 'New Notifications',
      'student_card': 'Student Card',
      'gpa': 'GPA',
      'credits': 'Credits',
      'quick_actions': 'Quick Actions',
      'services': 'Services',
      'search': 'Search',
      'home': 'Home',
      'schedule': 'Schedule',
      'settings': 'Settings',
      // Header for Navigation / Search screen
      'search_title': 'Search Information',
      'search_subtitle': 'Find student information',
      // Added keys for new dialogs/cards
      'coming_soon': 'Coming soon',
      'close': 'Close',
      'digital_student_card_preview': 'Digital student card preview',
      'gpa_details_soon': 'GPA details will be available in a future update',
      'profile_preview_coming_soon': 'Student profile preview will be available in a future update',
      // Services screen
      'services_description': 'Providing online services for students',
      'waiting_integration': 'Waiting for service integration',
      'old_password_label': 'Old password',
      'new_password_label': 'New password',
      'old_password_required': 'Please enter old password',
      'new_password_min_length': 'Password must be at least 6 characters',
      // New keys for StudentIdCard header
      'vnu_name': 'VIETNAM NATIONAL UNIVERSITY HO CHI MINH CITY',
      'uit_name': 'UNIVERSITY OF INFORMATION TECHNOLOGY',
      'card_title': 'Student Card',
      // Student confirmation screen
      'student_confirmation_title': 'Student confirmation certificate request',
      'student_confirmation_reason_title': 'Reason for confirmation',
      'student_confirmation_reason_military_defer': 'Postponement of military service',
      'student_confirmation_reason_dorm_extend': 'Dormitory stay extension request',
      'student_confirmation_reason_tax_reduction': 'Family personal income tax reduction documents',
      'student_confirmation_reason_military_education': 'Registration for National Defense Education',
      'student_confirmation_reason_other': 'Other',
      'student_confirmation_reason_other_hint': 'Enter other reason...',
      'student_confirmation_other_required': 'Please enter the other reason',
      'student_confirmation_reason_required': 'Please select a confirmation reason',
      'student_confirmation_submit': 'Request certificate',
      'student_confirmation_success_title': 'Request created successfully',
      'student_confirmation_serial_number': 'Serial number',
      'student_confirmation_expiry_date': 'Expiry date',
      // History / empty state for confirmation screen
      'student_confirmation_history_title': 'Request history',
      'no_history': 'No history',
      // Notes for student confirmation screen
      'student_confirmation_other_section_title': 'Other reason',
      'student_confirmation_other_section_instruction': 'Enter following supplementary document format',
      'student_confirmation_other_section_example': 'Example format: Supplement scholarship documents from local authorities, ...',
      'student_confirmation_other_section_format_warning': 'If this format is incorrect, the confirmation letter will be cancelled.',
      'student_confirmation_review_warning': 'Please check all information carefully before submitting.\nIf incorrect, contact the Student Affairs Office to have it reissued.',
      // Certificate confirmation / registration screen
      'certificate_registration_title': 'Certificate confirmation registration',
      'certificate_type_label': 'Certificate type',
      'certificate_type_required': 'Please select certificate type',
      'date_of_birth': 'Date of birth',
      'select_date': 'Select date',
      'date_of_birth_required': 'Please select date of birth',
      'id_number_label': 'ID Card / Citizen ID  (used for exam registration)',
      'id_number_hint': 'Enter ID card or citizen ID number',
      'id_number_required': 'Please enter ID number',
      'total_score': 'Total score',
      'total_score_hint': 'Enter total score',
      'exam_date': 'Exam date',
      'upload_file': 'Upload image (jpg, png, gif, jpeg)',
      'choose_file': 'Choose file',
      'no_file_selected': 'No file selected',
      'file_required': 'Please select an image file (jpg, png, gif, jpeg)',
      'invalid_file_type': 'Invalid file type',
      'file_pick_error': 'Unable to pick file. Please try again',
      'trf_number_label': 'TRF Number',
      'trf_number_hint': 'Enter TRF number',
      // BCU-EPT fields
      'bcu_listening_label': 'Listening score (BCU-EPT)',
      'bcu_listening_hint': 'Enter listening score',
      'bcu_reading_label': 'Reading score (BCU-EPT)',
      'bcu_reading_hint': 'Enter reading score',
      'bcu_speaking_label': 'Speaking score (BCU-EPT)',
      'bcu_speaking_hint': 'Enter speaking score',
      'bcu_writing_label': 'Writing score (BCU-EPT)',
      'bcu_writing_hint': 'Enter writing score',
      'apply_uit_global_scholarship': 'Apply for UIT Global language scholarship',
      'view_regulations': 'View regulations',
      'save': 'Save',
      'saved_success': 'Saved (simulated). Will integrate with backend later.',
      'choose_certificate_placeholder': '- Choose certificate -',
      // JLPT specific fields
      'jlpt_level_label': 'JLPT level',
      'jlpt_level_placeholder': '- Choose level -',
      // TOEIC specific fields
      'toeic_listening_label': 'Listening score',
      'toeic_listening_hint': 'Enter listening score',
      'toeic_reading_label': 'Reading score',
      'toeic_reading_hint': 'Enter reading score',
      'invalid_number': 'Invalid number',
      // REG / test place and TOEIC speaking/writing
      'reg_number_label': 'REG number',
      'reg_number_hint': 'Enter REG number',
      'test_place_label': 'Test center',
      'test_place_hint': 'Enter test center',
      'toeic_speaking_label': 'Speaking score',
      'toeic_speaking_hint': 'Enter speaking score',
      'toeic_writing_label': 'Writing score',
      'toeic_writing_hint': 'Enter writing score',
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
