import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../services/auth_service.dart';

class StudentConfirmationScreen extends StatefulWidget {
  const StudentConfirmationScreen({super.key});

  @override
  State<StudentConfirmationScreen> createState() => _StudentConfirmationScreenState();
}

class _StudentConfirmationScreenState extends State<StudentConfirmationScreen> {
  String _certificateLanguage = 'vi';
  int _selectedReason = 0; // 0..4
  final TextEditingController _otherReasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDark
        ? const Color.fromRGBO(30, 41, 59, 0.95)
        : Colors.white;
    final Color strokeColor = isDark
        ? const Color.fromRGBO(255, 255, 255, 0.12)
        : const Color.fromRGBO(0, 0, 0, 0.06);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: false,
                    titleSpacing: 20,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.t('student_confirmation_title'),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.description_outlined,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ],
                    ),
                    iconTheme: IconThemeData(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language selection
                Text(
                  loc.t('language'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLanguageChip(
                      context: context,
                      isDark: isDark,
                      label: loc.t('vietnamese'),
                      value: 'vi',
                    ),
                    const SizedBox(width: 8),
                    _buildLanguageChip(
                      context: context,
                      isDark: isDark,
                      label: loc.t('english'),
                      value: 'en',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reason section
                Text(
                  loc.t('student_confirmation_reason_title'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: strokeColor, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildReasonTile(
                            context: context,
                            isDark: isDark,
                            value: 0,
                            label: _certificateLanguage == 'vi'
                                ? loc.t('student_confirmation_reason_military_defer')
                                : 'Postponement of military service',
                          ),
                          _divider(strokeColor),
                          _buildReasonTile(
                            context: context,
                            isDark: isDark,
                            value: 1,
                            label: _certificateLanguage == 'vi'
                                ? loc.t('student_confirmation_reason_dorm_extend')
                                : 'Dormitory stay extension request',
                          ),
                          _divider(strokeColor),
                          _buildReasonTile(
                            context: context,
                            isDark: isDark,
                            value: 2,
                            label: _certificateLanguage == 'vi'
                                ? loc.t('student_confirmation_reason_tax_reduction')
                                : 'Family personal income tax reduction documents',
                          ),
                          _divider(strokeColor),
                          _buildReasonTile(
                            context: context,
                            isDark: isDark,
                            value: 3,
                            label: _certificateLanguage == 'vi'
                                ? loc.t('student_confirmation_reason_military_education')
                                : 'Registration for National Defense Education',
                          ),
                          _divider(strokeColor),
                          _buildReasonTile(
                            context: context,
                            isDark: isDark,
                            value: 4,
                            label: _certificateLanguage == 'vi'
                                ? loc.t('student_confirmation_reason_other')
                                : 'Other',
                          ),
                          if (_selectedReason == 4) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: TextField(
                                controller: _otherReasonController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: _certificateLanguage == 'vi'
                                      ? loc.t('student_confirmation_reason_other_hint')
                                      : 'Enter other reason...',
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color.fromRGBO(15, 23, 42, 0.9)
                                      : const Color.fromRGBO(248, 250, 252, 1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: strokeColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: strokeColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.bluePrimary, width: 1.5),
                                  ),
                                ),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ] else
                            const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bluePrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _onSubmit(context, loc, isDark),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            loc.t('student_confirmation_submit'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChip({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String value,
  }) {
    final bool isSelected = _certificateLanguage == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          setState(() {
            _certificateLanguage = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? AppTheme.bluePrimary
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            color: isSelected
                ? AppTheme.bluePrimary.withOpacity(0.12)
                : Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (isDark ? Colors.white : AppTheme.bluePrimary)
                  : (isDark ? Colors.white : Colors.black87),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTile({
    required BuildContext context,
    required bool isDark,
    required int value,
    required String label,
  }) {
    return RadioListTile<int>(
      value: value,
      groupValue: _selectedReason,
      onChanged: (val) {
        if (val == null) return;
        setState(() {
          _selectedReason = val;
        });
      },
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
      activeColor: AppTheme.bluePrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _divider(Color strokeColor) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: strokeColor,
    );
  }

  Future<void> _onSubmit(
      BuildContext context, AppLocalizations loc, bool isDark) async {
    if (_selectedReason == 4 && _otherReasonController.text.trim().isEmpty) {
      final snackBar = SnackBar(
        content: Text(loc.t('student_confirmation_other_required')),
        backgroundColor: AppTheme.error,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String purpose;
    switch (_selectedReason) {
      case 0:
        purpose = _certificateLanguage == 'vi'
            ? 'Tạm hoãn nghĩa vụ quân sự'
            : 'Postponement of military service';
        break;
      case 1:
        purpose = _certificateLanguage == 'vi'
            ? 'Xin gia hạn ở Ký túc xá'
            : 'Dormitory stay extension request';
        break;
      case 2:
        purpose = _certificateLanguage == 'vi'
            ? 'Bổ sung hồ sơ giảm thuế thu nhập cá nhân cho gia đình'
            : 'Family personal income tax reduction documents';
        break;
      case 3:
        purpose = _certificateLanguage == 'vi'
            ? 'Đăng ký học Giáo dục Quốc phòng'
            : 'Registration for National Defense Education';
        break;
      case 4:
        purpose = _otherReasonController.text.trim();
        break;
      default:
        purpose = '';
    }

    try {
      final result = await _requestConfirmationLetter(purpose);

      setState(() {
        _isLoading = false;
      });

      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(loc.t('student_confirmation_success_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${loc.t('student_confirmation_serial_number')}: ${result.serialNumber}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${loc.t('student_confirmation_expiry_date')}: ${result.expiryDate}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(loc.t('close')),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('network_error')),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<_ConfirmationLetterResponse> _requestConfirmationLetter(
      String purpose) async {
    final service = AuthService();
    final uri = service.buildUri('/api/service/confirmation-letter');

    final token = await service.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final client = http.Client();
    http.Response res;
    var clientClosed = false;

    try {
      res = await client
          .get(
        uri.replace(queryParameters: {'purpose': purpose}),
        headers: headers,
      )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      try {
        client.close();
      } catch (_) {}
      clientClosed = true;
      rethrow;
    } finally {
      if (!clientClosed) {
        try {
          client.close();
        } catch (_) {}
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final Map<String, dynamic> body =
            jsonDecode(res.body) as Map<String, dynamic>;
        return _ConfirmationLetterResponse(
          serialNumber: body['serialNumber'] as int? ?? 0,
          expiryDate: body['expiryDate'] as String? ?? '',
        );
      } catch (_) {
        throw Exception('invalid_response');
      }
    }

    throw Exception('network_error');
  }
}

class _ConfirmationLetterResponse {
  final int serialNumber;
  final String expiryDate;

  _ConfirmationLetterResponse({
    required this.serialNumber,
    required this.expiryDate,
  });
}
