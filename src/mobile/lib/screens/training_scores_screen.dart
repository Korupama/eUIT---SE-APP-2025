import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/academic_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../models/student_models.dart';

/// TrainingScoresScreen displays student training scores
/// Shows training scores list with semester filtering
class TrainingScoresScreen extends StatefulWidget {
  const TrainingScoresScreen({super.key});

  @override
  State<TrainingScoresScreen> createState() => _TrainingScoresScreenState();
}

class _TrainingScoresScreenState extends State<TrainingScoresScreen> {
  String? _selectedSemester;

  @override
  void initState() {
    super.initState();
    // Fetch training scores on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicProvider>().fetchTrainingScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.isLoading) {
      return _buildShimmerLoading(isDark);
    }

    final trainingScores = provider.trainingScores;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          loc.t('training_scores'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Semester filter
            _buildSemesterFilter(loc, isDark, provider),
            const SizedBox(height: 16),
            // Training scores list
            Expanded(
              child: trainingScores != null && trainingScores.trainingScores.isNotEmpty
                  ? _buildTrainingScoresList(trainingScores.trainingScores, isDark, loc)
                  : _buildEmptyState(loc, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
          child: Container(
            height: 24,
            width: 100,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 100,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterFilter(AppLocalizations loc, bool isDark, AcademicProvider provider) {
    // For simplicity, hardcoded semesters. In real app, fetch from API
    final semesters = ['2023-2024', '2024-2025', '2025-2026'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(26) : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('filter_by_semester'),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(loc.t('all')),
                selected: _selectedSemester == null,
                onSelected: (selected) {
                  setState(() => _selectedSemester = null);
                  provider.fetchTrainingScores();
                },
              ),
              ...semesters.map((semester) => FilterChip(
                label: Text(semester),
                selected: _selectedSemester == semester,
                onSelected: (selected) {
                  setState(() => _selectedSemester = selected ? semester : null);
                  provider.fetchTrainingScores(filterBySemester: selected ? semester : null);
                },
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingScoresList(List<TrainingScore> scores, bool isDark, AppLocalizations loc) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${loc.t('semester')}: ${score.hocKy}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score.tongDiem),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        score.tongDiem.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreItem(
                        loc.t('classification'),
                        score.xepLoai,
                        isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildScoreItem(
                        loc.t('status'),
                        score.tinhTrang,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations loc, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            loc.t('no_training_scores'),
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.red;
    return Colors.grey;
  }
}
