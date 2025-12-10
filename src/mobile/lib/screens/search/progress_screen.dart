import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/app_localizations.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/animated_background.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).t('progress_title'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: AnimatedBackground(isDark: isDark)),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
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
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);

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
          // Title
          Text(
            AppLocalizations.of(context).t('progress_overview_title'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          // Subtitle
          Text(
            AppLocalizations.of(context).t('progress_overview_subtitle'),
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.6),
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
                        color: Color.fromRGBO(59, 130, 246, 0.5),
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
              totalRequiredCredits == 0 ? AppLocalizations.of(context).t('no_data') : '${progressPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: isDark ? Color.fromRGBO(255,255,255,1) : Colors.black87,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: strokeColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Avoid deprecated .red/.green/.blue: extract RGB from color.value
              color: (() {
                final r = ((color.r * 255.0).round()).clamp(0, 255).toInt();
                final g = ((color.g * 255.0).round()).clamp(0, 255).toInt();
                final b = ((color.b * 255.0).round()).clamp(0, 255).toInt();
                return Color.fromARGB((0.2 * 255).round(), r, g, b);
              })(),
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
              color: Color.fromRGBO(255,255,255,0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),

          SizedBox(height: 8),

          // Value
          Text(
            value == '0' ? AppLocalizations.of(context).t('no_data') : value,
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
      final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);
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
        child: Center(
          child: Text(
            AppLocalizations.of(context).t('progress_no_group_data'),
            style: TextStyle(
              color: isDark ? Color.fromRGBO(255,255,255,0.5) : Colors.black54,
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
          AppLocalizations.of(context).t('progress_by_group_title'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30,41,59,0.62) : const Color.fromRGBO(255,255,255,0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255,255,255,0.10) : const Color.fromRGBO(0,0,0,0.05);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: strokeColor,
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
                    color: isDark ? Color.fromRGBO(255,255,255,1) : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tín chỉ đã hoàn thành: $completed',
                  style: TextStyle(
                    color: isDark ? Color.fromRGBO(255,255,255,0.7) : Colors.black54,
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
                  color: isDark ? Color.fromRGBO(255,255,255,0.6) : Colors.black54,
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
