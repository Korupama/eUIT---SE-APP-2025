import 'package:flutter/material.dart';

import '../widgets/animated_background.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';

class TranscriptRegistrationScreen extends StatefulWidget {
  const TranscriptRegistrationScreen({super.key});

  @override
  State<TranscriptRegistrationScreen> createState() => _TranscriptRegistrationScreenState();
}

class _TranscriptRegistrationScreenState extends State<TranscriptRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Use nullable types so we can show hint (initialValue == null) instead of an empty string
  String? _transcriptType;
  String? _language;
  int _quantity = 1;

  Widget _requiredLabel(String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _register() {
    final loc = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    // For now simulate registration
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.t('register')),
        content: Text(loc.t('transcript_registered_success')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(loc.t('close'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> types = [
      loc.t('transcript_type_option_cumulative'),
      loc.t('transcript_type_option_semester'),
      loc.t('transcript_type_option_schoolyear'),
      loc.t('transcript_type_option_completion_certificate'),
    ];

    final List<String> languages = [
      loc.t('vietnamese'),
      loc.t('english'),
    ];

    final List<int> quantities = [1, 2, 3, 5];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(loc.t('transcript_registration_title')),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    loc.t('transcript_registration_title'),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.92),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color.fromRGBO(255,255,255,0.08) : const Color.fromRGBO(0,0,0,0.08)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _requiredLabel(loc.t('transcript_type_label'), isDark),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _transcriptType,
                            isExpanded: true,
                            isDense: true,
                            iconSize: 20,
                            hint: Text(loc.t('transcript_type_placeholder'), overflow: TextOverflow.ellipsis),
                            items: types.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) => setState(() => _transcriptType = v),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? const Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? loc.t('transcript_type_required') : null,
                          ),

                          const SizedBox(height: 12),

                          Text(loc.t('transcript_language_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _language,
                            isExpanded: true,
                            isDense: true,
                            iconSize: 20,
                            hint: Text(loc.t('choose'), overflow: TextOverflow.ellipsis),
                            items: languages.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) => setState(() => _language = v),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? const Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? loc.t('required') : null,
                          ),

                          const SizedBox(height: 12),

                          Text(loc.t('transcript_quantity_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _quantity,
                            isExpanded: true,
                            isDense: true,
                            iconSize: 20,
                            items: quantities.map((q) => DropdownMenuItem(value: q, child: Text(q.toString(), overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) => setState(() => _quantity = v ?? 1),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? const Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.bluePrimary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(loc.t('register'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
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
}
