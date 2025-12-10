import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../widgets/animated_background.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class IntroductionLetterScreen extends StatefulWidget {
  const IntroductionLetterScreen({super.key});

  @override
  State<IntroductionLetterScreen> createState() => _IntroductionLetterScreenState();
}

class _IntroductionLetterScreenState extends State<IntroductionLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _destinationController.dispose();
    _contactController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      // Format as dd/MM/yyyy
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _submit() {
    final loc = AppLocalizations.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      // For now just show a dialog/confirmation. Integrate with API later.
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(loc.t('submission_received')),
          content: Text(loc.t('submission_received_message')),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.t('close'))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Text(
          loc.t('introduction_letter'),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen animated background
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Stack(
                children: [
                  // Scrollable content
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Image preview with card background
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Color.fromRGBO(255, 255, 255, 0.04) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Color.fromRGBO(255, 255, 255, 0.06) : Color.fromRGBO(0, 0, 0, 0.08)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                'assets/images/introduction_letter.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 220,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Form card container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Color.fromRGBO(255, 255, 255, 0.04) : Color.fromRGBO(255, 255, 255, 0.92),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Color.fromRGBO(255, 255, 255, 0.06) : Color.fromRGBO(0, 0, 0, 0.08)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Recipient
                                TextFormField(
                                  controller: _recipientController,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? loc.t('required') : null,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: null,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: loc.t('intro_recipient_label'),
                                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                    filled: true,
                                    fillColor: isDark ? Color.fromRGBO(0, 0, 0, 0.28) : Color.fromRGBO(0, 0, 0, 0.06),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 2. Destination
                                TextFormField(
                                  controller: _destinationController,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? loc.t('required') : null,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: null,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: loc.t('intro_destination_label'),
                                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                    filled: true,
                                    fillColor: isDark ? Color.fromRGBO(0, 0, 0, 0.28) : Color.fromRGBO(0, 0, 0, 0.06),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 3. Contact content (multi-line, auto-expand)
                                TextFormField(
                                  controller: _contactController,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 3,
                                  maxLines: null,
                                  validator: (v) => (v == null || v.trim().isEmpty) ? loc.t('required') : null,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  decoration: InputDecoration(
                                    labelText: loc.t('intro_contact_label'),
                                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                    filled: true,
                                    fillColor: isDark ? Color.fromRGBO(0, 0, 0, 0.28) : Color.fromRGBO(0, 0, 0, 0.06),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 4 & 5: From date and To date on same row
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _fromDateController,
                                        readOnly: true,
                                        validator: (v) => (v == null || v.trim().isEmpty) ? loc.t('required') : null,
                                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                        decoration: InputDecoration(
                                          labelText: loc.t('intro_from_label'),
                                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                          filled: true,
                                          fillColor: isDark ? Color.fromRGBO(0, 0, 0, 0.28) : Color.fromRGBO(0, 0, 0, 0.06),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        ),
                                        onTap: () => _pickDate(_fromDateController),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _toDateController,
                                        readOnly: true,
                                        validator: (v) => (v == null || v.trim().isEmpty) ? loc.t('required') : null,
                                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                        decoration: InputDecoration(
                                          labelText: loc.t('intro_to_label'),
                                          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                          filled: true,
                                          fillColor: isDark ? Color.fromRGBO(0, 0, 0, 0.28) : Color.fromRGBO(0, 0, 0, 0.06),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        ),
                                        onTap: () => _pickDate(_toDateController),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 80), // space for fixed button
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // NOTE: submit button moved out to top-level Stack so it is fixed to screen bottom

                ],
              ),
            ),
          ),

          // Fixed submit button at bottom of screen (outside scrollable area)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bluePrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
                onPressed: _submit,
                child: Text(loc.t('submit_introduction_request'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
