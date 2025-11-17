import 'package:flutter/material.dart';

class StudyResultScreen extends StatefulWidget {
  const StudyResultScreen({super.key});

  @override
  State<StudyResultScreen> createState() => _StudyResultScreenState();
}

class _StudyResultScreenState extends State<StudyResultScreen> {
  String selectedSemester = 'Học kỳ 2 - Năm học 2023-2024';

  final List<String> semesters = [
    'Học kỳ 2 - Năm học 2023-2024',
    'Học kỳ 1 - Năm học 2023-2024',
    'Học kỳ 2 - Năm học 2022-2023',
    'Học kỳ 1 - Năm học 2022-2023',
  ];

  final Map<String, List<Map<String, dynamic>>> semesterData = {
    'Học kỳ 2 - Năm học 2023-2024': [
      {
        'subject': 'Cấu trúc dữ liệu & Giải thuật',
        'credits': 4,
        'midterm': 8.5,
        'final': 9.0,
        'total': 8.8,
        'grade': 'A',
      },
      {
        'subject': 'Toán cao cấp A2',
        'credits': 4,
        'midterm': 8.0,
        'final': 8.5,
        'total': 8.3,
        'grade': 'B+',
      },
      {
        'subject': 'Tiếng Anh chuyên ngành',
        'credits': 3,
        'midterm': 9.5,
        'final': 9.0,
        'total': 9.3,
        'grade': 'A',
      },
    ],
    'Học kỳ 1 - Năm học 2023-2024': [
      {
        'subject': 'Lập trình hướng đối tượng',
        'credits': 4,
        'midterm': 8.0,
        'final': 8.5,
        'total': 8.3,
        'grade': 'B+',
      },
      {
        'subject': 'Cơ sở dữ liệu',
        'credits': 3,
        'midterm': 9.0,
        'final': 9.5,
        'total': 9.3,
        'grade': 'A',
      },
    ],
  };

  double get currentGPA {
    final data = semesterData[selectedSemester] ?? [];
    if (data.isEmpty) return 0.0;

    double totalPoints = 0;
    int totalCredits = 0;

    for (var subject in data) {
      totalPoints += subject['total'] * subject['credits'];
      totalCredits += subject['credits'] as int;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
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
          Text(
            'GPA Tích Lũy',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '8.37',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Hệ 10.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
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
                dropdownColor: Color(0xFF1E293B),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                items: semesters.map((String semester) {
                  return DropdownMenuItem<String>(
                    value: semester,
                    child: Text(semester),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedSemester = newValue;
                    });
                  }
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
    final data = semesterData[selectedSemester] ?? [];

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
          selectedSemester,
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
                        subject['subject'],
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
                        color: _getGradeColor(subject['grade']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subject['grade'],
                        style: TextStyle(
                          color: _getGradeColor(subject['grade']),
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
                      child: _buildScoreItem('Tín chỉ', subject['credits'].toString()),
                    ),
                    Expanded(
                      child: _buildScoreItem('Giữa kỳ', subject['midterm'].toString()),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildScoreItem('Cuối kỳ', subject['final'].toString()),
                    ),
                    Expanded(
                      child: _buildScoreItem('Tổng kết', subject['total'].toString(),
                          isHighlight: true),
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
      case 'A':
      case 'A+':
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
}