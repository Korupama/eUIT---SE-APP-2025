import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../models/notification_item.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForCategory(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.ketQuaHocTap:
        return Icons.grade;
      case NotificationCategory.baoBu:
        return Icons.event;
      case NotificationCategory.baoNghi:
        return Icons.cancel;
      case NotificationCategory.diemRenLuyen:
        return Icons.stars;
      case NotificationCategory.general:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForCategory(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.ketQuaHocTap:
        return Colors.blue;
      case NotificationCategory.baoBu:
        return Colors.orange;
      case NotificationCategory.baoNghi:
        return Colors.red;
      case NotificationCategory.diemRenLuyen:
        return Colors.green;
      case NotificationCategory.general:
        return AppTheme.bluePrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        title: Text(loc.t('notifications'), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        elevation: 1,
        actions: [
          if (provider.unreadNotificationCount > 0)
            TextButton(
              onPressed: () => provider.markAllNotificationsAsRead(),
              child: Text(
                'Đọc tất cả',
                style: TextStyle(color: AppTheme.bluePrimary),
              ),
            ),
        ],
      ),
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thông báo',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = notifications[index];
                final categoryColor = _getColorForCategory(n.category);
                final categoryIcon = _getIconForCategory(n.category);

                return Material(
                  color: isDark ? const Color(0xFF1E293B).withAlpha(153) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: n.isUnread
                            ? LinearGradient(colors: [categoryColor, categoryColor.withAlpha(180)])
                            : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade200]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: n.isUnread ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: n.isUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (n.body != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            n.body!,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          n.time,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: n.isUnread
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      provider.markNotificationAsRead(n.id);
                    },
                  ),
                );
              },
            ),
    );
  }
}

