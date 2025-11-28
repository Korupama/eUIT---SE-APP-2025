// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../widgets/animated_background.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';

class StudentConfirmationScreen extends StatefulWidget {
  const StudentConfirmationScreen({super.key});

  @override
  State<StudentConfirmationScreen> createState() => _StudentConfirmationScreenState();
}

class _StudentConfirmationScreenState extends State<StudentConfirmationScreen> {
  // Selected language chip (UI only)
  String _selectedLang = 'vi';

  // Selected reason value
  String? _selectedReason;
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).t('student_confirmation_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            onPressed: () {
              // Placeholder action for the right-side icon (matches ServicesScreen tile)
            },
          ),
        ],
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
                          color: isDark ? Colors.white : Colors.black87,
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
                                  : Color.fromRGBO(255, 255, 255, 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Color.fromRGBO(255, 255, 255, 0.10)
                                    : Color.fromRGBO(0, 0, 0, 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Color.fromRGBO(0, 0, 0, 0.1)
                                      : Color.fromRGBO(0, 0, 0, 0.1),
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
                        onPressed: () {
                          // UI only: no real submit logic as requested
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(AppLocalizations.of(context).t('student_confirmation_success_title')),
                              content: Text(AppLocalizations.of(context).t('under_development')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(AppLocalizations.of(context).t('close')),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context).t('student_confirmation_submit'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
    final isSelected = _selectedLang == code;
    final label = AppLocalizations.of(context).t(code == 'vi' ? 'vietnamese' : 'english');
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedLang = code),
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.bluePrimary,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isSelected ? AppTheme.bluePrimary : Color.fromRGBO(255, 255, 255, 0.14)),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  List<Widget> _buildReasonList(BuildContext context, bool isDark) {
    final t = AppLocalizations.of(context).t;

    final items = [
      {'value': 'military', 'key': 'student_confirmation_reason_military_defer'},
      {'value': 'dorm', 'key': 'student_confirmation_reason_dorm_extend'},
      {'value': 'tax', 'key': 'student_confirmation_reason_tax_reduction'},
      {'value': 'education', 'key': 'student_confirmation_reason_military_education'},
      {'value': 'other', 'key': 'student_confirmation_reason_other'},
    ];

    final List<Widget> widgets = [];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          leading: Radio<String>(
            value: item['value']!,
            groupValue: _selectedReason,
            onChanged: (v) => setState(() {
              _selectedReason = v;
              if (v != 'other') _otherController.clear();
            }),
            fillColor: MaterialStateProperty.all(AppTheme.bluePrimary),
          ),
          title: Text(
            t(item['key']!),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          onTap: () => setState(() {
            _selectedReason = item['value'];
            if (item['value'] != 'other') _otherController.clear();
          }),
        ),
      );

      if (i != items.length - 1) {
        widgets.add(Divider(color: Color.fromRGBO(255, 255, 255, isDark ? 0.2 : 0.8), height: 1));
      }

      // If 'other' and selected, render TextField directly under that option
      if (item['value'] == 'other' && _selectedReason == 'other') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _otherController,
              maxLines: 3,
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: t('student_confirmation_reason_other_hint'),
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
