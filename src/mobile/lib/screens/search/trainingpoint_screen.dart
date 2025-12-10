import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utils/app_localizations.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/animated_background.dart';

class TrainingPointScreen extends StatefulWidget {
  const TrainingPointScreen({super.key});

  @override
  State<TrainingPointScreen> createState() => _TrainingPointScreenState();
}

class _TrainingPointScreenState extends State<TrainingPointScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().fetchTrainingPoints();
    });
  }

  List<Map<String, dynamic>> get semesterScores {
    return context.watch<AcademicProvider>().trainingPoints;
  }

  double get totalScore {
    if (semesterScores.isEmpty) return 0.0;

    // Lọc các kỳ đã có điểm (tongDiem không null)
    final validScores = semesterScores
        .where((item) => item['tongDiem'] != null)
        .toList();

    if (validScores.isEmpty) return 0.0;

    // Tính tổng điểm của các kỳ đã có điểm
    final total = validScores.fold(0.0, (sum, item) {
      final score = item['tongDiem'];
      return sum + (score is num ? score.toDouble() : 0.0);
    });

    // Trả về điểm trung bình
    return total / validScores.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AcademicProvider>();
    final isLoading = provider.isLoading;
    final scores = semesterScores;

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
          AppLocalizations.of(context).t('training_point_title'),
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Training Score Card
                          _buildTotalScoreCard(),

                          SizedBox(height: 20),

                          // Semester Scores Card or empty state
                          scores.isEmpty
                              ? Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark ? Color.fromRGBO(30, 41, 59, 0.62) : Color.fromRGBO(255, 255, 255, 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? Color.fromRGBO(255,255,255,0.10) : Color.fromRGBO(0,0,0,0.05), width: 1),
                                  ),
                                  child: Center(child: Text(AppLocalizations.of(context).t('no_data'), style: TextStyle(color: isDark ? Color.fromRGBO(255,255,255,0.6) : Colors.black54))),
                                )
                              : _buildSemesterScoresCard(),

                          SizedBox(height: 20),

                          // Additional Info
                          _buildAdditionalInfo(),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScoreCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: strokeColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(139, 92, 246, 0.20),
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
                  AppLocalizations.of(context).t('training_point_total_label'),
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
                      semesterScores.isEmpty ? AppLocalizations.of(context).t('no_data') : totalScore.toStringAsFixed(1),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: semesterScores.isEmpty ? 16 : 48,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/ 100',
                        style: TextStyle(
                          color: isDark ? Color.fromRGBO(255, 255, 255, 0.5) : Colors.black54,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);

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
            AppLocalizations.of(context).t('training_point_by_semester'),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
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
                _buildSemesterItem(item),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                      color: Color.fromRGBO(255, 255, 255, 0.1),
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

  Widget _buildSemesterItem(Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final semester = item['hocKy'] ?? 'Unknown';
    final scoreRaw = item['tongDiem'];
    final score = _parseScore(scoreRaw);
    final ranking = item['xepLoai'] ?? 'Unknown';
    Color scoreColor = _getScoreColor(score.toInt());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                semester,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ranking,
                style: TextStyle(
                  color: isDark ? Color.fromRGBO(255, 255, 255, 0.6) : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color.fromARGB((0.2 * 255).round(), ((scoreColor.r * 255.0).round()).clamp(0,255).toInt(), ((scoreColor.g * 255.0).round()).clamp(0,255).toInt(), ((scoreColor.b * 255.0).round()).clamp(0,255).toInt()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color.fromARGB((0.3 * 255).round(), ((scoreColor.r * 255.0).round()).clamp(0,255).toInt(), ((scoreColor.g * 255.0).round()).clamp(0,255).toInt(), ((scoreColor.b * 255.0).round()).clamp(0,255).toInt()),
              width: 1,
            ),
          ),
          child: Text(
            scoreRaw == null ? AppLocalizations.of(context).t('training_point_no_score') : score.toStringAsFixed(1),
            style: TextStyle(
              color: scoreRaw == null ? (isDark ? Color.fromRGBO(255, 255, 255, 1) : Colors.black87) : scoreColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color.fromRGBO(30, 41, 59, 0.62) : const Color.fromRGBO(255, 255, 255, 0.9);
    final strokeColor = isDark ? const Color.fromRGBO(255, 255, 255, 0.10) : const Color.fromRGBO(0, 0, 0, 0.05);

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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).t('training_point_additional_info'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Text(
            AppLocalizations.of(context).t('training_point_additional_description'),
            style: TextStyle(
              color: isDark ? Color.fromRGBO(255, 255, 255, 0.6) : Colors.black54,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
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