import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/lecturer_models.dart';
import '../../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';

/// LecturerScheduleScreen - Lịch giảng dạy đầy đủ
class LecturerScheduleScreen extends StatefulWidget {
  final bool showBackButton;

  const LecturerScheduleScreen({super.key, this.showBackButton = false});

  @override
  State<LecturerScheduleScreen> createState() => _LecturerScheduleScreenState();
}

class _LecturerScheduleScreenState extends State<LecturerScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  late int _selectedWeek;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedWeek = _getCurrentWeek(); // Khởi tạo với tuần hiện tại
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch schedule for current semester
      context.read<LecturerProvider>().fetchSchedule(semester: '2025_2026_1');
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
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          SafeArea(
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
        ],
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
              if (widget.showBackButton)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
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
                child: Text(
                  'Lịch giảng dạy',
                  style: AppTheme.headingMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (!_isCurrentWeek())
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                      _selectedWeek = _getCurrentWeek();
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    backgroundColor: AppTheme.bluePrimary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Hôm nay',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.bluePrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(
                0.5,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    .withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
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
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
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
        unselectedLabelColor: isDark
            ? Colors.grey.shade400
            : Colors.grey.shade600,
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

    // Don't filter schedule here - we'll check dates when displaying each day
    final weekSchedule = _getWeekSchedule(provider.schedule);

    return Column(
      children: [
        _buildWeekSelector(isDark),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              // Tính ngày bắt đầu tuần (Thứ 2)
              final startOfWeek = _selectedDate.subtract(
                Duration(days: _selectedDate.weekday - 1),
              );
              // Lấy ngày tương ứng (index 0 = Thứ 2, index 6 = Chủ nhật)
              final day = startOfWeek.add(Duration(days: index));
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
            onPressed: _selectedWeek > 1
                ? () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 7),
                      );
                      _selectedWeek = _getWeekNumber(_selectedDate);
                    });
                  }
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: _selectedWeek > 1
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.grey.shade400,
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
            onPressed: _selectedWeek < 20
                ? () {
                    setState(() {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 7),
                      );
                      _selectedWeek = _getWeekNumber(_selectedDate);
                    });
                  }
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: _selectedWeek < 20
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    DateTime day,
    List<TeachingScheduleItem> schedule,
    bool isDark,
  ) {
    final dayName = DateFormat('EEEE', 'vi').format(day);
    final dateStr = DateFormat('dd/MM/yyyy').format(day);
    final isToday =
        day.day == DateTime.now().day &&
        day.month == DateTime.now().month &&
        day.year == DateTime.now().year;

    // Filter by search query AND check if class should be shown on this specific date
    final filteredSchedule = schedule.where((item) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = item.tenMon.toLowerCase().contains(_searchQuery) ||
            item.maMon.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }
      
      // Date range and cachTuan filter
      return _shouldShowClassOnDate(item, day);
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(
                0.5,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday
                    ? AppTheme.bluePrimary.withOpacity(0.5)
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                          .withOpacity(0.3),
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
                              (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200)
                                  .withOpacity(0.5),
                              (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200)
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
                            : (isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600),
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
                              : (isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.white.withOpacity(0.2)
                              : (isDark ? AppTheme.darkCard : Colors.white)
                                    .withOpacity(0.5),
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
                        'Không có lớp nào',
                        style: AppTheme.bodySmall.copyWith(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...filteredSchedule.map(
                    (item) => _buildScheduleItem(item, isDark),
                  ),
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
            color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                .withOpacity(0.3),
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
                  item.nhom != null && item.nhom!.trim().isNotEmpty
                      ? '${item.maMon.trim()}.${item.nhom!.trim()}'
                      : item.maMon.trim(),
                  style: AppTheme.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tenMon,
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.siSo} SV',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
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
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.phong ?? 'TBA',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
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

    final now = _selectedDate; // Use selected date, not current date
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _canNavigateToPreviousMonth()
                      ? () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                            );
                          });
                        }
                      : null,
                  icon: Icon(
                    Icons.chevron_left,
                    color: _canNavigateToPreviousMonth()
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.grey.shade400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy', 'vi').format(_selectedDate),
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _canNavigateToNextMonth()
                      ? () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                            );
                          });
                        }
                      : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color: _canNavigateToNextMonth()
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          // Calendar grid
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkCard : Colors.white)
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                        .withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    // Weekday headers
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient.scale(0.3),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                            .map((day) {
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                    // Calendar days
                    ...List.generate(
                      ((daysInMonth + firstWeekday - 1) / 7).ceil(),
                      (weekIndex) {
                        return Row(
                          children: List.generate(7, (dayIndex) {
                            // dayIndex: 0=CN(Sun), 1=T2(Mon), 2=T3(Tue), ..., 6=T7(Sat)
                            // firstWeekday: 1=Mon, 2=Tue, ..., 7=Sun (Dart weekday)
                            
                            // Calculate which day number should appear in this cell
                            // We need to find the offset from Sunday (day 0 of our grid)
                            final weekdayOffset = firstWeekday % 7; // Convert: Mon=1→1, Tue=2→2, ..., Sun=7→0
                            final dayNumber = weekIndex * 7 + dayIndex - weekdayOffset + 1;
                            
                            // Check if this is a valid day in current month
                            final isCurrentMonth = dayNumber >= 1 && dayNumber <= daysInMonth;
                            
                            // If not current month, calculate previous/next month day
                            int displayDay = dayNumber;
                            bool isPreviousMonth = false;
                            bool isNextMonth = false;
                            
                            if (dayNumber < 1) {
                              // Previous month
                              final prevMonth = DateTime(_selectedDate.year, _selectedDate.month, 0);
                              displayDay = prevMonth.day + dayNumber;
                              isPreviousMonth = true;
                            } else if (dayNumber > daysInMonth) {
                              // Next month
                              displayDay = dayNumber - daysInMonth;
                              isNextMonth = true;
                            }
                            
                            final day = isCurrentMonth ? DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              dayNumber,
                            ) : null;
                            
                            // Only check schedule for current month days
                            final daySchedule = isCurrentMonth && day != null ? (() {
                              final dayOfWeek = day.weekday; // 1=Mon, 2=Tue, ..., 7=Sun
                              final thuStr = (dayOfWeek == 7 ? '8' : '${dayOfWeek + 1}'); // 1(Mon)→2, 2(Tue)→3, 7(Sun)→8
                              return provider.schedule.where((item) {
                                if (item.thu == null) return false;
                                final thu = item.thu!.trim();
                                
                                // Check if class is on this weekday
                                if (thu != thuStr) return false;
                                
                                // Use helper function to check date range and cachTuan
                                return _shouldShowClassOnDate(item, day);
                              }).toList();
                            })() : <TeachingScheduleItem>[];
                            
                            final isToday = isCurrentMonth && day != null &&
                                day.day == DateTime.now().day &&
                                day.month == DateTime.now().month &&
                                day.year == DateTime.now().year;

                            return Expanded(
                              child: GestureDetector(
                                onTap: isCurrentMonth && daySchedule.isNotEmpty
                                    ? () => _showDayScheduleDialog(
                                        day!,
                                        daySchedule,
                                        isDark,
                                      )
                                    : null,
                                child: Container(
                                  height: 70,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? AppTheme.bluePrimary.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isToday
                                        ? Border.all(
                                            color: AppTheme.bluePrimary,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$displayDay',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: (isPreviousMonth || isNextMonth)
                                              ? (isDark ? Colors.grey.shade700 : Colors.grey.shade400)
                                              : (isDark ? Colors.white : Colors.black87),
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (isCurrentMonth && daySchedule.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: AppTheme.bluePrimary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

  Map<int, List<TeachingScheduleItem>> _getWeekSchedule(
    List<TeachingScheduleItem> schedule,
  ) {
    final Map<int, List<TeachingScheduleItem>> weekSchedule = {};
    for (int i = 0; i < 7; i++) {
      weekSchedule[i] = [];
    }
    
    for (final item in schedule) {
      if (item.thu == null) continue;
      
      final thu = item.thu!.trim();
      final thuInt = int.tryParse(thu);
      
      if (thuInt == null || thuInt < 2 || thuInt > 8) continue;
      
      // Convert Vietnamese day number to index: 2=Mon(0), 3=Tue(1), ..., 8=Sun(6)
      final dayIndex = thuInt == 8 ? 6 : thuInt - 2;
      
      if (dayIndex >= 0 && dayIndex < 7) {
        weekSchedule[dayIndex]!.add(item);
      }
    }
    
    return weekSchedule;
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return _selectedDate.isAfter(
          startOfWeek.subtract(const Duration(days: 1)),
        ) &&
        _selectedDate.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  int _getCurrentWeek() {
    return _getWeekNumber(DateTime.now());
  }

  // Helper to get the date for a specific day index in the current week
  DateTime _getDateForDayIndex(int dayIndex) {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    return startOfWeek.add(Duration(days: dayIndex));
  }

  // Check if a class should be shown on a specific date
  bool _shouldShowClassOnDate(TeachingScheduleItem item, DateTime date) {
    // Check if date is within course date range
    if (item.ngayBatDau != null && date.isBefore(item.ngayBatDau!)) return false;
    if (item.ngayKetThuc != null && date.isAfter(item.ngayKetThuc!)) return false;
    
    // Check cachTuan for biweekly classes
    if (item.cachTuan != null && item.cachTuan! > 1 && item.ngayBatDau != null) {
      // Get the target weekday from thu field
      final thuInt = int.tryParse(item.thu?.trim() ?? '');
      if (thuInt == null) return true; // If can't parse, don't filter by cachTuan
      
      // Convert Vietnamese thu (2-8) to Dart weekday (1-7)
      // thu: 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat, 8=Sun
      // Dart weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
      final targetWeekday = thuInt == 8 ? 7 : thuInt - 1;
      
      // Find the first class date (first occurrence on target weekday on/after ngayBatDau)
      final startDate = item.ngayBatDau!;
      int daysToAdd = (targetWeekday - startDate.weekday + 7) % 7;
      final firstClassDate = startDate.add(Duration(days: daysToAdd));
      
      // Calculate weeks difference from first class date
      final daysDiff = date.difference(firstClassDate).inDays;
      if (daysDiff < 0) return false; // Before first class
      
      final weeksDiff = daysDiff ~/ 7;
      if (weeksDiff % item.cachTuan! != 0) return false;
    }
    
    return true;
  }

  int _getWeekNumber(DateTime date) {
    // Tính tuần học từ đầu năm học (giả sử bắt đầu từ tuần 1 tháng 9)
    final currentYear = date.month >= 9 ? date.year : date.year - 1;
    final startOfAcademicYear = DateTime(currentYear, 9, 1);

    // Tìm thứ 2 đầu tiên của năm học
    final firstMonday = startOfAcademicYear.add(
      Duration(days: (8 - startOfAcademicYear.weekday) % 7),
    );

    if (date.isBefore(firstMonday)) {
      return 1;
    }

    final difference = date.difference(firstMonday).inDays;
    final weekNumber = (difference / 7).floor() + 1;

    // Giới hạn trong học kỳ (tuần 1-20)
    return weekNumber.clamp(1, 20);
  }

  void _showDayScheduleDialog(
    DateTime day,
    List<TeachingScheduleItem> schedule,
    bool isDark,
  ) {
    final filteredSchedule = schedule.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.tenMon.toLowerCase().contains(_searchQuery) ||
          item.maMon.toLowerCase().contains(_searchQuery);
    }).toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkCard : Colors.white).withOpacity(
                  0.9,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE', 'vi').format(day),
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(day),
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView(
                      shrinkWrap: true,
                      children: filteredSchedule
                          .map((item) => _buildScheduleItem(item, isDark))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canNavigateToPreviousMonth() {
    final provider = context.read<LecturerProvider>();
    if (provider.schedule.isEmpty) return true;
    
    // Tìm ngày bắt đầu sớm nhất trong lịch giảng
    DateTime? earliestDate;
    for (final item in provider.schedule) {
      if (item.ngayBatDau != null) {
        if (earliestDate == null || item.ngayBatDau!.isBefore(earliestDate)) {
          earliestDate = item.ngayBatDau;
        }
      }
    }
    
    if (earliestDate == null) return true;
    
    final previousMonth = DateTime(_selectedDate.year, _selectedDate.month - 1);
    final minDate = DateTime(earliestDate.year, earliestDate.month, 1);
    
    return previousMonth.isAfter(minDate) || 
           (previousMonth.year == minDate.year && previousMonth.month == minDate.month);
  }

  bool _canNavigateToNextMonth() {
    final provider = context.read<LecturerProvider>();
    if (provider.schedule.isEmpty) return true;
    
    // Tìm ngày kết thúc muộn nhất trong lịch giảng
    DateTime? latestDate;
    for (final item in provider.schedule) {
      if (item.ngayKetThuc != null) {
        if (latestDate == null || item.ngayKetThuc!.isAfter(latestDate)) {
          latestDate = item.ngayKetThuc;
        }
      }
    }
    
    if (latestDate == null) return true;
    
    final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
    final maxDate = DateTime(latestDate.year, latestDate.month, 1);
    
    return nextMonth.isBefore(maxDate) || 
           (nextMonth.year == maxDate.year && nextMonth.month == maxDate.month);
  }
}
