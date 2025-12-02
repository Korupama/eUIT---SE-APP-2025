import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/lecturer_provider.dart';
import '../../models/exam_schedule.dart';
import '../../widgets/animated_background.dart';

class LecturerExamScheduleScreen extends StatefulWidget {
  const LecturerExamScheduleScreen({super.key});

  @override
  State<LecturerExamScheduleScreen> createState() =>
      _LecturerExamScheduleScreenState();
}

class _LecturerExamScheduleScreenState extends State<LecturerExamScheduleScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _selectedLoaiThi;
  String? _selectedVaiTro;
  bool _showPastExams = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LecturerProvider>(
        context,
        listen: false,
      ).fetchExamSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          CustomScrollView(
            slivers: [
              _buildAppBar(isDark),
              SliverToBoxAdapter(child: _buildFilters(isDark)),
              _buildStatistics(isDark),
              _buildExamsList(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1E2746) : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note,
              size: 24,
              color: isDark ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            const Text(
              'Lịch thi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E2746).withOpacity(0.5),
                      const Color(0xFF2A3F7D).withOpacity(0.5),
                    ]
                  : [
                      Colors.white.withOpacity(0.6),
                      const Color(0xFFE3F2FD).withOpacity(0.6),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E2746).withOpacity(0.7),
                  const Color(0xFF2A3F7D).withOpacity(0.7),
                ]
              : [
                  Colors.white.withOpacity(0.75),
                  const Color(0xFFE3F2FD).withOpacity(0.75),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              // Toggle past exams
              Row(
                children: [
                  Text(
                    'Lịch cũ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showPastExams,
                    onChanged: (value) {
                      setState(() {
                        _showPastExams = value;
                      });
                    },
                    activeColor: const Color(0xFF2196F3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Tất cả loại thi', _selectedLoaiThi == null, () {
                setState(() {
                  _selectedLoaiThi = null;
                });
                _applyFilters();
              }, isDark),
              _buildFilterChip(
                'Giữa kỳ',
                _selectedLoaiThi == 'giuaky',
                () {
                  setState(() {
                    _selectedLoaiThi = 'giuaky';
                  });
                  _applyFilters();
                },
                isDark,
                color: Colors.orange,
              ),
              _buildFilterChip(
                'Cuối kỳ',
                _selectedLoaiThi == 'cuoiky',
                () {
                  setState(() {
                    _selectedLoaiThi = 'cuoiky';
                  });
                  _applyFilters();
                },
                isDark,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Tất cả vai trò', _selectedVaiTro == null, () {
                setState(() {
                  _selectedVaiTro = null;
                });
                _applyFilters();
              }, isDark),
              _buildFilterChip(
                'Coi thi',
                _selectedVaiTro == 'coithi',
                () {
                  setState(() {
                    _selectedVaiTro = 'coithi';
                  });
                  _applyFilters();
                },
                isDark,
                color: Colors.blue,
              ),
              _buildFilterChip(
                'Chấm thi',
                _selectedVaiTro == 'chamthi',
                () {
                  setState(() {
                    _selectedVaiTro = 'chamthi';
                  });
                  _applyFilters();
                },
                isDark,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected,
    VoidCallback onTap,
    bool isDark, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: color != null
                      ? [color.withOpacity(0.8), color]
                      : [const Color(0xFF2196F3), const Color(0xFF1976D2)],
                )
              : null,
          color: selected
              ? null
              : (isDark ? const Color(0xFF0A0E21) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(bool isDark) {
    return Consumer<LecturerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final upcomingExams = provider.examSchedules
            .where((e) => e.isUpcoming && !e.isToday)
            .length;
        final todayExams = provider.examSchedules
            .where((e) => e.isToday)
            .length;
        final coiThi = provider.examSchedules
            .where((e) => e.vaiTro == 'coithi' && e.isUpcoming)
            .length;
        final chamThi = provider.examSchedules
            .where((e) => e.vaiTro == 'chamthi' && e.isUpcoming)
            .length;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Hôm nay',
                    todayExams.toString(),
                    Icons.today,
                    Colors.red,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Sắp tới',
                    upcomingExams.toString(),
                    Icons.upcoming,
                    Colors.orange,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Coi thi',
                    coiThi.toString(),
                    Icons.visibility,
                    Colors.blue,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Chấm thi',
                    chamThi.toString(),
                    Icons.edit_note,
                    Colors.green,
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExamsList(bool isDark) {
    return Consumer<LecturerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildShimmerCard(isDark),
              childCount: 3,
            ),
          );
        }

        var exams = provider.examSchedules;

        // Filter past/future exams
        if (!_showPastExams) {
          exams = exams.where((e) => e.isUpcoming || e.isToday).toList();
        }

        if (exams.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState(isDark));
        }

        // Group exams by date
        final Map<String, List<ExamSchedule>> groupedExams = {};
        for (final exam in exams) {
          final dateKey = exam.dateString;
          if (!groupedExams.containsKey(dateKey)) {
            groupedExams[dateKey] = [];
          }
          groupedExams[dateKey]!.add(exam);
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final dateKey = groupedExams.keys.elementAt(index);
              final dateExams = groupedExams[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(dateKey, dateExams.first, isDark),
                  const SizedBox(height: 12),
                  ...dateExams
                      .map((exam) => _buildExamCard(exam, isDark))
                      .toList(),
                  const SizedBox(height: 16),
                ],
              );
            }, childCount: groupedExams.length),
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(String dateString, ExamSchedule exam, bool isDark) {
    String label = dateString;
    Color labelColor = isDark ? Colors.white : Colors.black87;

    if (exam.isToday) {
      label = 'Hôm nay - $dateString';
      labelColor = Colors.red;
    } else if (exam.daysUntil == 1) {
      label = 'Ngày mai - $dateString';
      labelColor = Colors.orange;
    } else if (exam.daysUntil > 0 && exam.daysUntil <= 7) {
      label = '$dateString (còn ${exam.daysUntil} ngày)';
      labelColor = Colors.blue;
    }

    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [labelColor, labelColor.withOpacity(0.5)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard(ExamSchedule exam, bool isDark) {
    final loaiThiColor = exam.loaiThi == 'giuaky' ? Colors.orange : Colors.red;
    final vaiTroColor = exam.vaiTro == 'coithi' ? Colors.blue : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E2746), const Color(0xFF2A3F7D)]
              : [Colors.white, const Color(0xFFE3F2FD)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.7),
                  isDark
                      ? Colors.white.withOpacity(0.02)
                      : Colors.white.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with badges
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${exam.maMon} - ${exam.tenMon}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [loaiThiColor.withOpacity(0.8), loaiThiColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exam.loaiThiLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Time and location info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0A0E21).withOpacity(0.5)
                        : const Color(0xFFF5F7FA).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.access_time, exam.timeRange, isDark),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        exam.location,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.group_outlined,
                        'Nhóm ${exam.nhom} - ${exam.siSo} sinh viên',
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Role and note
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            vaiTroColor.withOpacity(0.2),
                            vaiTroColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: vaiTroColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            exam.vaiTro == 'coithi'
                                ? Icons.visibility
                                : Icons.edit_note,
                            size: 16,
                            color: vaiTroColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            exam.vaiTroLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: vaiTroColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (exam.ghiChu != null && exam.ghiChu!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                exam.ghiChu!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white70 : Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E2746), const Color(0xFF2A3F7D)]
              : [Colors.white, const Color(0xFFE3F2FD)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có lịch thi',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    Provider.of<LecturerProvider>(
      context,
      listen: false,
    ).fetchExamSchedules(loaiThi: _selectedLoaiThi, vaiTro: _selectedVaiTro);
  }
}
