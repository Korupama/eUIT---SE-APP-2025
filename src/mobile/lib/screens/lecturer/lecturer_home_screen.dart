import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/lecturer_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/lecturer_id_card.dart';

/// LecturerHomeScreen - Trang chủ cho giảng viên
class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({super.key});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ScrollController _scrollController;

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

  bool _hoverLecturerCard = false;
  bool _hoverClassCard = false;

  void _handleQuickAction(String actionType) {
    switch (actionType) {
      case 'lecturer_card':
        final loc = AppLocalizations.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        _showLecturerCardDialog(loc, isDark);
        break;
      case 'lecturer_classes':
        // Navigate to class list screen
        Navigator.pushNamed(context, '/lecturer_class_list');
        break;
      case 'lecturer_schedule':
        // Navigate to schedule screen
        Navigator.pushNamed(context, '/lecturer_schedule');
        break;
      case 'lecturer_grading':
        Navigator.pushNamed(context, '/lecturer_grade_management');
        break;
      case 'lecturer_appeals':
        Navigator.pushNamed(context, '/lecturer_appeals');
        break;
      case 'lecturer_documents':
        Navigator.pushNamed(context, '/lecturer_documents');
        break;
      case 'lecturer_exam_schedule':
        Navigator.pushNamed(context, '/lecturer_exam_schedule');
        break;
      case 'lecturer_confirmation_letter':
        Navigator.pushNamed(context, '/lecturer_confirmation_letter');
        break;
      case 'lecturer_tuition':
        Navigator.pushNamed(context, '/lecturer_tuition');
        break;
      case 'lecturer_absences':
        Navigator.pushNamed(context, '/lecturer_absences');
        break;
      case 'lecturer_makeup_classes':
        Navigator.pushNamed(context, '/lecturer_makeup_classes');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final loc = AppLocalizations.of(context);
    final provider = context.watch<LecturerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: provider.isLoading
            ? _buildShimmerLoading(isDark)
            : RefreshIndicator(
                onRefresh: () async => await provider.refresh(),
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
                    bottom: 84,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildScrollableHeader(provider, isDark, loc),
                      const SizedBox(height: 24),

                      // Next Class Section
                      _buildSectionTitle('Lớp tiếp theo', isDark),
                      const SizedBox(height: 12),
                      _buildNextClassCard(provider, loc, isDark),
                      const SizedBox(height: 24),

                      // Lecturer Info Cards
                      _buildLecturerInfoCards(loc, isDark, provider),
                      const SizedBox(height: 24),

                      // Notifications
                      _buildSectionTitle('Thông báo mới', isDark),
                      const SizedBox(height: 12),
                      _buildNotificationsList(
                        provider,
                        isDark,
                        loc,
                        maxItems: 1,
                      ),
                      const SizedBox(height: 16),

                      // Quick Actions
                      _buildSectionTitle('Truy cập nhanh', isDark),
                      const SizedBox(height: 12),
                      _buildQuickActionsGrid(provider, isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildScrollableHeader(
    LecturerProvider provider,
    bool isDark,
    AppLocalizations loc,
  ) {
    final unreadCount = provider.notifications.where((n) => n.isUnread).length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard.withAlpha(160)
                : Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(18) : AppTheme.lightBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/lecturer_profile'),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: isDark ? Colors.white24 : AppTheme.lightBorder,
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          'assets/icons/logo-uit.svg',
                          colorFilter: const ColorFilter.mode(
                            AppTheme.bluePrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.lecturerProfile?.hoTen ?? 'Giảng viên',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mã GV: ${provider.lecturerProfile?.maGv ?? ''}',
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
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/notifications'),
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

  Widget _buildNextClassCard(
    LecturerProvider provider,
    AppLocalizations loc,
    bool isDark,
  ) {
    final nextClass = provider.nextClass;

    if (nextClass == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withAlpha(140)
                  : Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(18)
                    : AppTheme.lightBorder,
              ),
            ),
            child: Center(
              child: Text(
                'Không có lớp sắp tới',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

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
                      const Color(0xFF1E293B).withAlpha(140),
                      const Color(0xFF1E293B).withAlpha(110),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withAlpha(180),
                      Colors.white.withAlpha(160),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppTheme.bluePrimary.withAlpha(40)
                  : AppTheme.bluePrimary.withAlpha(30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppTheme.bluePrimary.withAlpha(12)
                    : Colors.black.withAlpha(8),
                blurRadius: isDark ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _periodsToTimeRange(
                            int.tryParse(nextClass.tietBatDau ?? '1') ?? 1,
                            int.tryParse(nextClass.tietKetThuc ?? '3') ?? 3,
                          ),
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.bluePrimary
                                : AppTheme.bluePrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nextClass.maMon,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nextClass.tenMon,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Bắt đầu sau',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calculateCountdown(nextClass),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDetailChip(
                    'Phòng: ${nextClass.phong ?? 'N/A'}',
                    isDark,
                  ),
                  _buildDetailChip('Nhóm: ${nextClass.nhom ?? 'N/A'}', isDark),
                  _buildDetailChip('Sĩ số: ${nextClass.siSo ?? 0}', isDark),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.bluePrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Xem lịch giảng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateCountdown(dynamic nextClass) {
    try {
      final now = DateTime.now();
      final classDate = nextClass.ngayBatDau;

      if (classDate == null) return '---';

      final startPeriod = int.tryParse(nextClass.tietBatDau ?? '1') ?? 1;
      final classTime = _getClassStartTime(classDate, startPeriod);

      final difference = classTime.difference(now);

      if (difference.isNegative) return 'Đã bắt đầu';

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 24) {
        final days = hours ~/ 24;
        return '${days}d ${hours % 24}h';
      } else if (hours > 0) {
        return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return '---';
    }
  }

  DateTime _getClassStartTime(DateTime date, int period) {
    const Map<int, int> periodStartHour = {
      1: 7,
      2: 8,
      3: 9,
      4: 10,
      5: 10,
      6: 13,
      7: 13,
      8: 14,
      9: 15,
      0: 16,
    };
    const Map<int, int> periodStartMinute = {
      1: 30,
      2: 15,
      3: 0,
      4: 0,
      5: 45,
      6: 0,
      7: 45,
      8: 30,
      9: 30,
      0: 15,
    };

    final hour = periodStartHour[period] ?? 7;
    final minute = periodStartMinute[period] ?? 30;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _periodsToTimeRange(int startPeriod, int endPeriod) {
    const Map<int, String> startMap = {
      1: '7:30',
      2: '8:15',
      3: '9:00',
      4: '10:00',
      5: '10:45',
      6: '13:00',
      7: '13:45',
      8: '14:30',
      9: '15:30',
      0: '16:15',
    };
    const Map<int, String> endMap = {
      1: '8:15',
      2: '9:00',
      3: '9:45',
      4: '10:45',
      5: '11:30',
      6: '13:45',
      7: '14:30',
      8: '15:15',
      9: '16:15',
      0: '17:00',
    };

    final start = startMap[startPeriod] ?? '$startPeriod';
    final end = endMap[endPeriod] ?? '$endPeriod';
    return '$start - $end';
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

  Widget _buildQuickActionsGrid(LecturerProvider provider, bool isDark) {
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
    final gradients = [
      [const Color(0xFF4D7FFF), const Color(0xFF2F6BFF)], // Blue
      [const Color(0xFF60A5FA), const Color(0xFF3B82F6)], // Light Blue
      [const Color(0xFFA855F7), const Color(0xFF9333EA)], // Purple
      [const Color(0xFF22C55E), const Color(0xFF16A34A)], // Green
      [const Color(0xFFF97316), const Color(0xFFEA580C)], // Orange
      [const Color(0xFFEC4899), const Color(0xFFDB2777)], // Pink
      [const Color(0xFF0EA5E9), const Color(0xFF0284C7)], // Sky Blue
      [const Color(0xFFEF4444), const Color(0xFFDC2626)], // Red
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald
      [const Color(0xFFFBBF24), const Color(0xFFF59E0B)], // Amber
    ];

    final gradient = index < gradients.length
        ? gradients[index]
        : [const Color(0xFF4D7FFF), const Color(0xFF2F6BFF)];

    IconData icon;
    switch (action.iconName) {
      case 'badge_outlined':
        icon = Icons.badge_outlined;
        break;
      case 'calendar_today_outlined':
        icon = Icons.calendar_today_outlined;
        break;
      case 'groups_outlined':
        icon = Icons.groups_outlined;
        break;
      case 'edit_document':
        icon = Icons.edit_document;
        break;
      case 'rate_review':
        icon = Icons.rate_review;
        break;
      case 'description_outlined':
        icon = Icons.description_outlined;
        break;
      case 'event_note':
        icon = Icons.event_note;
        break;
      case 'verified':
        icon = Icons.verified;
        break;
      case 'event_busy':
        icon = Icons.event_busy;
        break;
      case 'event_available':
        icon = Icons.event_available;
        break;
      case 'payment':
        icon = Icons.payment;
        break;
      default:
        icon = Icons.circle_outlined;
    }

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _handleQuickAction(action.type),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient.map((c) => c.withOpacity(0.85)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 28)),
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildNotificationsList(
    LecturerProvider provider,
    bool isDark,
    AppLocalizations loc, {
    int maxItems = 3,
  }) {
    final notifications = provider.notifications.take(maxItems).toList();

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
                        color: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.grey.shade100,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: notifications[0].isUnread
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        notifications[0].title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: notifications[0].body != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                notifications[0].body!,
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
                      trailing: notifications[0].isUnread
                          ? Container(
                              width: 10,
                              height: 10,
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
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppTheme.bluePrimary,
              ),
              label: Text(
                loc.t('view_all'),
                style: const TextStyle(
                  color: AppTheme.bluePrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

    return const SizedBox.shrink();
  }

  Widget _buildLecturerInfoCards(
    AppLocalizations loc,
    bool isDark,
    LecturerProvider provider,
  ) {
    final card1 = _buildLecturerCard(loc, isDark);
    final card2 = _buildClassCountCard(loc, isDark, provider);
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

  Widget _buildLecturerCard(AppLocalizations loc, bool isDark) {
    return _buildHoverCard(
      isDark: isDark,
      isHover: _hoverLecturerCard,
      onHover: (v) => setState(() => _hoverLecturerCard = v),
      onTap: () => _showLecturerCardDialog(loc, isDark),
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
                color: _hoverLecturerCard
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
          const Expanded(
            child: Text(
              'Thẻ GV',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCountCard(
    AppLocalizations loc,
    bool isDark,
    LecturerProvider provider,
  ) {
    final secondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final classCount = provider.teachingSchedule.length;

    return _buildHoverCard(
      isDark: isDark,
      isHover: _hoverClassCard,
      onHover: (v) => setState(() => _hoverClassCard = v),
      onTap: () {},
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lớp giảng dạy',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$classCount',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'lớp học',
                  style: TextStyle(
                    color: AppTheme.bluePrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.groups_outlined, color: secondary, size: 32),
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

  void _showLecturerCardDialog(AppLocalizations loc, bool isDark) {
    final provider = Provider.of<LecturerProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth - 24),
            child: LecturerIdCard(
              lecturerName: provider.lecturerProfile?.hoTen ?? 'Giảng viên',
              lecturerId: provider.lecturerProfile?.maGv ?? '',
              department: provider.lecturerProfile?.khoaBoMon ?? '',
              email: provider.lecturerProfile?.email ?? '',
            ),
          ),
        );
      },
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
            children: List.generate(6, (index) => _shimmerBox(80, 100, isDark)),
          ),
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
