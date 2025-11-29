import 'package:flutter/material.dart';
import 'add_schedule_modal.dart'; // Import modal file
import 'schedule_item.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ScheduleMainScreen extends StatefulWidget {
  const ScheduleMainScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleMainScreen> createState() => _ScheduleMainScreenState();
}

class _ScheduleMainScreenState extends State<ScheduleMainScreen> {
  DateTime currentWeekStart = DateTime(2025, 11, 24); // Monday of the week (31 Sep doesn't exist, so week starts Sep 29)
  int selectedDay = 3; // Day of October (T4 - Thursday)
  int selectedTab = 0; // 0: Lên lớp, 1: Kiểm tra, 2: Cá nhân

  // Lấy ngày hôm nay
  DateTime get today {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Lấy tuần bắt đầu của ngày hôm nay (Monday)
  DateTime get todayWeekStart {
    DateTime now = today;
    return now.subtract(Duration(days: now.weekday - 1));
  }

  // Kiểm tra có đang ở tuần hiện tại không
  bool get isCurrentWeek {
    return currentWeekStart.year == todayWeekStart.year &&
        currentWeekStart.month == todayWeekStart.month &&
        currentWeekStart.day == todayWeekStart.day;
  }

  // Sample schedule data
  final Map<String, List<ScheduleItem>> scheduleData = {
    '2025-11-25': [
      ScheduleItem(
        startTime: '8:15 AM',
        endTime: '11:30 AM',
        subject: 'IE104 Internet và Công nghệ Web',
        room: 'B1.06',
        type: 'class',
        teacher: 'TS. Nguyễn Văn A', // Thêm tên giảng viên
      ),
      ScheduleItem(
        startTime: '13:00 PM',
        endTime: '16:15 PM',
        subject: 'Thực hành IE104 Internet và Công nghệ Web',
        room: 'B1.22',
        type: 'class',
        teacher: 'ThS. Trần Thị B', // Thêm tên giảng viên
      ),
    ],
    '2025-11-27': [
      ScheduleItem(
        startTime: '9:00 AM',
        endTime: '11:00 AM',
        subject: 'IT001 Nhập môn Lập trình',
        room: 'A2.03',
        type: 'class',
        teacher: 'PGS.TS. Phan Trọng Đĩnh', // Thêm tên giảng viên
      ),
    ],
    '2025-11-30': [
      ScheduleItem(
        startTime: '14:00 PM',
        endTime: '16:00 PM',
        subject: 'CS106 Cấu trúc dữ liệu',
        room: 'C1.15',
        type: 'class',
        teacher: 'TS. Phạm Thị D', // Thêm tên giảng viên
      ),
    ],
  };

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
      selectedDay = today.day;
    });
  }

  void _addNewSchedule(ScheduleItem item) {
    List<DayInfo> weekDays = _getWeekDays();
    DayInfo selected = weekDays.firstWhere((d) => d.day == selectedDay);

    String key = "${selected.date.year}-${selected.date.month}-${selected.date.day}";

    if (!scheduleData.containsKey(key)) {
      scheduleData[key] = [];
    }

    setState(() {
      scheduleData[key]!.add(item);
    });
  }

  String getMonthYearDisplay() {
    List<DayInfo> weekDays = _getWeekDays();
    // Get the month that appears most in the current week
    Map<int, int> monthCount = {};
    for (var day in weekDays) {
      int month = day.date.month;
      monthCount[month] = (monthCount[month] ?? 0) + 1;
    }
    int dominantMonth = monthCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    int year = weekDays.first.date.year;

    return 'Tháng $dominantMonth/ $year';
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
        // Set to the Monday of the selected week
        currentWeekStart = picked.subtract(Duration(days: picked.weekday - 1));
      });
    }
  }

  List<ScheduleItem> getScheduleForSelectedDay() {
    List<DayInfo> weekDays = _getWeekDays();
    DayInfo? selectedDayInfo = weekDays.firstWhere(
          (day) => day.day == selectedDay,
      orElse: () => weekDays[0],
    );

    String key = '${selectedDayInfo.date.year}-${selectedDayInfo.date.month}-${selectedDayInfo.date.day}';
    List<ScheduleItem> items = scheduleData[key] ?? [];

    // Lọc theo tab
    if (selectedTab == 0) {
      return items.where((item) => item.type == 'class').toList();
    } else if (selectedTab == 1) {
      return items.where((item) => item.type == 'exam').toList();
    } else {
      return items.where((item) => item.type == 'personal').toList();
    }
  }

  String getEmptyMessage() {
    switch (selectedTab) {
      case 1:
        return 'Không có lịch kiểm tra';
      case 2:
        return 'Không có lịch cá nhân';
      default:
        return 'Không có lịch hôm nay';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Lịch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      // Nút "Hôm nay" - chỉ hiện khi không ở tuần hiện tại
                      if (!isCurrentWeek) ...[
                        GestureDetector(
                          onTap: goToToday,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              // Replaced deprecated `.withOpacity()` with const ARGB color to avoid precision-loss warning
                              color: const Color(0x334FFFED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4FFFED),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Hôm nay',
                              style: TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
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
                            color: isSelected ? const Color(0xFF4FFFED) : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2139),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTab('Lên lớp', 0),
                    _buildTab('Kiểm tra', 1),
                    _buildTab('Cá nhân', 2),
                  ],
                ),
              ),
            ),

            // Schedule List
            Expanded(
              child: getScheduleForSelectedDay().isNotEmpty
                  ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          colors: [
            Color(0xFF1E293B),
            Color(0xFF1E3A8A),
          ],
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
              const Text(
                'Phòng',
                style: TextStyle(
                  color: Color(0x80FFFFFF),
                  fontSize: 12,
                ),
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

    // Start from Sunday (currentWeekStart is Monday, so subtract 1 day)
    DateTime sunday = currentWeekStart.subtract(const Duration(days: 1));

    for (int i = 0; i < 7; i++) {
      DateTime date = sunday.add(Duration(days: i));
      days.add(DayInfo(dayNames[i], date.day, date));
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
