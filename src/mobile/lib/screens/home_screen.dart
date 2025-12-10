import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/student_id_card.dart';
import '../widgets/quick_actions_settings_modal.dart';
import '../screens/search/studyresult_screen.dart';
import '../screens/search/tuition_screen.dart';
import '../screens/parking_monthly_screen.dart';
import '../screens/student_confirmation_screen.dart';
import '../screens/certificate_confirmation_screen.dart';
import '../screens/regrade_screen.dart';
import '../screens/introduction_letter_screen.dart';

/// HomeScreen - Trang chủ Light Theme với bố cục mới
class HomeScreen extends StatefulWidget {
  final void Function(int)? onSelectPage;
  const HomeScreen({Key? key, this.onSelectPage}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Post frame callback logic if needed
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Hover states for interactive cards
  bool _hoverStudentCard = false;
  bool _hoverGpaCard = false;

  // GPA visibility state
  bool _isGpaVisible = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context);
    final provider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            // Always render the main content. Individual sections can show shimmers/placeholders
            // based on provider state. This avoids hiding Quick Actions and Notifications while
            // a global prefetch runs in the background.
            child: RefreshIndicator(
              onRefresh: () async {
                try {
                  // Refresh both quick GPA and next class when user pulls to refresh
                  await Future.wait([
                    provider.fetchQuickGpa(),
                    provider.fetchNextClass(),
                  ]);
                } catch (_) {
                  // ignore network errors for UX continuity
                }
              },
              color: AppTheme.bluePrimary,
              backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 20.h,
                  bottom: 84
                      .h, // Updated from 88 to match new bottom nav height (68 + 16)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header mới (Scrollable)
                    _buildScrollableHeader(provider, isDark, loc),
                    SizedBox(height: 24.h),

                    // Next Schedule Section
                    _buildSectionTitle(loc.t('next_schedule'), isDark),
                    SizedBox(height: 12.h),
                    _buildNextScheduleCard(provider, loc, isDark),
                    SizedBox(height: 24.h),

                    // Student card + GPA placed before Notifications
                    _buildStudentInfoCards(loc, isDark, provider),
                    SizedBox(height: 24.h),

                    // Notifications Section (show single item + View all)
                    _buildSectionTitle(loc.t('new_notifications'), isDark),
                    SizedBox(height: 12.h),
                    _buildNotificationsList(provider, isDark, loc, maxItems: 1),
                    SizedBox(height: 16.h),

                    // Quick Actions Section (SQUIRCLE)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(loc.t('quick_actions'), isDark),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 24.r,
                          ),
                          tooltip: 'Tùy chỉnh thao tác nhanh',
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => QuickActionsSettingsModal(
                                enabledActions: provider.quickActions,
                                allAvailableActions:
                                    provider.allAvailableQuickActions,
                                onSave: (updatedActions) async {
                                  await provider.saveQuickActionsPreferences(
                                    updatedActions,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildQuickActionsGrid(provider, isDark),
                    SizedBox(height: 24.h),
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
  Widget _buildScrollableHeader(
    HomeProvider provider,
    bool isDark,
    AppLocalizations loc,
  ) {
    final unreadCount = provider.notifications.where((n) => n.isUnread).length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6,
          sigmaY: 6,
        ), // nhẹ, hiển thị nền động phía sau
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard.withAlpha(160)
                : Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(18) : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Avatar + Name/MSSV
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // White circular background with blue logo
                        color: Colors.white,
                        border: Border.all(
                          color: isDark ? Colors.white24 : AppTheme.lightBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(6.r),
                        child: SvgPicture.asset(
                          'assets/icons/logo-uit.svg',
                          // Force the logo to render in the primary blue color
                          colorFilter: const ColorFilter.mode(
                            AppTheme.bluePrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.studentCard?.hoTen ?? loc.t('student_name'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${loc.t('id')}: ${provider.studentCard?.mssv?.toString()}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Right: Chatbot + Notification
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/chatbot');
                      },
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.25),
                              blurRadius: 20.r,
                              spreadRadius: 1,
                              offset: Offset(0, 6.h),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.07),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.smart_toy,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/notifications'),
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 24.r,
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18.r,
                              minHeight: 18.r,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
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
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Next Schedule Card với BackdropFilter và visual hierarchy
  Widget _buildNextScheduleCard(
    HomeProvider provider,
    AppLocalizations loc,
    bool isDark,
  ) {
    final schedule = provider.nextSchedule;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Reduced opacity so animated background shows through
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      // lower alpha than before to allow background to be visible
                      const Color(0xFF1E293B).withAlpha(140), // ~0.55 opacity
                      const Color(0xFF1E293B).withAlpha(110), // ~0.43 opacity
                    ],
                  )
                : LinearGradient(
                    colors: [
                      // Allow more of the animated background in light mode
                      Colors.white.withAlpha(180), // ~0.7 opacity
                      Colors.white.withAlpha(160),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(18) : AppTheme.lightBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppTheme.bluePrimary.withAlpha(12) // lighter shadow
                    : Colors.black.withAlpha(8),
                blurRadius: isDark ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for Title and Countdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time badge
                        Text(
                          schedule.timeRange,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.bluePrimary
                                : AppTheme.bluePrimary,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Course name
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final courseStyle = TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            );
                            return _EllipsizeAtWord(
                              text: schedule.courseName,
                              style: courseStyle,
                              maxLines: 2,
                              maxWidth: constraints.maxWidth,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right side: Countdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        loc.t('starts_in'),
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.countdown,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.bluePrimary
                              : AppTheme.bluePrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Details with Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Localize
                  _buildDetailChip(
                    '${loc.t('room')}: ${schedule.room}',
                    isDark,
                  ),
                  _buildDetailChip(
                    '${loc.t('lecturer')}: ${schedule.lecturer}',
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 10), // Reduced space
              // View schedule button aligned to the right
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    // Always navigate to Schedule tab (index 3 in MainScreen)
                    if (widget.onSelectPage != null) {
                      widget.onSelectPage!(3);
                    } else {
                      Navigator.pushNamed(context, '/schedule');
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.bluePrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ), // Compact padding
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, // Reduce tap area
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(loc.t('view_full_schedule')),
                ),
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
      spacing: 12.w,
      runSpacing: 16.h,
      children: actions.asMap().entries.map((entry) {
        return _buildSquircleActionButton(
          entry.value,
          isDark,
          entry.key,
          widget.onSelectPage,
        );
      }).toList(),
    );
  }

  Widget _buildSquircleActionButton(
    dynamic action,
    bool isDark,
    int index,
    void Function(int)? onSelectPage,
  ) {
    final loc = AppLocalizations.of(context);
    // Định nghĩa gradients cho từng action
    final gradients = [
      [
        const Color(0xFF4D7FFF),
        const Color(0xFF2F6BFF),
      ], // Kết quả - Xanh dương
      [const Color(0xFF60A5FA), const Color(0xFF3B82F6)], // TKB - Xanh nhạt
      [const Color(0xFFA855F7), const Color(0xFF9333EA)], // Học phí - Tím
      [const Color(0xFF22C55E), const Color(0xFF16A34A)], // Gửi xe - Xanh lá
      [const Color(0xFFF97316), const Color(0xFFEA580C)], // Phúc khảo - Cam
      [const Color(0xFFEC4899), const Color(0xFFDB2777)], // GXN - Hồng
      [
        const Color(0xFF06B6D4),
        const Color(0xFF0891B2),
      ], // Confirmation - Xanh lam
      [
        const Color(0xFF14B8A6),
        const Color(0xFF0D9488),
      ], // Chứng chỉ - Xanh ngọc
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
      case 'directions_car_outlined':
        icon = Icons.directions_car_outlined;
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
      width: 80.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Squircle button
          GestureDetector(
            onTap: () {
              // Type-based navigation - more stable than index-based
              switch (action.type) {
                case 'schedule':
                  // Navigate to schedule tab via PageController
                  onSelectPage?.call(3);
                  break;

                case 'results':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudyResultScreen(),
                    ),
                  );
                  break;

                case 'tuition':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TuitionScreen()),
                  );
                  break;

                case 'parking':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParkingMonthlyScreen(),
                    ),
                  );
                  break;

                case 'reference':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IntroductionLetterScreen(),
                    ),
                  );
                  break;

