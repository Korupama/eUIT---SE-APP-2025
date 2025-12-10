import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import 'subject_detail_screen.dart';
import 'package:mobile/models/grades_detail.dart';
import '../../widgets/animated_background.dart';
import '../../utils/app_localizations.dart';
import '../../theme/app_theme.dart';

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
      await provider.fetchGradeDetails();
      final details = provider.gradeDetails;
      final semList = details?.semesters.map((s) => s.hocKy).toList() ?? [];
      semList.sort((a, b) => b.compareTo(a));
      setState(() {
        semesters = semList;
        selectedSemester = semesters.isNotEmpty ? semesters.first : null;
      });
    });
  }

  List<SubjectDetail> get currentGrades {
    final provider = context.watch<AcademicProvider>();
    if (selectedSemester == null) return [];
    final sem = provider.gradeDetails?.semesters.firstWhere((s) => s.hocKy == selectedSemester, orElse: () => SemesterDetail(hocKy: '', semesterGpa: null, subjects: []));
    return sem?.subjects ?? [];
  }

  double get currentGPA {
    final provider = context.watch<AcademicProvider>();
    if (selectedSemester == null) return 0.0;
    final sem = provider.gradeDetails?.semesters.firstWhere((s) => s.hocKy == selectedSemester, orElse: () => SemesterDetail(hocKy: '', semesterGpa: null, subjects: []));
    return sem?.semesterGpa ?? 0.0;
  }

  // Tính toán GPA tích lũy (cumulative GPA) từ tất cả các học kỳ
  double get cumulativeGPA {
    final provider = context.watch<AcademicProvider>();
    return provider.gradeDetails?.overallGpa ?? 0.0;
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
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double navBarHeight = AppTheme.bottomNavBaseHeight + bottomInset;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.t('study_results_title'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated background (same as main screen's background) — ensure it expands to full screen
          Positioned.fill(
            child: IgnorePointer(
              child: SizedBox.expand(child: AnimatedBackground(isDark: isDark)),
            ),
          ),

          // Make the scrollable content also positioned to force Stack to full screen size
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + navBarHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GPA Card
                    _buildGPACard(isDark, loc),

                    SizedBox(height: 20),

                    // Semester Selector Card
                    _buildSemesterSelector(isDark, loc),

                    SizedBox(height: 20),

                    // Results Table
                    _buildResultsTable(isDark, loc),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGPACard(bool isDark, AppLocalizations loc) {
    // Use glassmorphism style in dark mode (semi-transparent white) like StudentConfirmationScreen
    final cardColor = isDark ? Color.fromRGBO(255, 255, 255, 0.06) : Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? Color.fromRGBO(255, 255, 255, 0.10) : Color.fromRGBO(0, 0, 0, 0.05);

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: strokeColor,
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
                color: AppTheme.bluePrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                loc.t('gpa_cumulative'),
                style: TextStyle(
                  color: AppTheme.bluePrimary,
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
                    // Use a translucent dark that matches the card tone but is lighter than full-opaque
                    color: isDark ? Color.fromRGBO(255, 255, 255, 0.08) : Color.fromRGBO(255, 255, 255, 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color.fromARGB((0.3 * 255).round(), 59, 130, 246),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('gpa_10_label'),
                        style: TextStyle(
                          color: isDark ? Colors.white.withAlpha((0.6 * 255).round()) : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        cumulativeGPA.toStringAsFixed(2),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
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
                    // Use translucent dark for selector input as well
                    color: isDark ? Color.fromRGBO(255, 255, 255, 0.08) : Color.fromRGBO(255, 255, 255, 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color.fromARGB((0.3 * 255).round(), 16, 185, 129),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('gpa_4_label'),
                        style: TextStyle(
                          color: isDark ? Colors.white.withAlpha((0.6 * 255).round()) : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        convertGPAto4Scale(cumulativeGPA).toStringAsFixed(2),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
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

  Widget _buildSemesterSelector(bool isDark, AppLocalizations loc) {
    final cardColor = isDark ? Color.fromRGBO(30, 41, 59, 0.62) : Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? Color.fromRGBO(255, 255, 255, 0.10) : Color.fromRGBO(0, 0, 0, 0.05);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: strokeColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('view_by_semester'),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              // Selector input uses glass in dark mode too
              color: isDark ? Color.fromRGBO(255, 255, 255, 0.08) : Color.fromRGBO(255, 255, 255, 0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: strokeColor,
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
                    child: Text(_formatSemesterLabel(semester, loc), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
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
            '${loc.t('current_semester_gpa')}: ${currentGPA.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDark ? Colors.white.withAlpha((0.7 * 255).round()) : Colors.black87.withAlpha((0.7 * 255).round()),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable(bool isDark, AppLocalizations loc) {
    final data = currentGrades;
    final cardColor = isDark ? Color.fromRGBO(30, 41, 59, 0.62) : Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? Color.fromRGBO(255, 255, 255, 0.10) : Color.fromRGBO(0, 0, 0, 0.05);

    if (data.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: strokeColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            loc.t('no_data'),
            style: TextStyle(
              color: isDark ? Colors.white.withAlpha((0.5 * 255).round()) : Colors.black54,
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
          _formatSemesterLabel(selectedSemester, loc),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),

        // Use ListView for better mobile experience
        ...data.asMap().entries.map((entry) {
          final subject = entry.value;
          final grade = subject.diemTongKet == null ? null : _calculateGrade(subject.diemTongKet);
          final Color gradeColor = grade == null ? Colors.white : _getGradeColor(grade);
          // Use Color.red/green/blue which return 0..255 ints
          final int r = gradeColor.red.clamp(0, 255);
          final int g = gradeColor.green.clamp(0, 255);
          final int b = gradeColor.blue.clamp(0, 255);
          final badgeBg = Color.fromARGB((0.2 * 255).round(), r, g, b);

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubjectDetailScreen(subject: subject),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Result item inner box: glass effect in dark mode so background doesn't appear too dark
                color: isDark ? Color.fromRGBO(255, 255, 255, 0.06) : Color.fromRGBO(255, 255, 255, 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: strokeColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          // Show trimmed subject code then name: "MAMH - Tên môn"
                          '${_trimSubjectCode(subject.maMonHoc)} - ${subject.tenMonHoc}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: grade == null
                              ? Color.fromARGB((0.2 * 255).round(), 255, 255, 255)
                              : badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          grade == null ? '-' : grade,
                          style: TextStyle(
                            color: grade == null ? (isDark ? Colors.white : Colors.black87) : gradeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: isDark ? Colors.white.withAlpha((0.7 * 255).round()) : Colors.black45, size: 20),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildScoreItem(loc.t('credits'), subject.soTinChi?.toString() ?? '-', isDark: isDark),
                      ),
                      Expanded(
                        child: _buildScoreItem(
                          loc.t('final_score'),
                          subject.diemTongKet == null ? '-' : subject.diemTongKet!.toStringAsFixed(1),
                          isHighlight: true,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildScoreItem(String label, String value, {bool isHighlight = false, bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white.withAlpha((0.5 * 255).round()) : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
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

  // ignore: unused_element
   double _parseScore(dynamic value) {
     if (value == null) return 0.0;
     if (value is num) return value.toDouble();
     if (value is String) {
       final parsed = double.tryParse(value);
       return parsed ?? 0.0;
     }
     return 0.0;
   }

  // ignore: unused_element
   String _trimSubjectCode(String? code) {
     if (code == null) return '';
     // Giả sử mã môn học có định dạng như sau: "MATH101 - Giải tích 1"
     final parts = code.split(' - ');
     return parts.isNotEmpty ? parts.first : '';
   }

  // Move the semester formatting helper to a class-level private method so all widgets can reuse it
  String _formatSemesterLabel(String? raw, AppLocalizations loc) {
    if (raw == null || raw.isEmpty) return '';
    final parts = raw.split(RegExp('[_-]'));
    if (parts.length < 3) return raw;
    final year1 = parts[0];
    final year2 = parts[1];
    final semester = parts[2];
    final template = loc.t('semester_format');
    return template.replaceAll('{semester}', semester).replaceAll('{year1}', year1).replaceAll('{year2}', year2);
  }
 }
