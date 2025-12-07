import 'package:flutter/material.dart';
import '../../widgets/animated_background.dart';
import '../../utils/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/grades_detail.dart';

class SubjectDetailScreen extends StatelessWidget {
  final SubjectDetail subject;

  const SubjectDetailScreen({super.key, required this.subject});

  String _formatScore(double? v) {
    if (v == null) return '-';
    return v.toStringAsFixed(2);
  }

  String _formatWeight(double? v) {
    if (v == null) return '-';
    return v.toStringAsFixed(0) + '%';
  }

  String _gradeLetter(double? score) {
    if (score == null) return '-';
    final s = score;
    if (s >= 9.0) return 'A+';
    if (s >= 8.0) return 'A';
    if (s >= 7.0) return 'B+';
    if (s >= 6.0) return 'B';
    if (s >= 5.0) return 'C';
    if (s >= 4.0) return 'D+';
    if (s >= 3.0) return 'D';
    return 'F';
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Color(0xFFFFD700);
      case 'A':
        return Color(0xFF10B981);
      case 'B+':
      case 'B':
        return Color(0xFF3B82F6);
      case 'C+':
      case 'C':
        return Color(0xFFF59E0B);
      case 'D+':
      case 'D':
        return Color(0xFFEF4444);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradeLetter = _gradeLetter(subject.diemTongKet);
    final gradeColor = _gradeColor(gradeLetter);
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double navBarHeight = AppTheme.bottomNavBaseHeight + bottomInset;

    // card colors (glass style)
    final cardColor = isDark ? Color.fromRGBO(255, 255, 255, 0.06) : Color.fromRGBO(255, 255, 255, 0.95);
    final strokeColor = isDark ? Color.fromRGBO(255, 255, 255, 0.10) : Color.fromRGBO(0, 0, 0, 0.05);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(subject.tenMonHoc, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        leading: BackButton(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: IgnorePointer(child: AnimatedBackground(isDark: isDark))),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navBarHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: strokeColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.tenMonHoc,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(subject.maMonHoc, style: TextStyle(color: isDark ? Colors.white.withAlpha((0.7*255).round()) : Colors.black54)),
                            SizedBox(width: 12),
                            Text('${subject.soTinChi ?? 0} ${loc.t('credits')}', style: TextStyle(color: isDark ? Colors.white.withAlpha((0.7*255).round()) : Colors.black54)),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                // Convert Color channels to 0..255 safely (avoid deprecated .red/.green/.blue)
                                color: Color.fromARGB(
                                  (0.15 * 255).round(),
                                  ((gradeColor.r * 255.0).round()).clamp(0, 255),
                                  ((gradeColor.g * 255.0).round()).clamp(0, 255),
                                  ((gradeColor.b * 255.0).round()).clamp(0, 255),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                gradeLetter,
                                style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: strokeColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.t('weights_scores'), style: TextStyle(color: isDark ? Colors.white.withAlpha((0.8*255).round()) : Colors.black87, fontWeight: FontWeight.w600)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow(loc.t('qt_weight_label'), _formatWeight(subject.trongSoQuaTrinh), isDark: isDark)),
                            SizedBox(width: 8),
                            Expanded(child: _buildInfoRow(loc.t('qt_score_label'), _formatScore(subject.diemQuaTrinh), isDark: isDark)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow(loc.t('gk_weight_label'), _formatWeight(subject.trongSoGiuaKi), isDark: isDark)),
                            SizedBox(width: 8),
                            Expanded(child: _buildInfoRow(loc.t('gk_score_label'), _formatScore(subject.diemGiuaKi), isDark: isDark)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow(loc.t('th_weight_label'), _formatWeight(subject.trongSoThucHanh), isDark: isDark)),
                            SizedBox(width: 8),
                            Expanded(child: _buildInfoRow(loc.t('th_score_label'), _formatScore(subject.diemThucHanh), isDark: isDark)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow(loc.t('ck_weight_label'), _formatWeight(subject.trongSoCuoiKi), isDark: isDark)),
                            SizedBox(width: 8),
                            Expanded(child: _buildInfoRow(loc.t('ck_score_label'), _formatScore(subject.diemCuoiKi), isDark: isDark)),
                          ],
                        ),

                        SizedBox(height: 12),
                        Divider(color: isDark ? Colors.white.withAlpha((0.06*255).round()) : Colors.black.withAlpha((0.06*255).round())),
                        SizedBox(height: 12),

                        Text(loc.t('final_score'), style: TextStyle(color: isDark ? Colors.white.withAlpha((0.6*255).round()) : Colors.black54)),
                        SizedBox(height: 8),
                        Text(
                          subject.diemTongKet == null ? '-' : subject.diemTongKet!.toStringAsFixed(2),
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
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

  Widget _buildInfoRow(String label, String value, {bool isDark = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.white.withAlpha((0.7*255).round()) : Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