                case 'certificate':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CertificateConfirmationScreen(),
                    ),
                  );
                  break;

                case 'regrade':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegradeScreen()),
                  );
                  break;

                case 'gxn':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentConfirmationScreen(),
                    ),
                  );
                  break;

                default:
                  // Show "đang phát triển" for unimplemented actions
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Chức năng đang phát triển'),
                      content: Text(action.label),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
              }
            },

            child: Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withAlpha(76),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Center(
                child: action.textIcon != null
                    ? Text(
                        action.textIcon!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(icon, color: Colors.white, size: 28.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // Label
          Text(
            loc.t(action.label),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.black87,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Notifications List với BackdropFilter
  Widget _buildNotificationsList(
    HomeProvider provider,
    bool isDark,
    AppLocalizations loc, {
    int maxItems = 3,
  }) {
    final all = provider.notifications;
    final notifications = all.take(maxItems).toList();

    // If we only want to show the latest one, render it and a footer button.
    if (maxItems == 1) {
      final hasOne = notifications.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasOne)
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withAlpha(153)
                          : Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.grey.shade100,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                      leading: Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          gradient: notifications[0].isUnread
                              ? const LinearGradient(
                                  colors: [
                                    AppTheme.bluePrimary,
                                    AppTheme.blueLight,
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade300,
                                    Colors.grey.shade200,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: notifications[0].isUnread
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 22.r,
                        ),
                      ),
                      title: Text(
                        notifications[0].title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: notifications[0].body != null
                          ? Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                notifications[0].body!,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 12.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : null,
                      trailing: notifications[0].isUnread
                          ? Container(
                              width: 10.r,
                              height: 10.r,
                              decoration: const BoxDecoration(
                                color: AppTheme.bluePrimary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      onTap: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                  ),
                ),
              ),
            ),

          // View all button (icon + localized label)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: Icon(
                Icons.arrow_forward_rounded,
                size: 18.r,
                color: AppTheme.bluePrimary,
              ),
              label: Text(
                loc.t('view_all'),
                style: TextStyle(
                  color: AppTheme.bluePrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.bluePrimary,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      );
    }

    // Default: render up to maxItems notifications with a footer button
    return Column(
      children: [
        // map each notification to a ListTile wrapped in blurred card
        ...notifications.map(
          (notification) => Container(
            margin: EdgeInsets.only(bottom: 12.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withAlpha(153)
                        : Colors.white.withAlpha(204),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(13)
                          : Colors.grey.shade100,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 16.w,
                    ),
                    leading: Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        gradient: notification.isUnread
                            ? const LinearGradient(
                                colors: [
                                  AppTheme.bluePrimary,
                                  AppTheme.blueLight,
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade200,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: notification.isUnread
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 22.r,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: notification.body != null
                        ? Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              notification.body!,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : null,
                    trailing: notification.isUnread
                        ? Container(
                            width: 10.r,
                            height: 10.r,
                            decoration: const BoxDecoration(
                              color: AppTheme.bluePrimary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () => {},
                  ),
                ),
              ),
            ),
          ),
        ),

        // View all button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: Icon(
              Icons.arrow_forward_rounded,
              size: 18.r,
              color: AppTheme.bluePrimary,
            ),
            label: Text(
              loc.t('view_all'),
              style: TextStyle(
                color: AppTheme.bluePrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.bluePrimary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(200.w, 48.h, isDark),
          SizedBox(height: 24.h),
          _shimmerBox(double.infinity, 200.h, isDark),
          SizedBox(height: 24.h),
          _shimmerBox(150.w, 24.h, isDark),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 16.h,
            children: List.generate(
              8,
              (index) => _shimmerBox(80.w, 100.h, isDark),
            ),
          ),
          SizedBox(height: 24.h),
          _shimmerBox(150.w, 24.h, isDark),
          SizedBox(height: 12.h),
          _shimmerBox(double.infinity, 80.h, isDark),
          SizedBox(height: 12.h),
          _shimmerBox(double.infinity, 80.h, isDark),
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
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  // Build 2 info cards (Student Card & GPA)
  Widget _buildStudentInfoCards(
    AppLocalizations loc,
    bool isDark,
    HomeProvider provider,
  ) {
    // Always render 2 cards on one row (each takes half width)
    final card1 = _buildStudentCard(loc, isDark);
    final card2 = _buildGpaCard(loc, isDark, provider);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: card1),
          SizedBox(width: 12.w),
          Expanded(child: card2),
        ],
      ),
    );
  }

  Widget _buildStudentCard(AppLocalizations loc, bool isDark) {
    return _buildHoverCard(
      isDark: isDark,
      isHover: _hoverStudentCard,
      onHover: (v) => setState(() => _hoverStudentCard = v),
      onTap: () => _showStudentCardDialog(loc, isDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: isDark ? Colors.white.withAlpha(13) : AppTheme.lightCard,
              border: Border.all(
                color: _hoverStudentCard
                    ? AppTheme.bluePrimary
                    : (isDark
                          ? Colors.white.withAlpha(26)
                          : AppTheme.lightBorder),
              ),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: AppTheme.bluePrimary,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              loc.t('student_card'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpaCard(
    AppLocalizations loc,
    bool isDark,
    HomeProvider provider,
  ) {
    final secondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final gpaText = _isGpaVisible
        ? (provider.gpa != null
              ? '${provider.gpa!.toStringAsFixed(2)}/10.0'
              : '0.00/10.0')
        : '••••/10.0';
    final creditsText = _isGpaVisible
        ? (provider.soTinChiTichLuy != null
              ? '${loc.t('credits')}: ${provider.soTinChiTichLuy}'
              : '${loc.t('credits')}: 0')
        : '${loc.t('credits')}: •••';

    return _buildHoverCard(
      isDark: isDark,
      isHover: _hoverGpaCard,
      onHover: (v) => setState(() => _hoverGpaCard = v),
      onTap: () => _showGpaDialog(loc, isDark, provider),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loc.t('gpa'),
                  style: TextStyle(
                    color: secondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  gpaText,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  creditsText,
                  style: TextStyle(
                    color: AppTheme.bluePrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isGpaVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: secondary,
            ),
            onPressed: () {
              setState(() {
                _isGpaVisible = !_isGpaVisible;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHoverCard({
    required Widget child,
    required bool isDark,
    required bool isHover,
    required VoidCallback onTap,
    required ValueChanged<bool> onHover,
  }) {
    final baseBorder = isDark
        ? Colors.white.withAlpha(26)
        : AppTheme.lightBorder;
    final borderColor = isHover ? AppTheme.bluePrimary : baseBorder;
    final boxShadowColor = isHover
        ? AppTheme.bluePrimary.withAlpha(76)
        : (isDark ? Colors.black.withAlpha(51) : Colors.black.withAlpha(25));

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard.withAlpha(191) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: boxShadowColor,
              blurRadius: isHover ? 16.r : 8.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: onTap,
            splashColor: AppTheme.bluePrimary.withAlpha(38),
            highlightColor: AppTheme.bluePrimary.withAlpha(20),
            child: Padding(padding: EdgeInsets.all(16.r), child: child),
          ),
        ),
      ),
    );
  }

  void _showStudentCardDialog(AppLocalizations loc, bool isDark) {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, // darken background for clarity
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth - 24.w),
            child: StudentIdCard(
              studentName: provider.studentCard?.hoTen ?? '{Họ và tên}',
              studentId: provider.studentCard?.mssv?.toString() ?? '{MSSV}',
              majorName: provider.studentCard?.nganhHoc ?? '{Ngành học}',
            ),
          ),
        );
      },
    );
  }

  void _showGpaDialog(
    AppLocalizations loc,
    bool isDark,
    HomeProvider provider,
  ) {
    final gpa = provider.gpa;
    final credits = provider.soTinChiTichLuy;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            loc.t('gpa'),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 48.r,
                color: AppTheme.bluePrimary,
              ),
              SizedBox(height: 12.h),
              if (gpa != null)
                Text(
                  '${gpa.toStringAsFixed(2)}/10.0',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                )
              else
                Text(
                  loc.t('coming_soon'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              SizedBox(height: 8.h),
              Text(
                gpa != null
                    ? '${loc.t('credits')}: ${credits ?? 0}'
                    : loc.t('gpa_details_soon'),
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.t('close'), style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }
}

// Helper widget: truncates text to whole-word boundary when adding ellipsis.
class _EllipsizeAtWord extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final double maxWidth;

  const _EllipsizeAtWord({
    Key? key,
    required this.text,
    required this.style,
    required this.maxLines,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    // Quick check: does the full text already fit?
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: maxLines,
    );
    tp.layout(maxWidth: maxWidth);
    if (!tp.didExceedMaxLines) {
      return Text(text, style: style, maxLines: maxLines);
    }

    // Try to fit as many whole words as possible, then append ellipsis
    final words = text.split(RegExp(r'\s+'));
    int low = 0;
    int high = words.length;
    String best = '';

    while (low <= high) {
      final mid = (low + high) >> 1;
      final candidate = words.take(mid).join(' ');
      final candWithEll = candidate.isEmpty ? '…' : '$candidate…';
      final tp2 = TextPainter(
        text: TextSpan(text: candWithEll, style: style),
        textDirection: textDirection,
        maxLines: maxLines,
      );
      tp2.layout(maxWidth: maxWidth);
      if (!tp2.didExceedMaxLines) {
        best = candWithEll;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    if (best.isNotEmpty) {
      return Text(
        best,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.clip,
      );
    }

    // Fallback: no whole word fits, do character-level binary search
    String bestChar = '';
    int lo = 0;
    int hi = text.length;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final cand = text.substring(0, mid);
      final candWithEll = '$cand…';
      final tp3 = TextPainter(
        text: TextSpan(text: candWithEll, style: style),
        textDirection: textDirection,
        maxLines: maxLines,
      );
      tp3.layout(maxWidth: maxWidth);
      if (!tp3.didExceedMaxLines) {
        bestChar = candWithEll;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    if (bestChar.isNotEmpty) {
      return Text(
        bestChar,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.clip,
      );
    }

    // As a last resort, show original text with ellipsis overflow (shouldn't reach here)
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
