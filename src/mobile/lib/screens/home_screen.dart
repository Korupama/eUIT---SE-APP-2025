import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/student_id_card.dart';

/// HomeScreen - Trang chủ Light Theme với bố cục mới
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
            child: provider.isLoading
                ? _buildShimmerLoading(isDark)
                : RefreshIndicator(
                    onRefresh: () async {
                      try {
                        // Refresh both quick GPA and next class when user pulls to refresh
                        await Future.wait([provider.fetchQuickGpa(), provider.fetchNextClass()]);
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
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom:
                            84, // Updated from 88 to match new bottom nav height (68 + 16)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header mới (Scrollable)
                          _buildScrollableHeader(provider, isDark, loc),
                          const SizedBox(height: 24),

                          // Next Schedule Section
                          _buildSectionTitle(loc.t('next_schedule'), isDark),
                          const SizedBox(height: 12),
                          _buildNextScheduleCard(provider, loc, isDark),
                          const SizedBox(height: 24),

                          // Student card + GPA placed before Notifications
                          _buildStudentInfoCards(loc, isDark, provider),
                          const SizedBox(height: 24),

                          // Notifications Section (show single item + View all)
                          _buildSectionTitle(
                            loc.t('new_notifications'),
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationsList(provider, isDark, loc, maxItems: 1),
                          const SizedBox(height: 16),

                          // Quick Actions Section (SQUIRCLE)
                          _buildSectionTitle(loc.t('quick_actions'), isDark),
                          const SizedBox(height: 12),
                          _buildQuickActionsGrid(provider, isDark),
                          const SizedBox(height: 24),

                          // Notifications Section
                          // _buildSectionTitle(
                          //   loc.t('new_notifications'),
                          //   isDark,
                          // ),
                          // const SizedBox(height: 12),
                          // _buildNotificationsList(provider, isDark),
                          // const SizedBox(height: 20),

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
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), // nhẹ, hiển thị nền động phía sau
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard.withAlpha(160) : Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(16),
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
                      width: 48,
                      height: 48,
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
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          'assets/icons/logo-uit.svg',
                          // Force the logo to render in the primary blue color
                          colorFilter: const ColorFilter.mode(AppTheme.bluePrimary, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.studentCard?.hoTen ?? loc.t('student_name'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${loc.t('id')}: ${provider.studentCard?.mssv?.toString()}',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Right: Chatbot + Notification
              Row(
                children: [


                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
        fontSize: 18,
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
          padding: const EdgeInsets.all(20),
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
              color: isDark
                  ? AppTheme.bluePrimary.withAlpha(40) // reduced from 76 -> ~0.16
                  : AppTheme.bluePrimary.withAlpha(30), // reduced from 51
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
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Course name
                        LayoutBuilder(builder: (context, constraints) {
                          final courseStyle = TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          );
                          return _EllipsizeAtWord(
                            text: schedule.courseName,
                            style: courseStyle,
                            maxLines: 2,
                            maxWidth: constraints.maxWidth,
                          );
                        }),
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
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schedule.countdown,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.bluePrimary
                              : AppTheme.bluePrimary,
                          fontSize: 24,
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
                  _buildDetailChip('${loc.t('room')}: ${schedule.room}', isDark),
                  _buildDetailChip('${loc.t('lecturer')}: ${schedule.lecturer}', isDark),
                ],
              ),
              const SizedBox(height: 10), // Reduced space
              // View schedule button aligned to the right
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {},
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
      spacing: 12,
      runSpacing: 16,
      children: actions.asMap().entries.map((entry) {
        return _buildSquircleActionButton(entry.value, isDark, entry.key);
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
                    : Icon(icon, color: Colors.white, size: 28),
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
  Widget _buildNotificationsList(HomeProvider provider, bool isDark, AppLocalizations loc, {int maxItems = 3}) {
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
              margin: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withAlpha(153)
                          : Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: notifications[0].isUnread
                              ? const LinearGradient(colors: [AppTheme.bluePrimary, AppTheme.blueLight])
                              : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade200]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: notifications[0].isUnread ? Colors.white : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        notifications[0].title,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: notifications[0].body != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                notifications[0].body!,
                                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : null,
                      trailing: notifications[0].isUnread
                          ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.bluePrimary, shape: BoxShape.circle))
                          : null,
                      onTap: () => Navigator.pushNamed(context, '/notifications'),
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
              icon: Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.bluePrimary),
              label: Text(loc.t('view_all'), style: TextStyle(color: AppTheme.bluePrimary, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.bluePrimary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        ...notifications.map((notification) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withAlpha(153) : Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withAlpha(13) : Colors.grey.shade100),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: notification.isUnread
                              ? const LinearGradient(colors: [AppTheme.bluePrimary, AppTheme.blueLight])
                              : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade200]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: notification.isUnread ? Colors.white : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      title: Text(notification.title,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      subtitle: notification.body != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(notification.body!,
                                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            )
                          : null,
                      trailing: notification.isUnread
                          ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.bluePrimary, shape: BoxShape.circle))
                          : null,
                      onTap: () => {}
                    ),
                  ),
                ),
              ),
            )),

        // View all button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.bluePrimary),
            label: Text(loc.t('view_all'), style: const TextStyle(color: AppTheme.bluePrimary, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.bluePrimary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
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

  // Build 2 info cards (Student Card & GPA)
  Widget _buildStudentInfoCards(AppLocalizations loc, bool isDark, HomeProvider provider) {
    // Always render 2 cards on one row (each takes half width)
    final card1 = _buildStudentCard(loc, isDark);
    final card2 = _buildGpaCard(loc, isDark, provider);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: card1),
          const SizedBox(width: 12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Colors.white.withAlpha(13) : AppTheme.lightCard,
              border: Border.all(
                color: _hoverStudentCard
                    ? AppTheme.bluePrimary
                    : (isDark
                          ? Colors.white.withAlpha(26)
                          : AppTheme.lightBorder),
              ),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: AppTheme.bluePrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.t('student_card'),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpaCard(AppLocalizations loc, bool isDark, HomeProvider provider) {
    final secondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final gpaText = _isGpaVisible ? (provider.gpa != null ? '${provider.gpa!.toStringAsFixed(2)}/10.0' : '0.00/10.0') : '••••/10.0';
    final creditsText = _isGpaVisible ? (provider.soTinChiTichLuy != null ? '${loc.t('credits')}: ${provider.soTinChiTichLuy}' : '${loc.t('credits')}: 0') : '${loc.t('credits')}: •••';

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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gpaText,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  creditsText,
                  style: const TextStyle(
                    color: AppTheme.bluePrimary,
                    fontSize: 12,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: boxShadowColor,
              blurRadius: isHover ? 16 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            splashColor: AppTheme.bluePrimary.withAlpha(38),
            highlightColor: AppTheme.bluePrimary.withAlpha(20),
            child: Padding(padding: const EdgeInsets.all(16), child: child),
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth - 24),
            child: StudentIdCard(
              studentName: provider.studentCard?.hoTen ?? 'Nguyễn Văn A',
              studentId: provider.studentCard?.mssv?.toString() ?? '20520001',
              majorName: provider.studentCard?.nganhHoc ?? 'Khoa học máy tính',
            ),
          ),
        );
      },
    );
  }

  void _showGpaDialog(AppLocalizations loc, bool isDark, HomeProvider provider) {
    final gpa = provider.gpa;
    final credits = provider.soTinChiTichLuy;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            loc.t('gpa'),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.assessment_outlined,
                size: 48,
                color: AppTheme.bluePrimary,
              ),
              const SizedBox(height: 12),
              if (gpa != null)
                Text(
                  '${gpa.toStringAsFixed(2)}/10.0',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                )
              else
                Text(
                  loc.t('coming_soon'),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                gpa != null ? '${loc.t('credits')}: ${credits ?? 0}' : loc.t('gpa_details_soon'),
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.t('close')),
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

  const _EllipsizeAtWord({Key? key, required this.text, required this.style, required this.maxLines, required this.maxWidth}) : super(key: key);

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
      return Text(best, style: style, maxLines: maxLines, overflow: TextOverflow.clip);
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
      return Text(bestChar, style: style, maxLines: maxLines, overflow: TextOverflow.clip);
    }

    // As a last resort, show original text with ellipsis overflow (shouldn't reach here)
    return Text(text, style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
  }
}
