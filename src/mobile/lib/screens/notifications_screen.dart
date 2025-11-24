import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
      ),
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final n = notifications[index];
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
                      ? const LinearGradient(colors: [AppTheme.bluePrimary, AppTheme.blueLight])
                      : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade200]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: n.isUnread ? Colors.white : Colors.grey.shade600,
                ),
              ),
              title: Text(n.title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
              subtitle: n.body != null ? Text(n.body!, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)) : null,
              trailing: n.isUnread ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.bluePrimary, shape: BoxShape.circle)) : null,
              onTap: () {
                // For now just print; a future improvement could open a detail view and mark as read
                print('Open notification: ${n.title}');
              },
            ),
          );
        },
      ),
    );
  }
}

