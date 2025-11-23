import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';

class StudentIdCard extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String majorName;
  final double elevation;

  const StudentIdCard({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.majorName,
    this.elevation = 4.0,
  });

  int? _deriveCohortYear() {
    if (studentId.length < 2) return null;
    final prefix = studentId.substring(0, 2);
    final digits = int.tryParse(prefix);
    if (digits == null) return null;
    return 2000 + digits; // Rule: first 2 digits + 2000
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cohortYear = _deriveCohortYear();

    return AspectRatio(
      aspectRatio: 1.586, // ISO ID-1 (credit card) ratio
      child: Card(
        elevation: elevation,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? AppTheme.darkCard : Colors.white,
        child: Column(
          children: [
            // Header (1/4 height)
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  // Logo placeholder (keeps square proportion using LayoutBuilder)
                  Expanded(
                    flex: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = min(constraints.maxHeight, constraints.maxWidth);
                        return Center(
                          child: Container(
                            width: size * 0.6,
                            height: size * 0.6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.school, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                  // Right blue area with 2 lines
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade800,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              loc.t('vnu_name'),
                              maxLines: 1,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                              stepGranularity: 0.5,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: AutoSizeText(
                              loc.t('uit_name'),
                              maxLines: 1,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                              stepGranularity: 0.5,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body (3/4 height)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  // Left column: Photo + ID
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? Colors.white10 : Colors.grey.shade200,
                              ),
                              child: const Center(
                                child: Icon(Icons.person, size: 48, color: AppTheme.bluePrimary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          flex: 1,
                          child: AutoSizeText(
                            studentId,
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                            stepGranularity: 0.5,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right column: Details + Barcode
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            loc.t('card_title'),
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                            stepGranularity: 0.5,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AutoSizeText(
                            studentName.toUpperCase(),
                            maxLines: 1,
                            minFontSize: 10,
                            overflow: TextOverflow.ellipsis,
                            stepGranularity: 0.5,
                            style: const TextStyle(
                              color: AppTheme.bluePrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          AutoSizeText(
                            cohortYear != null
                                ? (loc.locale.languageCode == 'vi'
                                    ? 'Khoá $cohortYear'
                                    : 'Cohort $cohortYear')
                                : (loc.locale.languageCode == 'vi' ? 'Khoá ?' : 'Cohort ?'),
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                            stepGranularity: 0.5,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AutoSizeText(
                            majorName,
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                            stepGranularity: 0.5,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Barcode simulated area + code
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _BarcodePlaceholder(isDark: isDark),
                                ),
                                const SizedBox(height: 4),
                                AutoSizeText(
                                  '15000$studentId',
                                  maxLines: 1,
                                  minFontSize: 8,
                                  overflow: TextOverflow.ellipsis,
                                  stepGranularity: 0.5,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _BarcodePlaceholder extends StatelessWidget {
  final bool isDark;
  const _BarcodePlaceholder({required this.isDark});

  List<int> _pattern() {
    // Deterministic pseudo pattern based on prime numbers for visual variety
    const primes = [2,3,5,7,11,13,17,19,23,29,31];
    final List<int> bars = [];
    for (var i = 0; i < 42; i++) {
      final p = primes[i % primes.length];
      bars.add((i * p) % 5 == 0 ? 2 : (i % 3 == 0 ? 1 : 3)); // thickness categories
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final bars = _pattern();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final t in bars)
              Expanded(
                flex: t,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    color: t % 2 == 0 ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white24 : Colors.black12),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
