import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';

/// HomeScreen - Trang chủ Light Theme với bố cục mới
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          // Animated background cho Dark Mode
          if (isDark)
            const Positioned.fill(
              child: AnimatedBackground(isDark: true),
            ),

          // Main scrollable content
          SafeArea(
            child: provider.isLoading
                ? _buildShimmerLoading(isDark)
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    color: AppTheme.bluePrimary,
                    backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 84, // Updated from 88 to match new bottom nav height (68 + 16)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header mới (Scrollable)
                          _buildScrollableHeader(provider, isDark),
                          const SizedBox(height: 24),

                          // Next Schedule Section
                          _buildSectionTitle(loc.t('next_schedule'), isDark),
                          const SizedBox(height: 12),
                          _buildNextScheduleCard(provider, loc, isDark),
                          const SizedBox(height: 24),

                          // Quick Actions Section (SQUIRCLE)
                          _buildSectionTitle(loc.t('quick_actions'), isDark),
                          const SizedBox(height: 12),
                          _buildQuickActionsGrid(provider, isDark),
                          const SizedBox(height: 24),

                          // Notifications Section
                          _buildSectionTitle(loc.t('new_notifications'), isDark),
                          const SizedBox(height: 12),
                          _buildNotificationsList(provider, isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Header mới - Scrollable với BackdropFilter
  Widget _buildScrollableHeader(HomeProvider provider, bool isDark) {
    final unreadCount = provider.notifications.where((n) => n.isUnread).length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkBackground.withAlpha(242) // 0.95 opacity
                : Colors.white.withAlpha(229), // 0.9 opacity
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(26) // 0.1 opacity
                  : Colors.grey.shade200.withAlpha(204), // 0.8 opacity
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Avatar + Name/MSSV
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MSSV: 20520001',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right: Notification Bell
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      print('Notification tapped');
                    },
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Next Schedule Card với BackdropFilter và visual hierarchy
  Widget _buildNextScheduleCard(HomeProvider provider, AppLocalizations loc, bool isDark) {
    final schedule = provider.nextSchedule;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      const Color(0xFF1E293B).withAlpha(229), // 0.9 opacity
                      const Color(0xFF1E293B).withAlpha(204), // 0.8 opacity
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withAlpha(242), // 0.95 opacity
                      Colors.white.withAlpha(242),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppTheme.bluePrimary.withAlpha(76) // 0.3 opacity
                  : AppTheme.bluePrimary.withAlpha(51), // 0.2 opacity
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppTheme.bluePrimary.withAlpha(26) // 0.1 opacity
                    : Colors.black.withAlpha(13),
                blurRadius: isDark ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time badge
              Text(
                schedule.timeRange,
                style: TextStyle(
                  color: isDark ? AppTheme.bluePrimary : AppTheme.bluePrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Course code
              Text(
                schedule.courseCode,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),

              // Course name
              Text(
                schedule.courseName,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Details with Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDetailChip('Phòng: ${schedule.room}', isDark),
                  _buildDetailChip('GV: ${schedule.lecturer}', isDark),
                ],
              ),
              const SizedBox(height: 14),

              // Countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.t('starts_in'),
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    schedule.countdown,
                    style: TextStyle(
                      color: isDark ? AppTheme.bluePrimary : AppTheme.bluePrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // View schedule button
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.bluePrimary,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(loc.t('view_full_schedule')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, bool isDark) {
    return Chip(
      label: Text(label),
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // Quick Actions Grid - SQUIRCLE với Gradients
  Widget _buildQuickActionsGrid(HomeProvider provider, bool isDark) {
    final actions = provider.quickActions;

    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: actions.asMap().entries.map((entry) {
        return _buildSquircleActionButton(
          entry.value,
          isDark,
          entry.key,
        );
      }).toList(),
    );
  }

  Widget _buildSquircleActionButton(dynamic action, bool isDark, int index) {
    // Định nghĩa gradients cho từng action
    final gradients = [
      [const Color(0xFF4D7FFF), const Color(0xFF2F6BFF)], // Thẻ SV - Xanh dương
      [const Color(0xFF60A5FA), const Color(0xFF3B82F6)], // Kết quả - Xanh nhạt
      [const Color(0xFFA855F7), const Color(0xFF9333EA)], // TKB - Tím
      [const Color(0xFF22C55E), const Color(0xFF16A34A)], // Học phí - Xanh lá
      [const Color(0xFFF97316), const Color(0xFFEA580C)], // Gửi xe - Cam
      [const Color(0xFFEC4899), const Color(0xFFDB2777)], // Phúc khảo - Hồng
      [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // GXN - Xanh lam
      [const Color(0xFF14B8A6), const Color(0xFF0D9488)], // Chứng chỉ - Xanh ngọc
    ];

    final gradient = index < gradients.length
        ? gradients[index]
        : [const Color(0xFF4D7FFF), const Color(0xFF2F6BFF)];

    IconData? icon;
    switch (action.iconName) {
      case 'school_outlined':
        icon = Icons.school_outlined;
        break;
      case 'calendar_today_outlined':
        icon = Icons.calendar_today_outlined;
        break;
      case 'monetization_on_outlined':
        icon = Icons.monetization_on_outlined;
        break;
      case 'edit_document':
        icon = Icons.edit_document;
        break;
      case 'check_box_outlined':
        icon = Icons.check_box_outlined;
        break;
      case 'description_outlined':
        icon = Icons.description_outlined;
        break;
      case 'workspace_premium_outlined':
        icon = Icons.workspace_premium_outlined;
        break;
      default:
        icon = Icons.circle_outlined;
    }

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Squircle button
          GestureDetector(
            onTap: () {
              print('Tapped: ${action.label}');
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withAlpha(76),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: action.textIcon != null
                    ? Text(
                        action.textIcon!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Label
          Text(
            action.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Notifications List với BackdropFilter
  Widget _buildNotificationsList(HomeProvider provider, bool isDark) {
    final notifications = provider.notifications.take(3).toList();

    return Column(
      children: notifications.map((notification) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B).withAlpha(153) // 0.6 opacity
                      : Colors.white.withAlpha(204), // 0.8 opacity
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(13) // 0.05 opacity
                        : Colors.grey.shade100,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: notification.isUnread
                          ? const LinearGradient(
                              colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: notification.isUnread ? Colors.white : Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: notification.body != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            notification.body!,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : null,
                  trailing: notification.isUnread
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.bluePrimary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    print('Tapped notification: ${notification.title}');
                  },
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(200, 48, isDark),
          const SizedBox(height: 24),
          _shimmerBox(double.infinity, 200, isDark),
          const SizedBox(height: 24),
          _shimmerBox(150, 24, isDark),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            children: List.generate(8, (index) => _shimmerBox(80, 100, isDark)),
          ),
          const SizedBox(height: 24),
          _shimmerBox(150, 24, isDark),
          const SizedBox(height: 12),
          _shimmerBox(double.infinity, 80, isDark),
          const SizedBox(height: 12),
          _shimmerBox(double.infinity, 80, isDark),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppTheme.darkCard : Colors.grey.shade300,
      highlightColor: isDark ? const Color(0xFF2A3A4D) : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
