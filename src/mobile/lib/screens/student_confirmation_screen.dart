// ignore_for_file: deprecated_member_use
// TODO: Refactor API calling due to changing of backend structure
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/animated_background.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class StudentConfirmationScreen extends StatefulWidget {
  const StudentConfirmationScreen({super.key});

  @override
  State<StudentConfirmationScreen> createState() =>
      _StudentConfirmationScreenState();
}

// Small model to represent history items returned by the API
class ConfirmationHistoryItem {
  final int serialNumber;
  final String purpose;
  final String expiryDate;
  final String requestedAt;

  ConfirmationHistoryItem({
    required this.serialNumber,
    required this.purpose,
    required this.expiryDate,
    required this.requestedAt,
  });

  factory ConfirmationHistoryItem.fromJson(Map<String, dynamic> json) {
    return ConfirmationHistoryItem(
      serialNumber: (json['serialNumber'] is int)
          ? json['serialNumber'] as int
          : int.tryParse(json['serialNumber']?.toString() ?? '') ?? 0,
      purpose: json['purpose']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString() ?? '',
      requestedAt: json['requestedAt']?.toString() ?? '',
    );
  }
}

class _StudentConfirmationScreenState extends State<StudentConfirmationScreen> {
  // Selected language chip (UI only)
  String _selectedLang = 'vi';

  // Selected reason value
  String? _selectedReason;
  final TextEditingController _otherController = TextEditingController();
  bool _isSubmitting = false;

  // Scaffold key so we can open the endDrawer from the AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // History state
  List<ConfirmationHistoryItem> _history = [];
  bool _isHistoryLoading = false;

