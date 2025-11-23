import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final List<Map<String, dynamic>> academicEvents = [
    {
      'date': '05/08/2024 - 11/08/2024',
      'title': 'Tuần sinh hoạt công dân sinh viên đầu khóa',
      'color': Color(0xFF3B82F6),
    },
    {
      'date': '12/08/2024',
      'title': 'Bắt đầu học kỳ 1 năm học 2024-2025',
      'color': Color(0xFF3B82F6),
    },
    {
      'date': '02/09/2024',
      'title': 'Nghỉ lễ Quốc Khánh',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '07/10/2024 - 12/10/2024',
      'title': 'Thi giữa kỳ',
      'color': Color(0xFFF59E0B),
    },
    {
      'date': '16/12/2024 - 28/12/2024',
      'title': 'Thi kết thúc học phần học kỳ 1',
      'color': Color(0xFFF59E0B),
    },
    {
      'date': '01/01/2025',
      'title': 'Nghỉ Tết Dương lịch',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '27/01/2025 - 08/02/2025',
      'title': 'Nghỉ Tết Nguyên Đán',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '17/02/2025',
      'title': 'Bắt đầu học kỳ 2 năm học 2024-2025',
      'color': Color(0xFF3B82F6),
    },
    {
      'date': '30/04/2025',
      'title': 'Nghỉ lễ Giải phóng miền Nam',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '01/05/2025',
      'title': 'Nghỉ lễ Quốc tế Lao động',
      'color': Color(0xFFEF4444),
    },
  ];

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
          'Kế hoạch năm học 2024-2025',
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
          child: Container(
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
              children: [
                ...academicEvents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  final isLast = index == academicEvents.length - 1;

                  return _buildTimelineItem(
                    date: event['date'],
                    title: event['title'],
                    color: event['color'],
                    isLast: isLast,
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String title,
    required Color color,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              // Circle
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: Color(0xFF0F172A),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color,
                          color.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    date,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),

                  SizedBox(height: 6),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
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