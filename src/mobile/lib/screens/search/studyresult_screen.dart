import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';

class StudyResultScreen extends StatefulWidget {
  const StudyResultScreen({super.key});

  @override
  State<StudyResultScreen> createState() => _StudyResultScreenState();
}

class _StudyResultScreenState extends State<StudyResultScreen> {
  String? selectedSemester;
  List<String> semesters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AcademicProvider>();
      await provider.fetchGrades();
      final allGrades = provider.grades;
      final uniqueSemesters = allGrades
          .map((e) => e['hocKy'] as String)
          .toSet()
          .toList();
      uniqueSemesters.sort((a, b) => b.compareTo(a));
      setState(() {
        semesters = uniqueSemesters;
        selectedSemester = semesters.isNotEmpty ? semesters.first : null;
      });
    });
  }

  List<Map<String, dynamic>> get currentGrades {
    final provider = context.watch<AcademicProvider>();
    if (selectedSemester == null) return [];
    return provider.grades.where((g) => g['hocKy'] == selectedSemester).toList();
  }

  double get currentGPA {
    final data = currentGrades;
    if (data.isEmpty) return 0.0;

    double totalPoints = 0;
    num totalCredits = 0;

    for (var subject in data) {
      final totalRaw = subject['diemTongKet'];
      // Chỉ tính môn đã có điểm (không null)
      if (totalRaw == null) continue;

      final total = (totalRaw is num) ? totalRaw.toDouble() : 0.0;
      final creditsRaw = subject['soTinChi'];
      final credits = (creditsRaw is num) ? creditsRaw : 0;
      totalPoints += total * credits;
      totalCredits += credits;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  // Tính toán GPA tích lũy (cumulative GPA) từ tất cả các học kỳ
  double get cumulativeGPA {
    final provider = context.watch<AcademicProvider>();
    final allGrades = provider.grades;

    if (allGrades.isEmpty) return 0.0;

    double totalPoints = 0;
    num totalCredits = 0;

    for (var subject in allGrades) {
      final totalRaw = subject['diemTongKet'];
      // Chỉ tính môn đã có điểm (không null)
      if (totalRaw == null) continue;

      final total = (totalRaw is num) ? totalRaw.toDouble() : 0.0;
      final creditsRaw = subject['soTinChi'];
      final credits = (creditsRaw is num) ? creditsRaw : 0;
      totalPoints += total * credits;
      totalCredits += credits;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  // Chuyển đổi GPA từ hệ 10.0 sang hệ 4.0
  double convertGPAto4Scale(double gpa10) {
    if (gpa10 >= 8.5) return 4.0;
    if (gpa10 >= 7.0) return 3.0 + (gpa10 - 7.0) / 1.5;
    if (gpa10 >= 5.5) return 2.0 + (gpa10 - 5.5) / 1.5;
    if (gpa10 >= 4.0) return 1.0 + (gpa10 - 4.0) / 1.5;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kết quả học tập',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GPA Card
              _buildGPACard(),

              SizedBox(height: 20),

              // Semester Selector Card
              _buildSemesterSelector(),

              SizedBox(height: 20),

              // Results Table
              _buildResultsTable(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGPACard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school_rounded,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'GPA Tích Lũy',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              // Hệ 10.0
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF3B82F6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hệ 10.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        cumulativeGPA.toStringAsFixed(2),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Hệ 4.0
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF10B981).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hệ 4.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        convertGPAto4Scale(cumulativeGPA).toStringAsFixed(2),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterSelector() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xem điểm theo kỳ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSemester,
                isExpanded: true,
                items: semesters.map((String semester) {
                  return DropdownMenuItem(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedSemester = value);
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'GPA kỳ này: ${currentGPA.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    final data = currentGrades;

    if (data.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Chưa có dữ liệu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedSemester ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),

        // Use ListView for better mobile experience
        ...data.asMap().entries.map((entry) {
          final subject = entry.value;

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject name and grade
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subject['tenMonHoc'] ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: subject['diemTongKet'] == null
                          ? Colors.white.withOpacity(0.2)
                          : _getGradeColor(_calculateGrade(_parseScore(subject['diemTongKet']))).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subject['diemTongKet'] == null
                          ? 'chưa có điểm'
                          : _calculateGrade(_parseScore(subject['diemTongKet'])),
                        style: TextStyle(
                          color: subject['diemTongKet'] == null
                            ? Colors.white
                            : _getGradeColor(_calculateGrade(_parseScore(subject['diemTongKet']))),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Scores grid
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreItem('Tín chỉ', (subject['soTinChi'] ?? 0).toString()),
                    ),
                    Expanded(
                      child: _buildScoreItem(
                        'Tổng kết',
                        subject['diemTongKet'] == null
                          ? 'chưa có điểm'
                          : ((subject['diemTongKet'] is num)
                              ? (subject['diemTongKet'] as num).toDouble().toStringAsFixed(1)
                              : '0.0'),
                        isHighlight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildScoreItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isHighlight ? 18 : 16,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Color(0xFFFFD700); // Yellow for A+
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

  String _calculateGrade(num? score) {
    final s = (score ?? 0).toDouble();

    if (s >= 9.0) return 'A+';
    if (s >= 8.0) return 'A';
    if (s >= 7.0) return 'B+';
    if (s >= 6.0) return 'B';
    if (s >= 5.0) return 'C';
    if (s >= 4.0) return 'D+';
    if (s >= 3.0) return 'D';
    return 'F';
  }


  double _parseScore(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }
}