  @override
  void initState() {
    super.initState();
    // Defer reading Localizations.localeOf(context) until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Localizations.localeOf(context).languageCode.toLowerCase();
      setState(() {
        _selectedLang = locale.startsWith('en') ? 'en' : 'vi';
      });

      // Load history after we've initialized the UI context
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String _getPurposeText() {
    // Keep the same local label logic used for display (match selected language)
    final Map<String, String> vi = {
      'military': 'Tạm hoãn nghĩa vụ quân sự',
      'dorm': 'Xin gia hạn ở ký túc xá',
      'tax': 'Bổ sung hồ sơ giảm thuế thu nhập cá nhân cho gia đình',
      'education': 'Đăng ký học Giáo dục Quốc phòng',
      'other': 'Khác',
    };
    final Map<String, String> en = {
      'military': 'Defer military service',
      'dorm': 'Request dormitory extension',
      'tax': 'Supplement personal income tax documents for family',
      'education': 'Register for National Defense Education',
      'other': 'Other',
    };

    if (_selectedReason == null) return '';
    if (_selectedReason == 'other') return _otherController.text.trim();
    return _selectedLang == 'en'
        ? (en[_selectedReason!] ?? '')
        : (vi[_selectedReason!] ?? '');
  }

  // Fetch confirmation history from API
  Future<void> _loadHistory() async {
    setState(() => _isHistoryLoading = true);
    final auth = AuthService();
    try {
      final token = await auth.getToken();
      final uri = auth.buildUri('/api/service/confirmation-letter/history');
      final headers = {'Accept': 'application/json'};
      if (token != null && token.isNotEmpty)
        headers['Authorization'] = 'Bearer $token';

      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
        final parsed = list
            .map(
              (e) =>
                  ConfirmationHistoryItem.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        if (mounted) setState(() => _history = parsed);
      } else if (res.statusCode == 401) {
        await auth.deleteToken();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Yêu cầu đăng nhập lại')));
      } else {
        String message = 'Không thể tải lịch sử';
        try {
          final Map<String, dynamic> err =
              jsonDecode(res.body) as Map<String, dynamic>;
          if (err['message'] != null) message = err['message'].toString();
        } catch (_) {}
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi mạng, thử lại')));
    } finally {
      if (mounted) setState(() => _isHistoryLoading = false);
    }
  }

  Future<void> _submitConfirmation() async {
    // Validation
    final purpose = _getPurposeText();
    if (_selectedReason == null || purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lý do xác nhận')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = AuthService();
    try {
      final token = await auth.getToken();
      final uri = auth.buildUri('/api/service/confirmation-letter');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty)
        headers['Authorization'] = 'Bearer $token';

      final body = jsonEncode({'purpose': purpose});
      final res = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> json =
            jsonDecode(res.body) as Map<String, dynamic>;
        final serial = json['serialNumber']?.toString() ?? '—';
        final expiry = json['expiryDate']?.toString() ?? '';
        final requestDate = _formatDate(DateTime.now());

        // Show success dialog with details
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              AppLocalizations.of(
                context,
              ).t('student_confirmation_success_title'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số seri: $serial'),
                const SizedBox(height: 6),
                Text('Lý do: $purpose'),
                const SizedBox(height: 6),
                Text('Ngày yêu cầu: $requestDate'),
                const SizedBox(height: 6),
                Text('Ngày hết hạn: $expiry'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(AppLocalizations.of(context).t('close')),
              ),
            ],
          ),
        );

        // After successful submit, refresh history
        await _loadHistory();
      } else if (res.statusCode == 401) {
        // unauthorized
        await auth.deleteToken();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Yêu cầu đăng nhập lại')));
      } else {
        String message = 'Đăng ký thất bại';
        try {
          final Map<String, dynamic> err =
              jsonDecode(res.body) as Map<String, dynamic>;
          if (err['message'] != null) message = err['message'].toString();
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi mạng, thử lại')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      // Use a subtle semi-transparent scrim so the underlying animated background is visible but dimmed
      drawerScrimColor: Colors.black.withOpacity(0.5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context).t('student_confirmation_title'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Open the history drawer
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),

      // Add endDrawer to show history
      endDrawer: Drawer(
        // semi-transparent drawer background (adapts to light/dark for contrast)
        backgroundColor: isDark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.92),
        elevation: 0,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).t('student_confirmation_history_title'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isHistoryLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_history.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context).t('no_history'),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              itemCount: _history.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, idx) {
                                final item = _history[idx];
                                return ListTile(
                                  title: Text(
                                    'Số seri: ${item.serialNumber}',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Lý do: ${item.purpose}',
                                        style: TextStyle(fontSize: 12.sp),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Yêu cầu: ${item.requestedAt}',
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    item.expiryDate,
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  onTap: () {
                                    // Optionally close drawer and show details / copy serial
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            )),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // Use the shared AnimatedBackground widget for the animated backdrop
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),

          // Safe area for content; container has min height and submit button is fixed at bottom
          SafeArea(
            child: Padding(
              // add extra bottom padding so the fixed button doesn't cover content
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),

                      // Label for language selection (localized)
                      Text(
                        AppLocalizations.of(context).t('language'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Language chips row
                      Row(
                        children: [
                          _buildLanguageChip(context, 'vi'),
                          SizedBox(width: 12.w),
                          _buildLanguageChip(context, 'en'),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Title
                      Text(
                        AppLocalizations.of(
                          context,
                        ).t('student_confirmation_reason_title'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Glassmorphism container with radios — min height provided
                      Flexible(
                        fit: FlexFit.loose,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 280.h),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Color.fromRGBO(255, 255, 255, 0.1)
                                  : Color.fromRGBO(255, 255, 255, 0.8),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark
                                    ? Color.fromRGBO(255, 255, 255, 0.10)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Color.fromRGBO(0, 0, 0, 0.1)
                                      : Color.fromRGBO(0, 0, 0, 0.05),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _buildReasonList(context, isDark),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // spacer so content doesn't butt into the bottom fixed button area
                      SizedBox(height: 12.h),

                      // Small explanatory notes directly under the reasons card
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 8.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              ).t('student_confirmation_other_section_title'),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              AppLocalizations.of(context).t(
                                'student_confirmation_other_section_instruction',
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).t('student_confirmation_other_section_example'),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 12.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AppLocalizations.of(context).t(
                                'student_confirmation_other_section_format_warning',
                              ),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.red[400]
                                    : Colors.limeAccent,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Fixed submit button pinned to bottom of the SafeArea padding
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.bluePrimary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _isSubmitting ? null : _submitConfirmation,
                        child: _isSubmitting
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(
                                  context,
                                ).t('student_confirmation_submit'),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Localized review warning (separate, above the submit button)
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 58.h, // place above the fixed button
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).t('student_confirmation_review_warning'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(BuildContext context, String code) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedLang == code;
    final label = AppLocalizations.of(
      context,
    ).t(code == 'vi' ? 'vietnamese' : 'english');
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : isDark
              ? Colors.white
              : Colors.black87,
          fontSize: 13.sp,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedLang = code),
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.bluePrimary,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected
              ? AppTheme.bluePrimary
              : isDark
              ? Colors.white54
              : Color.fromRGBO(0, 0, 0, 0.8),
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    );
  }

  // TODO: Sửa lại cấu trúc request khi backend đã sửa thành language và purpose riêng biệt
  List<Widget> _buildReasonList(BuildContext context, bool isDark) {
    // Localized labels for the reasons (local, independent from AppLocalizations)
    final Map<String, String> vi = {
      'military': 'Tạm hoãn nghĩa vụ quân sự',
      'dorm': 'Xin gia hạn ở ký túc xá',
      'tax': 'Bổ sung hồ sơ giảm thuế thu nhập cá nhân cho gia đình',
      'education': 'Đăng ký học Giáo dục Quốc phòng',
      'other': 'Khác',
      'other_hint': 'Nhập lý do khác...',
    };

    final Map<String, String> en = {
      'military': 'Defer military service',
      'dorm': 'Request dormitory extension',
      'tax': 'Supplement personal income tax documents for family',
      'education': 'Register for National Defense Education',
      'other': 'Other',
      'other_hint': 'Enter other reason...',
    };

    final items = ['military', 'dorm', 'tax', 'education', 'other'];

    final List<Widget> widgets = [];

    for (var i = 0; i < items.length; i++) {
      final key = items[i];
      final label = _selectedLang == 'en' ? en[key]! : vi[key]!;
      final hint = _selectedLang == 'en'
          ? en['other_hint']!
          : vi['other_hint']!;

      widgets.add(
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 2.h),
          leading: Radio<String>(
            value: key,
            groupValue: _selectedReason,
            onChanged: (v) => setState(() {
              _selectedReason = v;
              if (v != 'other') _otherController.clear();
            }),
            fillColor: MaterialStateProperty.all(AppTheme.bluePrimary),
            visualDensity: VisualDensity.compact,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 13.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => setState(() {
            _selectedReason = key;
            if (key != 'other') _otherController.clear();
          }),
        ),
      );

      if (i != items.length - 1) {
        widgets.add(
          Divider(
            color: isDark
                ? Color.fromRGBO(255, 255, 255, 0.5)
                : Color.fromRGBO(0, 0, 0, 0.5),
            height: 1,
          ),
        );
      }

      // If 'other' and selected, render TextField directly under that option
      if (key == 'other' && _selectedReason == 'other') {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: TextField(
              controller: _otherController,
              maxLines: 3,
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 12.sp,
                ),
                filled: true,
                fillColor: Color.fromRGBO(0, 0, 0, isDark ? 0.3 : 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
