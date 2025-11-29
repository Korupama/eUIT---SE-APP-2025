// filepath: d:/SourceCodes/SEAPP_eUIT/eUIT---SE-APP-2025/src/mobile/lib/screens/parking_monthly_screen.dart

import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class ParkingMonthlyScreen extends StatefulWidget {
  const ParkingMonthlyScreen({super.key});

  @override
  State<ParkingMonthlyScreen> createState() => _ParkingMonthlyScreenState();
}

class _ParkingMonthlyScreenState extends State<ParkingMonthlyScreen> {
  final TextEditingController _plateController = TextEditingController();
  int? _selectedMonths;
  bool _isSubmitting = false;

  final List<int> _options = [1, 2, 3, 6, 9, 12];

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final plate = _plateController.text.trim();
    if (_selectedMonths == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn số tháng')));
      return;
    }
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập biển số xe')));
      return;
    }

    setState(() => _isSubmitting = true);
    // Simulate a short delay to mimic submission
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    // Show success dialog
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).t('success')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số tháng: $_selectedMonths'),
            const SizedBox(height: 8),
            Text('Biển số: $plate'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(AppLocalizations.of(context).t('close'))),
        ],
      ),
    );

    // Optionally clear or keep values — leave as-is
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Đăng ký Vé tháng gửi xe máy',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Months selector label
                      Text(
                        'Chọn số tháng đăng ký giữ xe',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      // Card with month options
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Color.fromRGBO(255, 255, 255, 0.06) : Color.fromRGBO(255, 255, 255, 0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Color.fromRGBO(255, 255, 255, 0.08) : Color.fromRGBO(0, 0, 0, 0.8)),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _options.map((m) {
                            final selected = _selectedMonths == m;
                            return ChoiceChip(
                              label: Text('$m tháng', style: TextStyle(color: selected ? Colors.white : (isDark ? Colors.white : Colors.black87))),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedMonths = m),
                              selectedColor: AppTheme.bluePrimary,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(side: BorderSide(color: selected ? AppTheme.bluePrimary : (isDark ? Colors.white54 : Color.fromRGBO(0, 0, 0, 0.6))), borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // License plate label
                      Text('Biển số xe đăng ký', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _plateController,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Biển số xe Đăng ký',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                          filled: true,
                          fillColor: isDark ? Color.fromRGBO(0, 0, 0, 0.3) : Color.fromRGBO(0, 0, 0, 0.06),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text('Ví dụ: 47E1-123.45', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, fontStyle: FontStyle.italic)),

                      const SizedBox(height: 80), // space for fixed button
                    ],
                  ),

                  // Fixed submit button
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bluePrimary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 4),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
