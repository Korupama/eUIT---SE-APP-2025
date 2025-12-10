import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool tuition = true;
  bool exams = true;
  bool events = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC);
    final card = isDark ? AppTheme.darkCard : AppTheme.lightCard;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('notification_customization')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: card,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(loc.t('tuition')),
                  value: tuition,
                  onChanged: (v) => setState(() => tuition = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.t('exams')),
                  value: exams,
                  onChanged: (v) => setState(() => exams = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(loc.t('events')),
                  value: events,
                  onChanged: (v) => setState(() => events = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
