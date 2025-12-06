import 'package:flutter/material.dart';
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradeLetter = _gradeLetter(subject.diemTongKet);
    final gradeColor = _gradeColor(gradeLetter);

    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E293B),
        title: Text(subject.tenMonHoc),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.tenMonHoc,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(subject.maMonHoc, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      SizedBox(width: 12),
                      Text('${subject.soTinChi ?? 0} tín chỉ', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.15),
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

            // Scores breakdown grid
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trọng số / Điểm', style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow('QT weight', _formatWeight(subject.trongSoQuaTrinh))),
                      SizedBox(width: 8),
                      Expanded(child: _buildInfoRow('QT score', _formatScore(subject.diemQuaTrinh))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow('GK weight', _formatWeight(subject.trongSoGiuaKi))),
                      SizedBox(width: 8),
                      Expanded(child: _buildInfoRow('GK score', _formatScore(subject.diemGiuaKi))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow('TH weight', _formatWeight(subject.trongSoThucHanh))),
                      SizedBox(width: 8),
                      Expanded(child: _buildInfoRow('TH score', _formatScore(subject.diemThucHanh))),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow('CK weight', _formatWeight(subject.trongSoCuoiKi))),
                      SizedBox(width: 8),
                      Expanded(child: _buildInfoRow('CK score', _formatScore(subject.diemCuoiKi))),
                    ],
                  ),

                  SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.06)),
                  SizedBox(height: 12),

                  Text('Điểm tổng kết', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  SizedBox(height: 8),
                  Text(
                    subject.diemTongKet == null ? '-' : subject.diemTongKet!.toStringAsFixed(2),
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

