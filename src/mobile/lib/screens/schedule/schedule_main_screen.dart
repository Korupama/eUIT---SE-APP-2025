import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_schedule_modal.dart'; // Import modal file
import 'schedule_item.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../../models/schedule_models.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/app_localizations.dart';
import 'dart:developer' as developer;

class ScheduleMainScreen extends StatefulWidget {
  const ScheduleMainScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleMainScreen> createState() => _ScheduleMainScreenState();
}

class _ScheduleMainScreenState extends State<ScheduleMainScreen> {
  // currentWeekStart will point to Sunday (CN) of the displayed week
  late DateTime currentWeekStart;
  // selectedDay: 0 = CN ... 6 = T7 (weekday index within the displayed week)
  late int selectedDay; // 0 = CN ... 6 = T7
  int selectedTab = 0; // 0: Lên lớp, 1: Kiểm tra, 2: Cá nhân

  // Local personal events stored until backend confirms
  final Map<String, List<ScheduleItem>> _personalEvents =
      {}; // keyed by 'yyyy-M-d'

  // Lấy ngày hôm nay
  DateTime get today {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Lấy tuần bắt đầu của ngày hôm nay (CN - Sunday)
  DateTime get todayWeekStart {
    final now = DateTime.now();
    final index = now.weekday % 7; // Sunday -> 0
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: index));
  }

  // Kiểm tra có đang ở tuần hiện tại không
  bool get isCurrentWeek {
    // final now = DateTime.now();
    // int index = now.weekday % 7; // Sunday -> 0
    // final todayStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: index));

    final now = DateTime.now();
    final index = now.weekday % 7;
    final todayStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: index));

    return currentWeekStart.year == todayStart.year &&
        currentWeekStart.month == todayStart.month &&
        currentWeekStart.day == todayStart.day;
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    // CN = weekday 7 → index = 0
    int index = now.weekday % 7;

    // Tuần bắt đầu từ CN → CN = date - index days
    currentWeekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: index));

    selectedDay = index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScheduleProvider>();
      provider.fetchClasses(viewMode: 'week');
      provider.fetchExams();
    });
  }

  void changeWeek(int delta) {
    DateTime newWeek = currentWeekStart.add(Duration(days: 7 * delta));

    // Không cho xem quá khứ
    if (newWeek.isBefore(todayWeekStart)) {
      return;
    }

    setState(() {
      currentWeekStart = newWeek;
    });
  }

  // Hàm quay về ngày hôm nay
  void goToToday() {
    setState(() {
      currentWeekStart = todayWeekStart;
      final now = DateTime.now();
      selectedDay = now.weekday % 7; // 0..6
    });
  }

  void _addNewSchedule(ScheduleItem item) async {
    // Convert selected day to a DateTime
    List<DayInfo> weekDays = _getWeekDays();
    DayInfo selected = weekDays.firstWhere((d) => d.day == selectedDay);
    final date = selected.date;
    final key = '${date.year}-${date.month}-${date.day}';

    // Create a minimal PersonalEventRequest using selected date (09:00) as time
    final provider = context.read<ScheduleProvider>();
    final eventTime = DateTime(date.year, date.month, date.day, 9, 0);
    final personalReq = PersonalEventRequest(
      eventName: item.subject,
      time: eventTime,
      location: item.room,
      description: item.teacher,
    );

    final resp = await provider.createPersonalEvent(personalReq);
    if (resp != null && resp.success && resp.event != null) {
      // Use local cache keyed by date
      _personalEvents.putIfAbsent(key, () => []);
      _personalEvents[key]!.add(item);
      setState(() {});
    } else {
      // Fallback: still add locally so user sees the created item; backend may sync later
      _personalEvents.putIfAbsent(key, () => []);
      _personalEvents[key]!.add(item);
      setState(() {});
    }
  }

  List<ScheduleItem> _getClassesExamsAndPersonalForDate(DateTime date) {
    final provider = context.read<ScheduleProvider>();
    final List<ScheduleItem> results = [];

    // Classes from API
    final classes = provider.schedule?.classes ?? [];
    for (final c in classes) {
      if (_isClassOnDate(c, date)) {
        results.add(
          ScheduleItem(
            startTime: c.tietBatDau != null ? 'Tiết ${c.tietBatDau}' : '-',
            endTime: c.tietKetThuc != null ? 'Tiết ${c.tietKetThuc}' : '-',
            subject: c.tenMonHoc,
            room: c.phongHoc ?? 'N/A',
            type: 'class',
            teacher: c.tenGiangVien,
          ),
        );
      }
    }

    // Exams from API
    final exams = provider.exams?.exams ?? [];
    for (final e in exams) {
      if (_isSameDay(e.ngayThi, date)) {
        results.add(
          ScheduleItem(
            startTime: e.caThi,
            endTime: '',
            subject: e.tenMonHoc,
            room: e.phongThi ?? 'N/A',
            type: 'exam',
            teacher: e.tenGiangVien,
          ),
        );
      }
    }

    // Local personal events
    final key = '${date.year}-${date.month}-${date.day}';
    if (_personalEvents.containsKey(key)) {
      results.addAll(_personalEvents[key]!);
    }

    // Sort by startTime heuristic (class tiet or exam time string)
    return results;
  }

  bool _isClassOnDate(ScheduleClass s, DateTime date) {
    // Ignore if tietBatDau is null or thu is '*'
    if (s.tietBatDau == null || s.thu == '*') return false;
    if (s.ngayBatDau == null || s.ngayKetThuc == null) return false;
    if (date.isBefore(s.ngayBatDau!) || date.isAfter(s.ngayKetThuc!))
      return false;
    // Backend uses '2'->Monday ... '8'->Sunday. DateTime.weekday: Monday=1..Sunday=7
    final thuNum = int.tryParse(s.thu ?? '0');
    if (thuNum == null) return false;
    final expectedWeekday = thuNum - 1; // 2->1 (Monday)
    if (expectedWeekday != date.weekday) return false;
    // Calculate weekIndex from ngayBatDau
    final daysDiff = date.difference(s.ngayBatDau!).inDays;
    final weekIndex = (daysDiff / 7).floor() + 1;
    final cachTuan = s.cachTuan ?? 0;
    if (cachTuan == 2 && (weekIndex - 1) % 2 != 0)
      return false; // every 2 weeks, start from ngayBatDau
    // cachTuan=1 or 0: every week
    return true;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String getMonthYearDisplay() {
    final loc = AppLocalizations.of(context);
    List<DayInfo> weekDays = _getWeekDays();
    // Get the month that appears most in the current week
    Map<int, int> monthCount = {};
    for (var day in weekDays) {
      int month = day.date.month;
      monthCount[month] = (monthCount[month] ?? 0) + 1;
    }
    int dominantMonth = monthCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    int year = weekDays.first.date.year;

    return '${loc.t('month')} $dominantMonth/ $year';
  }

  void showMonthYearPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentWeekStart.isBefore(today) ? today : currentWeekStart,
      firstDate: today, // Chỉ cho chọn từ hôm nay trở đi
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4FFFED),
              onPrimary: Colors.black,
              surface: Color(0xFF1E2139),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Set to the Sunday (CN) of the selected week (consistent with CN->T7)
        final index = picked.weekday % 7; // Sunday -> 0
        currentWeekStart = DateTime(
          picked.year,
          picked.month,
          picked.day,
        ).subtract(Duration(days: index));
      });
    }
  }

  List<ScheduleItem> getScheduleForSelectedDay() {
    final weekDays = _getWeekDays();
    final selectedDayInfo = weekDays.firstWhere(
      (d) => d.day == selectedDay,
      orElse: () => weekDays[0],
    );
    final date = selectedDayInfo.date;
    final all = _getClassesExamsAndPersonalForDate(date);

    if (selectedTab == 0) return all.where((i) => i.type == 'class').toList();
    if (selectedTab == 1) return all.where((i) => i.type == 'exam').toList();
    return all.where((i) => i.type == 'personal').toList();
  }

  String getEmptyMessage() {
    final loc = AppLocalizations.of(context);
    switch (selectedTab) {
      case 1:
        return loc.t('no_exam_schedule');
      case 2:
        return loc.t('no_personal_schedule');
      default:
        return loc.t('no_schedule_today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    // Note: don't auto-change selectedDay during build. initial value is set in initState
    // and goToToday() will explicitly reset to today when requested by the user.
    final now = DateTime.now();
    final todayIndex = now.weekday % 7; // 0..6 (CN..T7)
    // Show "Hôm nay" when either the week or the selected day is not today's day
    final showTodayButton = !(isCurrentWeek && selectedDay == todayIndex);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.t('schedule_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      // Nút "Hôm nay" - chỉ hiện khi không ở tuần hiện tại
                      if (showTodayButton) ...[
                        GestureDetector(
                          onTap: goToToday,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // Replaced deprecated `.withOpacity()` with const ARGB color to avoid precision-loss warning
                              color: const Color(0x334FFFED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4FFFED),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              loc.t('today'),
                              style: const TextStyle(
                                color: Color(0xFF4FFFED),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // Use explicit ARGB instead of `withOpacity` (deprecated)
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Month Navigation
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: showMonthYearPicker,
                    child: Row(
                      children: [
                        Text(
                          getMonthYearDisplay(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          // Replaced deprecated withOpacity -> explicit ARGB
                          color: const Color(0xB3FFFFFF),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  // Chỉ hiện nút next week
                  IconButton(
                    onPressed: () => changeWeek(1),
                    icon: const Icon(Icons.chevron_right),
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Mini Calendar (Week View)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _getWeekDays().map((day) {
                  bool isSelected = day.day == selectedDay;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day.day;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          day.dayName,
                          style: const TextStyle(
                            color: Color(0x99FFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4FFFED)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.date.day}', // Update to use date.day
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tab Navigation
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2139),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTab(loc.t('class_tab'), 0),
                    _buildTab(loc.t('exam_tab'), 1),
                    _buildTab(loc.t('personal_tab'), 2),
                  ],
                ),
              ),
            ),

            // Schedule List
            Expanded(
              child: getScheduleForSelectedDay().isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: getScheduleForSelectedDay().length,
                      itemBuilder: (context, index) {
                        final item = getScheduleForSelectedDay()[index];
                        return _buildScheduleCard(item);
                      },
                    )
                  : Center(
                      child: Text(
                        getEmptyMessage(),
                        style: TextStyle(
                          color: const Color(0x80FFFFFF),
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog<void>(
            context: context,
            builder: (_) =>
                AddScheduleModal(onSave: (item) => _addNewSchedule(item)),
          );
        },
        backgroundColor: const Color(0xFF4FFFED),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF4FFFED), Color(0xFF2DD4BF)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xB3FFFFFF),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // Converted to ARGB (50% alpha)
          color: const Color(0x7F4FFFED),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            // Converted to ARGB (~20% alpha)
            color: Color(0x334FFFED),
            blurRadius: 20,
            spreadRadius: 0,
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
                '${item.startTime} - ${item.endTime}',
                style: const TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                AppLocalizations.of(context).t('room'),
                style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Thêm thông tin giảng viên
                    if (item.teacher.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.teacher,
                        style: const TextStyle(
                          color: Color(0xB3FFFFFF),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.room,
                style: const TextStyle(
                  color: Colors.white,
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

  List<DayInfo> _getWeekDays() {
    List<DayInfo> days = [];
    List<String> dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    // currentWeekStart BẮT ĐẦU TỪ CN
    for (int i = 0; i < 7; i++) {
      DateTime date = currentWeekStart.add(Duration(days: i));
      // DayInfo.day will hold weekday index (0..6) to match selectedDay
      days.add(DayInfo(dayNames[i], i, date));
    }

    return days;
  }
}

class DayInfo {
  final String dayName;
  final int day;
  final DateTime date;

  DayInfo(this.dayName, this.day, this.date);
}
