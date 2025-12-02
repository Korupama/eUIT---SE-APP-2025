import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/lecturer_models.dart';
import 'package:shimmer/shimmer.dart';

/// LecturerScheduleScreen - Lịch giảng dạy đầy đủ
class LecturerScheduleScreen extends StatefulWidget {
  const LecturerScheduleScreen({super.key});

  @override
  State<LecturerScheduleScreen> createState() => _LecturerScheduleScreenState();
}

class _LecturerScheduleScreenState extends State<LecturerScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  int _selectedWeek = 1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LecturerProvider>().fetchSchedule();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LecturerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildTabBar(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeekView(provider, isDark),
                  _buildMonthView(provider, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                .withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch giảng dạy',
                      style: AppTheme.headingMedium.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Học kỳ 1 - Năm học 2024-2025',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _selectedWeek = 1;
                  });
                },
                icon: Icon(
                  Icons.today_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    .withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm lớp học...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withOpacity(0.3),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        labelStyle: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTheme.bodyMedium,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Theo tuần'),
          Tab(text: 'Theo tháng'),
        ],
      ),
    );
  }

  Widget _buildWeekView(LecturerProvider provider, bool isDark) {
    if (provider.isLoading) {
      return _buildShimmerLoading(isDark);
    }

    final weekSchedule = _getWeekSchedule(provider.schedule);

    return Column(
      children: [
        _buildWeekSelector(isDark),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = _selectedDate.add(Duration(days: index - _selectedDate.weekday + 1));
              final daySchedule = weekSchedule[index] ?? [];
              return _buildDayCard(day, daySchedule, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedWeek = (_selectedWeek - 1).clamp(1, 20);
                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
              });
            },
            icon: Icon(
              Icons.chevron_left,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Tuần $_selectedWeek',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedWeek = (_selectedWeek + 1).clamp(1, 20);
                _selectedDate = _selectedDate.add(const Duration(days: 7));
              });
            },
            icon: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DateTime day, List<TeachingScheduleItem> schedule, bool isDark) {
    final dayName = DateFormat('EEEE', 'vi').format(day);
    final dateStr = DateFormat('dd/MM/yyyy').format(day);
    final isToday = day.day == DateTime.now().day &&
        day.month == DateTime.now().month &&
        day.year == DateTime.now().year;

    // Filter by search query
    final filteredSchedule = schedule.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.tenMon.toLowerCase().contains(_searchQuery) ||
          item.maMon.toLowerCase().contains(_searchQuery);
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday
                    ? AppTheme.bluePrimary.withOpacity(0.5)
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
                width: isToday ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isToday
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [
                              (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                                  .withOpacity(0.5),
                              (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                                  .withOpacity(0.3),
                            ],
                          ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isToday
                            ? Colors.white
                            : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dayName,
                        style: AppTheme.bodyMedium.copyWith(
                          color: isToday
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: AppTheme.bodySmall.copyWith(
                          color: isToday
                              ? Colors.white.withOpacity(0.9)
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.white.withOpacity(0.2)
                              : (isDark ? AppTheme.darkCard : Colors.white).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredSchedule.length} tiết',
                          style: AppTheme.bodySmall.copyWith(
                            color: isToday
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (filteredSchedule.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Không có lịch giảng',
                        style: AppTheme.bodySmall.copyWith(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...filteredSchedule.map((item) => _buildScheduleItem(item, isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(TeachingScheduleItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Tiết',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${item.tietBatDau}-${item.tietKetThuc}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tenMon,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nhóm ${item.nhom}',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.siSo} SV',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.phong ?? 'TBA',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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

  Widget _buildMonthView(LecturerProvider provider, bool isDark) {
    if (provider.isLoading) {
      return _buildShimmerLoading(isDark);
    }

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = DateTime(now.year, now.month, index + 1);
        final daySchedule = provider.schedule
            .where((item) => item.thu == day.weekday)
            .toList();

        // Filter by search query
        final filteredSchedule = daySchedule.where((item) {
          if (_searchQuery.isEmpty) return true;
          return item.tenMon.toLowerCase().contains(_searchQuery) ||
              item.maMon.toLowerCase().contains(_searchQuery);
        }).toList();

        return _buildDayCard(day, filteredSchedule, isDark);
      },
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Map<int, List<TeachingScheduleItem>> _getWeekSchedule(List<TeachingScheduleItem> schedule) {
    final Map<int, List<TeachingScheduleItem>> weekSchedule = {};
    for (int i = 0; i < 7; i++) {
      weekSchedule[i] = schedule.where((item) => item.thu == i + 1).toList();
    }
    return weekSchedule;
  }
}
