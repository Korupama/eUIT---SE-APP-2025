import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Helper to render a label with a red '*' prefix to indicate required fields
  Widget _requiredLabel(String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
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

  // Form fields
  // Default to empty string so the dropdown shows the placeholder item when the screen opens
  String _certificateType = '';
  // Scholarship checkbox state (shown for TOEFL iBT, IELTS, and Japanese certificates)
  bool _applyUitGlobalScholarship = false;
  // TOEIC specific controllers
  final TextEditingController _toeicListeningController = TextEditingController();
  final TextEditingController _toeicReadingController = TextEditingController();
  // TOEIC speaking/writing + REG/test place
  final TextEditingController _toeicSpeakingController = TextEditingController();
  final TextEditingController _toeicWritingController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _testPlaceController = TextEditingController();
  // JLPT level for Japanese certificates (N1 - N5)
  String _jlptLevel = '';
  // IELTS TRF number
  final TextEditingController _trfNumberController = TextEditingController();
  DateTime? _dateOfBirth;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  // BCU-EPT specific controllers
  final TextEditingController _bcuListeningController = TextEditingController();
  final TextEditingController _bcuReadingController = TextEditingController();
  final TextEditingController _bcuSpeakingController = TextEditingController();
  final TextEditingController _bcuWritingController = TextEditingController();
  final TextEditingController _totalScoreController = TextEditingController();
  DateTime? _examDate;
  final TextEditingController _examDateController = TextEditingController();

  // File
  PlatformFile? _selectedFile;

  // TODO: Add API to get newest link for UIT Global scholarship regulation
  // For now use a placeholder URL; the API should provide the current regulation link.
  static final Uri _uitGlobalScholarshipUri = Uri.parse('https://ctsv.uit.edu.vn/bai-viet/thong-bao-trien-khai-hoc-bong-uit-global-tu-hoc-ky-1-nam-hoc-2025-2026');

  Future<void> _openScholarshipReg() async {
    try {
      if (!await launchUrl(_uitGlobalScholarshipUri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('link_open_failed'))));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).t('link_open_failed'))));
    }
  }

  // Example certificate list (can be extended later)
  final List<String> _certificateOptions = [
    'Chứng chỉ TOEIC (Nghe-Đọc)',
    'Chứng chỉ TOEIC (Nói-Viết)',
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
    _toeicListeningController.dispose();
    _toeicReadingController.dispose();
    _toeicSpeakingController.dispose();
    _toeicWritingController.dispose();
    _regNumberController.dispose();
    _testPlaceController.dispose();
    _trfNumberController.dispose();
    _examDateController.dispose();
    // dispose BCU controllers
    _bcuListeningController.dispose();
    _bcuReadingController.dispose();
    _bcuSpeakingController.dispose();
    _bcuWritingController.dispose();
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
                          // Required: add red '*' before label
                          _requiredLabel(loc.t('certificate_type_label'), isDark),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _certificateType,
                            // Insert a placeholder item as the first option so the dropdown shows "- Chọn loại chứng chỉ -" by default
                            items: [
                              DropdownMenuItem(value: '', child: Text(loc.t('choose_certificate_placeholder'))),
                              ..._certificateOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            ],
                            onChanged: (v) => setState(() => _certificateType = v ?? ''),
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
                          // Required: add red '*' before label
                          _requiredLabel(loc.t('date_of_birth'), isDark),
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
                          // Required: add red '*' before label
                          _requiredLabel(loc.t('id_number_label'), isDark),
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
                          // BCU-EPT score fields (Listening, Reading, Speaking, Writing)
                          if (_certificateType == 'Chứng chỉ BCU-EPT') ...[
                            Text(loc.t('bcu_listening_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bcuListeningController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('bcu_listening_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null; // optional
                                final parsed = double.tryParse(v.replaceAll(',', '.'));
                                return parsed == null ? loc.t('invalid_number') : null;
                              },
                            ),
                            const SizedBox(height: 12),

                            Text(loc.t('bcu_reading_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bcuReadingController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('bcu_reading_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final parsed = double.tryParse(v.replaceAll(',', '.'));
                                return parsed == null ? loc.t('invalid_number') : null;
                              },
                            ),
                            const SizedBox(height: 12),

                            Text(loc.t('bcu_speaking_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bcuSpeakingController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('bcu_speaking_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final parsed = double.tryParse(v.replaceAll(',', '.'));
                                return parsed == null ? loc.t('invalid_number') : null;
                              },
                            ),
                            const SizedBox(height: 12),

                            Text(loc.t('bcu_writing_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _bcuWritingController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('bcu_writing_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final parsed = double.tryParse(v.replaceAll(',', '.'));
                                return parsed == null ? loc.t('invalid_number') : null;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Extra fields depending on selected certificate
                          // If TOEIC (Nói-Viết): show REG number + Speaking + Writing
                          if (_certificateType == 'Chứng chỉ TOEIC (Nói-Viết)') ...[
                            Text(loc.t('reg_number_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _regNumberController,
                              decoration: InputDecoration(
                                hintText: loc.t('reg_number_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(loc.t('toeic_speaking_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _toeicSpeakingController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('toeic_speaking_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                return double.tryParse(v.replaceAll(',', '.')) == null ? 'Không hợp lệ' : null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(loc.t('toeic_writing_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _toeicWritingController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('toeic_writing_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                return double.tryParse(v.replaceAll(',', '.')) == null ? 'Không hợp lệ' : null;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],

                          // If selected certificate is Japanese, show test place
                          if (_certificateType == 'Tiếng Nhật') ...[
                            Text(loc.t('test_place_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _testPlaceController,
                              decoration: InputDecoration(
                                hintText: loc.t('test_place_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // JLPT level selection (N1 - N5)
                            Text(loc.t('jlpt_level_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _jlptLevel,
                              items: [
                                DropdownMenuItem(value: '', child: Text(loc.t('jlpt_level_placeholder'))),
                                DropdownMenuItem(value: 'N1', child: Text('N1')),
                                DropdownMenuItem(value: 'N2', child: Text('N2')),
                                DropdownMenuItem(value: 'N3', child: Text('N3')),
                                DropdownMenuItem(value: 'N4', child: Text('N4')),
                                DropdownMenuItem(value: 'N5', child: Text('N5')),
                              ],
                              onChanged: (v) => setState(() => _jlptLevel = v ?? ''),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // TOEIC listening/reading fields (only for "Chứng chỉ TOEIC (Nghe-Đọc)")
                          if (_certificateType == 'Chứng chỉ TOEIC (Nghe-Đọc)') ...[
                            Text(loc.t('toeic_listening_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _toeicListeningController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('toeic_listening_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null; // optional
                                final parsed = double.tryParse(v.replaceAll(',', '.'));
                                return parsed == null ? 'Không hợp lệ' : null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(loc.t('toeic_reading_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _toeicReadingController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: loc.t('toeic_reading_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null; // optional
                                final parsed = double.tryParse(v.replaceAll(',', '.'));
                                return parsed == null ? 'Không hợp lệ' : null;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Default extra fields: total score and exam date
                          // For IELTS: show TRF Number before total score
                          if (_certificateType == 'Chứng chỉ IELTS') ...[
                            Text(loc.t('trf_number_label'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _trfNumberController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: loc.t('trf_number_hint'),
                                filled: true,
                                fillColor: isDark ? Color.fromRGBO(0,0,0,0.3) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // If the certificate is GDQP&AN we do NOT show total score and exam date
                          if (_certificateType != 'Chứng chỉ GDQP&AN' && _certificateType != 'Bằng TN THPT' && _certificateType != 'Giấy Khai sinh' && _certificateType != 'Bằng đại học ngoại ngữ' && _certificateType != 'Bằng cao đẳng') ...[
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
                          ],

                          // File picker
                          // File picker (required)
                          _requiredLabel(loc.t('upload_file'), isDark),
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

                          // Conditional scholarship regulation checkbox
                          if (_certificateType == 'Chứng chỉ TOEFL iBT' || _certificateType == 'Chứng chỉ IELTS' || _certificateType == 'Tiếng Nhật') ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _applyUitGlobalScholarship,
                                  onChanged: (v) => setState(() => _applyUitGlobalScholarship = v ?? false),
                                  activeColor: AppTheme.bluePrimary,
                                ),
                                Expanded(
                                  child: Text(
                                    loc.t('apply_uit_global_scholarship'),
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _openScholarshipReg,
                                  child: Text(
                                    loc.t('view_regulations'),
                                    style: TextStyle(color: AppTheme.bluePrimary, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],

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
