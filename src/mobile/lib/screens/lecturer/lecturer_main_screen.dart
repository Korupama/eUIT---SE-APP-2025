import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'lecturer_home_screen.dart';
import 'lecturer_class_list_screen.dart';
import 'lecturer_schedule_screen.dart';
import '../settings_screen.dart';
import '../../widgets/draggable_chatbot_overlay.dart';
import '../../widgets/animated_background.dart';

class LecturerMainScreen extends StatefulWidget {
  const LecturerMainScreen({super.key});

  @override
  State<LecturerMainScreen> createState() => _LecturerMainScreenState();
}

class _LecturerMainScreenState extends State<LecturerMainScreen> {
  int _selectedIndex = 0; // home (index 0 is now home)

  late final List<Widget> _pages;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pages = [
      const KeepAliveWrapper(child: LecturerHomeScreen()),
      const KeepAliveWrapper(child: LecturerScheduleScreen()),
      const KeepAliveWrapper(child: LecturerClassListScreen()),
      const KeepAliveWrapper(child: SettingsScreen()),
    ];
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          _onNavTap(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFF020617),
        body: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBackground(isDark: isDark),
              ),
            ),
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                if (index != _selectedIndex) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              children: _pages,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCustomBottomNav(loc, isDark),
            ),
            const DraggableChatbotOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(AppLocalizations loc, bool isDark) {
    final double baseHeight = 75.0;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double barHeight = baseHeight + bottomInset;
    final double bgShift = 12.0;
    final double outerHeight = barHeight + bgShift;

    return SizedBox(
      height: outerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: bgShift,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF1E293B).withAlpha(200),
                              const Color(0xFF1E293B).withAlpha(180),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withAlpha(220),
                              Colors.white.withAlpha(220),
                            ],
                          ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppTheme.bluePrimary.withAlpha(40)
                            : AppTheme.bluePrimary.withAlpha(30),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppTheme.bluePrimary.withAlpha(18)
                            : Colors.black.withAlpha(10),
                        blurRadius: 16,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _NavItem(
                      index: 0,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.home_rounded,
                      label: 'Trang chủ',
                      isDark: isDark,
                      onTap: () => _onNavTap(0),
                    ),
                    _NavItem(
                      index: 1,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.calendar_month_rounded,
                      label: 'Lịch giảng',
                      isDark: isDark,
                      onTap: () => _onNavTap(1),
                    ),
                    _NavItem(
                      index: 2,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.groups_rounded,
                      label: 'Lớp học',
                      isDark: isDark,
                      onTap: () => _onNavTap(2),
                    ),
                    _NavItem(
                      index: 3,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.settings_rounded,
                      label: 'Cài đặt',
                      isDark: isDark,
                      onTap: () => _onNavTap(3),
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
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData iconData;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.iconData,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 1.0, end: selectedIndex == index ? 1.03 : 1.0),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 2, right: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _computeBubbleSize(index, selectedIndex),
                      height: _computeBubbleSize(index, selectedIndex),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF1E293B).withAlpha(200),
                                  const Color(0xFF1E293B).withAlpha(180),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.white.withAlpha(230),
                                  Colors.white.withAlpha(230),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedIndex == index
                              ? (isDark
                                  ? AppTheme.bluePrimary.withAlpha(200)
                                  : AppTheme.bluePrimary)
                              : (index == 0
                                  ? AppTheme.bluePrimary
                                  : (isDark
                                      ? Colors.white.withAlpha(200)
                                      : Colors.black45)),
                          width: selectedIndex == index ? 1.4 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppTheme.bluePrimary.withAlpha(20)
                                : Colors.black.withAlpha(10),
                            blurRadius: selectedIndex == index ? 12 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: TweenAnimationBuilder<Color?>(
                          duration: const Duration(milliseconds: 200),
                          tween: ColorTween(
                            begin: Colors.grey.shade600,
                            end: selectedIndex == index
                                ? (isDark
                                    ? Colors.blue.shade300
                                    : AppTheme.bluePrimary)
                                : (index == 0
                                    ? AppTheme.bluePrimary
                                    : (isDark
                                        ? Colors.white.withAlpha(200)
                                        : Colors.black45)),
                          ),
                          builder: (context, iconColor, _) {
                            final bubbleSize = _computeBubbleSize(index, selectedIndex);
                            final iconSize = (bubbleSize * 0.5).clamp(12.0, 20.0);
                            return Icon(
                              iconData,
                              size: iconSize,
                              color: iconColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 200),
                  tween: ColorTween(
                    begin: Colors.grey.shade600,
                    end: selectedIndex == index
                        ? (isDark ? Colors.blue.shade300 : AppTheme.bluePrimary)
                        : (index == 0
                            ? AppTheme.bluePrimary
                            : (isDark
                                ? Colors.white.withAlpha(200)
                                : Colors.black45)),
                  ),
                  builder: (context, color, child) {
                    return Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selectedIndex == index
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: color,
                        height: 1.0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static double _computeBubbleSize(int index, int selectedIndex) {
    const double maxSize = 48.0;
    const double primaryStep = 4.0;
    const double secondaryStep = 2.0;
    final int distance = (selectedIndex - index).abs();
    final int primarySteps = distance.clamp(0, 2);
    final int extraSteps = (distance > 2) ? (distance - 2) : 0;
    final double size =
        maxSize - primarySteps * primaryStep - extraSteps * secondaryStep;
    return size.clamp(24.0, maxSize);
  }
}

// Placeholder screen for unimplemented pages
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 64,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đang phát triển',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Wrapper to keep pages alive when navigating away
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  
  const KeepAliveWrapper({super.key, required this.child});
  
  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
