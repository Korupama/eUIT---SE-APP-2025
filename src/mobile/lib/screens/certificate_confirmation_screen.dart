import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../widgets/animated_background.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';

class CertificateConfirmationScreen extends StatefulWidget {
  const CertificateConfirmationScreen({super.key});

  @override
  State<CertificateConfirmationScreen> createState() => _CertificateConfirmationScreenState();
}

class _CertificateConfirmationScreenState extends State<CertificateConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _certificateType;
  DateTime? _dateOfBirth;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _totalScoreController = TextEditingController();
  DateTime? _examDate;
  final TextEditingController _examDateController = TextEditingController();

  // File
  PlatformFile? _selectedFile;

  // Example certificate list (can be extended later)
  final List<String> _certificateOptions = [
    'Chứng chỉ TOEIC (Nghe-Đọc)',
    'Chứng chỉ TOEIC (Nói- Viết)',
    'Chứng chỉ TOEFL iBT',
    'Chứng chỉ IELTS',
    'Chứng chỉ PTE Academic',
    'Chứng chỉ Cambridge',
    'Chứng chỉ VNU-EPT',
    'Tiếng Nhật',
    'Tiếng Pháp',
    'VPET',
    'Chứng chỉ GDQP&AN',
    'Bằng TN THPT',
    'Giấy Khai sinh',
    'VSTEP - Đánh giá năng lực',
    'Bằng đại học ngoại ngữ',
    'Bằng cao đẳng',
    'Chứng chỉ BCU-EPT',
  ];

  @override
  void dispose() {
    _dobController.dispose();
    _idNumberController.dispose();
    _totalScoreController.dispose();
    _examDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, TextEditingController controller, DateTime? initial, void Function(DateTime) onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      onPicked(picked);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'gif', 'jpeg'],
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('file_pick_error'))));
    }
  }

  void _submit() {
    final loc = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.t('file_required'))));
      return;
    }

    // Validate extension
    final ext = (_selectedFile!.extension ?? '').toLowerCase();
    if (!['jpg', 'png', 'gif', 'jpeg'].contains(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.t('invalid_file_type'))));
      return;
    }

    // For now, we only simulate saving. Integrate with API later.
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.t('save')),
        content: Text(loc.t('saved_success')),
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(loc.t('certificate_registration_title')),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Stack(
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
                    loc.t('certificate_registration_title'),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  // Card container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Color.fromRGBO(30, 41, 59, 0.62) : Color.fromRGBO(255, 255, 255, 0.92),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Color.fromRGBO(255,255,255,0.08) : Color.fromRGBO(0,0,0,0.08)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Certificate type
                          Text(loc.t('certificate_type_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _certificateType,
                            items: _certificateOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) => setState(() => _certificateType = v),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? loc.t('certificate_type_required') : null,
                          ),

                          const SizedBox(height: 12),

                          // Date of birth
                          Text(loc.t('date_of_birth'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: () => _pickDate(context, _dobController, _dateOfBirth, (d) => setState(() => _dateOfBirth = d)),
                            decoration: InputDecoration(
                              hintText: loc.t('select_date'),
                              filled: true,
                              fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? loc.t('date_of_birth_required') : null,
                          ),

                          const SizedBox(height: 12),

                          // ID number
                          Text(loc.t('id_number_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _idNumberController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: loc.t('id_number_hint'),
                              filled: true,
                              fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? loc.t('id_number_required') : null,
                          ),

                          const SizedBox(height: 12),

                          // Default extra fields: total score and exam date
                          Text(loc.t('total_score'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _totalScoreController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: loc.t('total_score_hint'),
                              filled: true,
                              fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(loc.t('exam_date'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _examDateController,
                            readOnly: true,
                            onTap: () => _pickDate(context, _examDateController, _examDate, (d) => setState(() => _examDate = d)),
                            decoration: InputDecoration(
                              hintText: loc.t('select_date'),
                              filled: true,
                              fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // File picker
                          Text(loc.t('upload_file'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.attach_file),
                                label: Text(loc.t('choose_file')),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bluePrimary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedFile?.name ?? loc.t('no_file_selected'),
                                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.bluePrimary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(loc.t('save'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
