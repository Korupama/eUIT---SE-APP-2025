import 'package:flutter/material.dart';

class TrainingPointScreen extends StatefulWidget {
  const TrainingPointScreen({super.key});

  @override
  State<TrainingPointScreen> createState() => _TrainingPointScreenState();
}

class _TrainingPointScreenState extends State<TrainingPointScreen> {
  final List<Map<String, dynamic>> semesterScores = [
    {
      'semester': 'Học kỳ 1 - 2023-2024',
      'score': 85,
    },
    {
      'semester': 'Học kỳ 2 - 2023-2024',
      'score': 92,
    },
    {
      'semester': 'Học kỳ 1 - 2022-2023',
      'score': 88,
    },
    {
      'semester': 'Học kỳ 2 - 2022-2023',
      'score': 90,
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
          'Điểm Rèn Luyện',
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
              // Total Training Score Card
              _buildTotalScoreCard(),

              SizedBox(height: 20),

              // Semester Scores Card
              _buildSemesterScoresCard(),

              SizedBox(height: 20),

              // Additional Info
              _buildAdditionalInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalScoreCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF8B5CF6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: Color(0xFF8B5CF6),
            ),
          ),

          SizedBox(width: 24),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm Rèn Luyện Tổng',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '88.5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/ 100',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterScoresCard() {
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
            'Điểm rèn luyện theo kỳ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20),

          // Semester list
          ...semesterScores.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == semesterScores.length - 1;

            return Column(
              children: [
                _buildSemesterItem(item['semester'], item['score']),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSemesterItem(String semester, int score) {
    Color scoreColor = _getScoreColor(score);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          semester,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scoreColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(
              color: scoreColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Thông tin thêm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Text(
            'Điểm rèn luyện được đánh giá dựa trên sự tham gia vào các hoạt động của trường, lớp, và các thành tích khác. Điểm số này ảnh hưởng đến việc xét học bổng và các danh hiệu thi đua.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) {
      return Color(0xFF10B981); // Green - Excellent
    } else if (score >= 80) {
      return Color(0xFF3B82F6); // Blue - Good
    } else if (score >= 70) {
      return Color(0xFFF59E0B); // Orange - Average
    } else if (score >= 60) {
      return Color(0xFFEF4444); // Red - Below Average
    } else {
      return Color(0xFF6B7280); // Gray - Poor
    }
  }
}