import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/animated_background.dart';
import 'package:shimmer/shimmer.dart';
import 'chatbot.dart';

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
  bool _bubbleClosed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          // Animated background cho Dark Mode
          if (isDark)
            const Positioned.fill(child: AnimatedBackground(isDark: true)),

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

                          // Quick Actions Section (SQUIRCLE)
                          _buildSectionTitle(loc.t('quick_actions'), isDark),
                          const SizedBox(height: 12),
                          _buildQuickActionsGrid(provider, isDark),
                          const SizedBox(height: 24),

                          // Notifications Section
                          _buildSectionTitle(
                            loc.t('new_notifications'),
                            isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildNotificationsList(provider, isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),

          /// 🔥 Chatbot Bubble Button
          if (!_bubbleClosed)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              bottom: 90,
              right: 20,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: !_bubbleClosed ? 1 : 0.7,
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: !_bubbleClosed ? 1 : 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Bubble Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatbotScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.transparent,
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.white10 : Colors.black12,
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Center(
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: isDark ? Colors.white : Colors.black87,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      ///  Nút close bubble
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => setState(() => _bubbleClosed = true),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
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
                  // Avatar: tappable to show profile (temporary)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
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
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // RIGHT: Chatbot + Notification
              Row(
                children: [
                  // Chatbot Button (Circle) - Matching Theme
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatbotScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        /// 🎨 Gradient giống hệt bell notification
                        color: Colors.transparent,

                        /// 🌫️ Shadow giống bell
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppTheme.bluePrimary.withOpacity(0.3)
                                : Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],

                        /// Viền nhẹ giống bell notification
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                          width: 1.2,
                        ),
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Center(
                            child: Icon(
                              Icons.smart_toy,
                              size: 20,

                              /// Icon màu giống bell (trắng khi dark / đen khi light)
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Notification Bell
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
                        Text(
                          schedule.courseName,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
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
                  _buildDetailChip('Phòng: ${schedule.room}', isDark),
                  _buildDetailChip('GV: ${schedule.lecturer}', isDark),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: notification.isUnread
                          ? Colors.white
                          : Colors.grey.shade600,
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
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
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

  // Build 2 info cards (Student Card & GPA)
  Widget _buildStudentInfoCards(AppLocalizations loc, bool isDark) {
    // Always render 2 cards on one row (each takes half width)
    final card1 = _buildStudentCard(loc, isDark);
    final card2 = _buildGpaCard(loc, isDark);
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

  Widget _buildGpaCard(AppLocalizations loc, bool isDark) {
    final secondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return _buildHoverCard(
      isDark: isDark,
      isHover: _hoverGpaCard,
      onHover: (v) => setState(() => _hoverGpaCard = v),
      onTap: () => _showGpaDialog(loc, isDark),
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
                  _isGpaVisible ? '8.52/10.0' : '••••/10.0',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isGpaVisible
                      ? '${loc.t('credits')}: 128'
                      : '${loc.t('credits')}: •••',
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            loc.t('student_card'),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : AppTheme.lightCard,
                  border: Border.all(
                    color: isDark ? Colors.white24 : AppTheme.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 48,
                      color: AppTheme.bluePrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.t('coming_soon'),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.t('digital_student_card_preview'),
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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

  void _showGpaDialog(AppLocalizations loc, bool isDark) {
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
              Text(
                loc.t('coming_soon'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.t('gpa_details_soon'),
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
