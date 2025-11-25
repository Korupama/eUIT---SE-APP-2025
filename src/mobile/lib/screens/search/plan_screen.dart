import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // returns current DateTime (separate function for easier testing/overriding)
  DateTime now() => DateTime.now();

  final List<Map<String, dynamic>> academicEvents = [
    {
      'date': '05/08/2024 - 11/08/2024',
      'title': 'Tuần sinh hoạt công dân sinh viên đầu khóa',
      'color': Color(0xFF3B82F6),
    },
    {
      'date': '12/08/2024',
      'title': 'Bắt đầu học kỳ 1 năm học 2024-2025',
      'color': Color(0xFF3B82F6),
    },
    {
      'date': '02/09/2024',
      'title': 'Nghỉ lễ Quốc Khánh',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '07/10/2024 - 12/10/2024',
      'title': 'Thi giữa kỳ',
      'color': Color(0xFFF59E0B),
    },
    {
      'date': '16/12/2024 - 28/12/2024',
      'title': 'Thi kết thúc học phần học kỳ 1',
      'color': Color(0xFFF59E0B),
    },
    {
      'date': '01/01/2025',
      'title': 'Nghỉ Tết Dương lịch',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '27/01/2025 - 08/02/2025',
      'title': 'Nghỉ Tết Nguyên Đán',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '17/02/2025',
      'title': 'Bắt đầu học kỳ 2 năm học 2024-2025',
      'color': Color(0xFF3B82F6),
    },
    {
      'date': '30/04/2025',
      'title': 'Nghỉ lễ Giải phóng miền Nam',
      'color': Color(0xFFEF4444),
    },
    {
      'date': '01/05/2025',
      'title': 'Nghỉ lễ Quốc tế Lao động',
      'color': Color(0xFFEF4444),
    },
  ];

  // parse a single date string in dd/MM/yyyy
  DateTime _parseDate(String s) {
    final parts = s.trim().split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date format: $s');
    }
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  // parse a date or range like "dd/MM/yyyy" or "dd/MM/yyyy - dd/MM/yyyy"
  List<DateTime> _parseRange(String s) {
    final parts = s.split(RegExp(r'\s*[-–—]\s*'));
    final start = _parseDate(parts[0]);
    final end = parts.length > 1 ? _parseDate(parts[1]) : start;
    // normalize to date-only (time 00:00)
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return [startDate, endDate];
  }

  bool _isNowInRange(String dateRange) {
    final range = _parseRange(dateRange);
    final today = now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return !todayDate.isBefore(range[0]) && !todayDate.isAfter(range[1]);
  }

  // --- New fields for auto-scroll and focus ---
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey> _itemKeys = [];
  int _focusedIndex = -1; // item we scrolled to / highlighted
  bool _hasNow = false; // true when an item contains today's date

  @override
  void initState() {
    super.initState();
    // create keys for each timeline item
    _itemKeys = List.generate(academicEvents.length, (_) => GlobalKey());

    // after first frame, find the index to focus and scroll to it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineFocusAndScroll();
    });
  }

  void _determineFocusAndScroll() {
    try {
      final today = DateTime(now().year, now().month, now().day);

      // 1) try to find an event that contains today
      for (var i = 0; i < academicEvents.length; i++) {
        final r = _parseRange(academicEvents[i]['date'] as String);
        if (!today.isBefore(r[0]) && !today.isAfter(r[1])) {
          setState(() {
            _focusedIndex = i;
            _hasNow = true;
          });
          _ensureVisible(i);
          return;
        }
      }

      // 2) no exact match: find first event that has an end date >= today (upcoming or covering today)
      for (var i = 0; i < academicEvents.length; i++) {
        final r = _parseRange(academicEvents[i]['date'] as String);
        if (!r[1].isBefore(today)) {
          setState(() {
            _focusedIndex = i;
            _hasNow = false;
          });
          _ensureVisible(i);
          return;
        }
      }

      // 3) all events are before today -> focus last
      setState(() {
        _focusedIndex = academicEvents.length - 1;
        _hasNow = false;
      });
      _ensureVisible(_focusedIndex);
    } catch (e) {
      // ignore and don't crash UI
    }
  }

  void _ensureVisible(int index) {
    if (index < 0 || index >= _itemKeys.length) return;
    final ctx = _itemKeys[index].currentContext;
    if (ctx == null) return;
    try {
      Scrollable.ensureVisible(ctx, duration: Duration(milliseconds: 400), alignment: 0.15);
    } catch (e) {
      // ignore
    }
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
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
          'Kế hoạch năm học 2024-2025',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Top banner showing today and whether it's inside an event
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.06)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Today: ${_formatDate(now())}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Spacer(),
                      if (_focusedIndex >= 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _hasNow ? Colors.greenAccent : Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _hasNow ? 'IN CURRENT TIMELINE' : 'NEAREST',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // timeline items
                ...academicEvents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  final isLast = index == academicEvents.length - 1;
                  final isNow = _isNowInRange(event['date'] as String);
                  final isFocused = index == _focusedIndex;

                  return Container(
                    key: _itemKeys[index],
                    child: _buildTimelineItem(
                      date: event['date'] as String,
                      title: event['title'] as String,
                      color: event['color'] as Color,
                      isLast: isLast,
                      isNow: isNow,
                      isFocused: isFocused,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String title,
    required Color color,
    required bool isLast,
    required bool isNow,
    bool isFocused = false,
  }) {
    final indicatorSize = isNow ? 20.0 : 16.0;
    final borderColor = isNow ? Colors.greenAccent : Color(0xFF0F172A);
    final shadowColor = isNow
        ? Colors.greenAccent.withAlpha((0.4 * 255).round())
        : color.withAlpha((0.5 * 255).round());

    // subtle highlight for focused item
    final focusedDecoration = isFocused
        ? BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.06)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(255, 255, 255, 0.02),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          )
        : null;

    return IntrinsicHeight(
      child: Container(
        decoration: focusedDecoration,
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // visible accent stripe when focused
            Container(
              width: 6,
              height: 56,
              margin: EdgeInsets.only(right: 10, top: 6),
              decoration: BoxDecoration(
                color: isFocused ? Colors.amberAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Timeline indicator
            Column(
              children: [
                // Circle
                Container(
                  width: indicatorSize,
                  height: indicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: borderColor,
                      width: isNow ? 3 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: isNow ? 12 : 8,
                        spreadRadius: isNow ? 2 : 1,
                      ),
                    ],
                  ),
                ),

                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            color,
                            color.withAlpha((0.3 * 255).round()),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 16),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date row with optional NOW badge
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            color: isNow ? Colors.greenAccent : color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (isNow) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NOW',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (!isNow && isFocused) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NEAREST',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 6),

                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

