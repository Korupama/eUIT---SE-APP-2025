// lib/screens/schedule/schedule_item.dart

class ScheduleItem {
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String type;

  ScheduleItem({
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.room,
    required this.type,
  });
}
