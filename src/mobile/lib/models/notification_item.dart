class NotificationItem {
  final String title;
  final String? body;
  final String time;
  final bool isUnread;

  NotificationItem({
    required this.title,
    this.body,
    this.time = '1 giờ trước',
    this.isUnread = false,
  });
}

