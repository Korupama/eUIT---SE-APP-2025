import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().fetchProgress();
    });
  }

  Map<String, dynamic>? get progressData {
    return context.watch<AcademicProvider>().progress;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  int get completedCredits => _parseInt(progressData?['graduationProgress']?['totalCreditsCompleted']);
  int get totalRequiredCredits => _parseInt(progressData?['graduationProgress']?['totalCreditsRequired']);
  int get remainingCredits => totalRequiredCredits - completedCredits;

  double get progressPercentage {
    return totalRequiredCredits > 0 ? (completedCredits / totalRequiredCredits) * 100 : 0.0;
  }

  List<Map<String, dynamic>> get progressByGroup {
    final list = progressData?['progressByGroup'];
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().toList();
    }
    return [];
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
          'Kết quả đào tạo (Tiến độ)',
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
              // Progress Card
              _buildProgressCard(),

              SizedBox(height: 20),

              // Credits Info Cards
              _buildCreditsInfoCards(),

              SizedBox(height: 20),

              // Progress By Group
              _buildProgressByGroupSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
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
          // Title
          Text(
            'Tổng quan tín chỉ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          // Subtitle
          Text(
            'Theo dõi tiến độ hoàn thành chương trình đào tạo của bạn.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          SizedBox(height: 24),

          // Progress Bar
          Stack(
            children: [
              // Background bar
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              // Progress bar
              FractionallySizedBox(
                widthFactor: progressPercentage / 100,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF3B82F6).withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Percentage
          Center(
            child: Text(
              totalRequiredCredits == 0 ? 'chưa có dữ liệu' : '${progressPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsInfoCards() {
    return Row(
      children: [
        // Completed Credits
        Expanded(
          child: _buildCreditCard(
            title: '{Tín chỉ đã hoàn thành}',
            value: completedCredits.toString(),
            color: Color(0xFF10B981),
            icon: Icons.check_circle_outline,
          ),
        ),

        SizedBox(width: 12),

        // Remaining Credits
        Expanded(
          child: _buildCreditCard(
            title: '{Tín chỉ còn lại}',
            value: remainingCredits.toString(),
            color: Color(0xFFF59E0B),
            icon: Icons.pending_outlined,
          ),
        ),

        SizedBox(width: 12),

        // Total Required Credits
        Expanded(
          child: _buildCreditCard(
            title: '{Tổng tín chỉ yêu cầu}',
            value: totalRequiredCredits.toString(),
            color: Color(0xFF3B82F6),
            icon: Icons.school_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
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
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          SizedBox(height: 12),

          // Title
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),

          SizedBox(height: 8),

          // Value
          Text(
            value == '0' ? 'chưa có dữ liệu' : value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressByGroupSection() {
    final groups = progressByGroup;
    if (groups.isEmpty) {
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
        child: Center(
          child: Text(
            'Chưa có dữ liệu nhóm tín chỉ',
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
          'Tiến độ theo nhóm tín chỉ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...groups.map((group) => _buildGroupCard(group)).toList(),
      ],
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group) {
    final groupName = group['groupName'] ?? 'Nhóm';
    final completed = _parseInt(group['completedCredits']);
    final gpa = group['gpa'] is num ? (group['gpa'] as num).toStringAsFixed(2) : '0.00';
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tín chỉ đã hoàn thành: $completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GPA',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                gpa,
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}