// ignore_for_file: deprecated_member_use
// TODO: Refactor API calling due to changing of backend structure
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/animated_background.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class StudentConfirmationScreen extends StatefulWidget {
  const StudentConfirmationScreen({super.key});

  @override
  State<StudentConfirmationScreen> createState() => _StudentConfirmationScreenState();
}

// Small model to represent history items returned by the API
class ConfirmationHistoryItem {
  final int serialNumber;
  final String purpose;
  final String expiryDate;
  final String requestedAt;

  ConfirmationHistoryItem({required this.serialNumber, required this.purpose, required this.expiryDate, required this.requestedAt});

  factory ConfirmationHistoryItem.fromJson(Map<String, dynamic> json) {
    return ConfirmationHistoryItem(
      serialNumber: (json['serialNumber'] is int) ? json['serialNumber'] as int : int.tryParse(json['serialNumber']?.toString() ?? '') ?? 0,
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

  String _formatDate(DateTime dt) => '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

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
    return _selectedLang == 'en' ? (en[_selectedReason!] ?? '') : (vi[_selectedReason!] ?? '');
  }

  // Fetch confirmation history from API
  Future<void> _loadHistory() async {
    setState(() => _isHistoryLoading = true);
    final auth = AuthService();
    try {
      final token = await auth.getToken();
      final uri = auth.buildUri('/api/service/confirmation-letter/history');
      final headers = {'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
        final parsed = list.map((e) => ConfirmationHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
        if (mounted) setState(() => _history = parsed);
      } else if (res.statusCode == 401) {
        await auth.deleteToken();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yêu cầu đăng nhập lại')));
      } else {
        String message = 'Không thể tải lịch sử';
        try {
          final Map<String, dynamic> err = jsonDecode(res.body) as Map<String, dynamic>;
          if (err['message'] != null) message = err['message'].toString();
        } catch (_) {}
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi mạng, thử lại')));
    } finally {
      if (mounted) setState(() => _isHistoryLoading = false);
    }
  }

  Future<void> _submitConfirmation() async {
    // Validation
    final purpose = _getPurposeText();
    if (_selectedReason == null || purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn lý do xác nhận')));
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
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

      final body = jsonEncode({'purpose': purpose});
      final res = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 20));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> json = jsonDecode(res.body) as Map<String, dynamic>;
        final serial = json['serialNumber']?.toString() ?? '—';
        final expiry = json['expiryDate']?.toString() ?? '';
        final requestDate = _formatDate(DateTime.now());

        // Show success dialog with details
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context).t('student_confirmation_success_title')),
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
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(AppLocalizations.of(context).t('close'))),
            ],
          ),
        );

        // After successful submit, refresh history
        await _loadHistory();
      } else if (res.statusCode == 401) {
        // unauthorized
        await auth.deleteToken();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yêu cầu đăng nhập lại')));
      } else {
        String message = 'Đăng ký thất bại';
        try {
          final Map<String, dynamic> err = jsonDecode(res.body) as Map<String, dynamic>;
          if (err['message'] != null) message = err['message'].toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi mạng, thử lại')));
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
            fontSize: 18,
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
        backgroundColor: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.92),
        elevation: 0,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).t('student_confirmation_history_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87), onPressed: () => Navigator.of(context).maybePop()),
                  ],
                ),
              ),

              Expanded(
                child: _isHistoryLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_history.isEmpty
                        ? Center(child: Text(AppLocalizations.of(context).t('no_history')))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _history.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, idx) {
                              final item = _history[idx];
                              return ListTile(
                                title: Text('Số seri: ${item.serialNumber}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Lý do: ${item.purpose}'),
                                    const SizedBox(height: 4),
                                    Text('Yêu cầu: ${item.requestedAt}'),
                                  ],
                                ),
                                trailing: Text(item.expiryDate),
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
          Positioned.fill(
            child: AnimatedBackground(isDark: isDark),
          ),

          // Safe area for content; container has min height and submit button is fixed at bottom
          SafeArea(
            child: Padding(
              // add extra bottom padding so the fixed button doesn't cover content
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Label for language selection (localized)
                      Text(
                        AppLocalizations.of(context).t('language'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Language chips row
                      Row(
                        children: [
                          _buildLanguageChip(context, 'vi'),
                          const SizedBox(width: 12),
                          _buildLanguageChip(context, 'en'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        AppLocalizations.of(context).t('student_confirmation_reason_title'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Glassmorphism container with radios — min height provided
                      Flexible(
                        fit: FlexFit.loose,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 300),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Color.fromRGBO(255, 255, 255, 0.1)
                                  : Color.fromRGBO(255, 255, 255, 0.8),
                              borderRadius: BorderRadius.circular(12),
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
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
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
                      const SizedBox(height: 12),

                      // Small explanatory notes directly under the reasons card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).t('student_confirmation_other_section_title'),
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context).t('student_confirmation_other_section_instruction'),
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).t('student_confirmation_other_section_example'),
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).t('student_confirmation_other_section_format_warning'),
                              style: TextStyle(color: isDark ? Colors.red[400] : Colors.limeAccent, fontSize: 15, fontWeight: FontWeight.w600),
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
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.bluePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _isSubmitting ? null : _submitConfirmation,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                            : Text(
                                AppLocalizations.of(context).t('student_confirmation_submit'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                      ),
                    ),
                  ),

                  // Localized review warning (separate, above the submit button)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 68, // place above the fixed button (button height 56 + spacing)
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        AppLocalizations.of(context).t('student_confirmation_review_warning'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
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
    final label = AppLocalizations.of(context).t(code == 'vi' ? 'vietnamese' : 'english');
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : isDark ? Colors.white : Colors.black87)),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedLang = code),
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.bluePrimary,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isSelected ? AppTheme.bluePrimary : isDark ? Colors.white54 : Color.fromRGBO(0, 0, 0, 0.8)),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      final hint = _selectedLang == 'en' ? en['other_hint']! : vi['other_hint']!;

      widgets.add(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          leading: Radio<String>(
            value: key,
            groupValue: _selectedReason,
            onChanged: (v) => setState(() {
              _selectedReason = v;
              if (v != 'other') _otherController.clear();
            }),
            fillColor: MaterialStateProperty.all(AppTheme.bluePrimary),
          ),
          title: Text(
            label,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          onTap: () => setState(() {
            _selectedReason = key;
            if (key != 'other') _otherController.clear();
          }),
        ),
      );

      if (i != items.length - 1) {
        widgets.add(Divider(color: isDark ? Color.fromRGBO(255, 255, 255, 0.5) : Color.fromRGBO(0, 0, 0, 0.5), height: 1));
      }

      // If 'other' and selected, render TextField directly under that option
      if (key == 'other' && _selectedReason == 'other') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _otherController,
              maxLines: 3,
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                filled: true,
                fillColor: Color.fromRGBO(0, 0, 0, isDark ? 0.3 : 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
