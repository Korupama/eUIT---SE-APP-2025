enum NotificationCategory {
  general,
  ketQuaHocTap,
  baoBu,
  baoNghi,
  diemRenLuyen,
}

class NotificationItem {
  final String id;
  final String title;
  final String? body;
  final String time;
  final bool isUnread;
  final NotificationCategory category;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // Dữ liệu gốc từ server

  NotificationItem({
    String? id,
    required this.title,
    this.body,
    this.time = '1 giờ trước',
    this.isUnread = true,
    this.category = NotificationCategory.general,
    DateTime? createdAt,
    this.data,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  NotificationItem copyWith({
    String? title,
    String? body,
    String? time,
    bool? isUnread,
    NotificationCategory? category,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      isUnread: isUnread ?? this.isUnread,
      category: category ?? this.category,
      createdAt: createdAt,
      data: data ?? this.data,
    );
  }
}
