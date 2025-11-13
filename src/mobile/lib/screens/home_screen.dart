import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_colors.dart';
import '../utils/app_localizations.dart';
import '../models/quick_action.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   @override
   Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();
    // TODO: Implement skeleton loading here while provider is fetching data from API.
    const avatarUrl = 'https://ui-avatars.com/api/?name=Alex+Thompson&background=0D1B2A&color=fff';
    return Scaffold(
      backgroundColor: AppColorsTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.t('welcome_back'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Alex Thompson', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      ),
                      if (provider.notifications.any((n) => n.isUnread))
                        Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.redAccent,
                            child: Text(
                              provider.notifications.where((n) => n.isUnread).length.toString(),
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColorsTheme.cardBackground,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Next schedule title
              Text(loc.t('next_schedule'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              // Schedule card
              Hero(
                tag: 'next-schedule-card',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.nextSchedule.timeRange, style: const TextStyle(color: AppColorsTheme.primaryAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Text(provider.nextSchedule.courseCode, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(provider.nextSchedule.courseName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phòng: ${provider.nextSchedule.room}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Giảng viên: ${provider.nextSchedule.lecturer}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(loc.t('starts_in'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(provider.nextSchedule.countdown, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: AppColorsTheme.primaryAccent),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(loc.t('view_full_schedule')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // New notifications
              Text(loc.t('new_notifications'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  provider.notifications.first.title,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 30),
              // Student card & GPA (responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  // When narrow, stack vertically to avoid horizontal overflow
                  if (constraints.maxWidth < 360) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColorsTheme.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(radius: 18, backgroundColor: AppColorsTheme.background, child: Icon(Icons.person_outline, color: Colors.white)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Thẻ sinh viên', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColorsTheme.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(radius: 18, backgroundColor: AppColorsTheme.background, child: Icon(Icons.visibility_outlined, color: Colors.white)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('GPA', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                    SizedBox(height: 4),
                                    Text('3.42 • 112 tín chỉ', style: TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Default wide layout: side-by-side
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColorsTheme.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(radius: 18, backgroundColor: AppColorsTheme.background, child: Icon(Icons.person_outline, color: Colors.white)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Thẻ sinh viên', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColorsTheme.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(radius: 18, backgroundColor: AppColorsTheme.background, child: Icon(Icons.visibility_outlined, color: Colors.white)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('GPA', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                    SizedBox(height: 4),
                                    Text('3.42 • 112 tín chỉ', style: TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              // Quick actions header
              Text(loc.t('quick_actions'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              // Quick actions grid
              Wrap(
                spacing: 16,
                runSpacing: 18,
                alignment: WrapAlignment.start,
                children: provider.quickActions.map((a) => _QuickAction(data: a)).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final QuickAction data;
  const _QuickAction({required this.data});
  IconData? _resolveIcon() {
    if (data.textIcon != null) return null;
    switch (data.iconName) {
      case 'school_outlined':
        return Icons.school_outlined;
      case 'calendar_today_outlined':
        return Icons.calendar_today_outlined;
      case 'monetization_on_outlined':
        return Icons.monetization_on_outlined;
      case 'edit_document':
        return Icons.edit_document;
      case 'check_box_outlined':
        return Icons.check_box_outlined;
      case 'description_outlined':
        return Icons.description_outlined;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
  @override
  Widget build(BuildContext context) {
    final iconData = _resolveIcon();
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColorsTheme.background,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColorsTheme.primaryAccent, width: 2),
              ),
              alignment: Alignment.center,
              child: iconData != null
                  ? Icon(iconData, color: Colors.white, size: 24)
                  : Text(data.textIcon ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
