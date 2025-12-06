import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/screens/schedule/schedule_main_screen.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'search/navigation_screen.dart';
import 'settings_screen.dart';
import '../widgets/draggable_chatbot_overlay.dart';
import 'services_screen.dart';
import '../widgets/animated_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // home

  late final List<Widget> _pages;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ServicesScreen(),
      const NavigationScreen(),
      const HomeScreen(),
      const ScheduleMainScreen(),
      const SettingsScreen(),
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
        // Khi không ở tab Home, back sẽ đưa về Home thay vì thoát app
        if (_selectedIndex != 2) {
          _onNavTap(2);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : const Color(0xFF020617),
        body: Stack(
          children: [
            // Nền động chung cho tất cả tab
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBackground(isDark: isDark),
              ),
            ),

            // Nội dung các tab (PageView)
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

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCustomBottomNav(loc, isDark),
            ),
            // Global Chatbot Overlay
            const DraggableChatbotOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBottomNav(AppLocalizations loc, bool isDark) {
    // Bottom nav background: frosted schedule-card-like look but slightly more transparent.
    // Fix the background height so it doesn't change when children animate.
    final double baseHeight = 75.0; // base bar height (content)
    final double bottomInset = MediaQuery.of(context).padding.bottom; // device inset
    final double barHeight = baseHeight + bottomInset;

    // We want the background to be visually lower than the nav items.
    // We'll render a fixed-height container (barHeight) as the background and shift it down by bgShift.
    // The foreground (nav items) will remain in the original position.
    final double bgShift = 12.0; // how many pixels to push the background down

    // Outer height must accommodate the shifted background so it doesn't clip.
    final double outerHeight = barHeight + bgShift;

    return SizedBox(
      height: outerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shifted background layer
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

          // Foreground: nav items stay in original position (not shifted)
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
                      iconData: Icons.home_repair_service_outlined,
                      label: loc.t('services'),
                      isDark: isDark,
                      onTap: () => _onNavTap(0),
                    ),
                    _NavItem(
                      index: 1,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.search_rounded,
                      label: loc.t('search'),
                      isDark: isDark,
                      onTap: () => _onNavTap(1),
                    ),
                    _NavItem(
                      index: 2,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.home_rounded,
                      label: loc.t('home'),
                      isDark: isDark,
                      onTap: () => _onNavTap(2),
                    ),
                    _NavItem(
                      index: 3,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.calendar_month_rounded,
                      label: loc.t('schedule'),
                      isDark: isDark,
                      onTap: () => _onNavTap(3),
                    ),
                    _NavItem(
                      index: 4,
                      selectedIndex: _selectedIndex,
                      iconData: Icons.settings_rounded,
                      label: loc.t('settings'),
                      isDark: isDark,
                      onTap: () => _onNavTap(4),
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

// Custom Nav Item Widget
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
    // Each item expands evenly; bubble size depends on distance from selectedIndex: nearer => larger.
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
            // Reduce top padding so bubbles sit closer to the top of the navbar
            padding: const EdgeInsets.only(top: 1, bottom: 2, left: 4, right: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use the 'Next Schedule' card visual style (small frosted gradient with border)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      // Size interpolates based on distance from selectedIndex
                      // sizes range from maxSize (48) to minSize (36)
                      width: _computeBubbleSize(index, selectedIndex),
                      height: _computeBubbleSize(index, selectedIndex),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        // Default background (frosted card look). No special-case background for Home.
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
                              ? (isDark ? AppTheme.bluePrimary.withAlpha(200) : AppTheme.bluePrimary)
                              : (index == 2 ? AppTheme.bluePrimary : (isDark ? Colors.white.withAlpha(200) : Colors.black45)),
                          width: selectedIndex == index ? 1.4 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? AppTheme.bluePrimary.withAlpha(20) : Colors.black.withAlpha(10),
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
                                ? (isDark ? Colors.blue.shade300 : AppTheme.bluePrimary)
                                : (index == 2 ? AppTheme.bluePrimary : (isDark ? Colors.white.withAlpha(200)  : Colors.black45)),
                          ),
                          builder: (context, iconColor, _) {
                            final bubbleSize = _computeBubbleSize(index, selectedIndex);
                            // Make icon proportional to bubble to avoid overflow.
                            // Use ~50% of bubble size, clamped to [12, 20].
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

                const SizedBox(height: 4),
                // Label under the bubble
                TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 200),
                  tween: ColorTween(
                    begin: Colors.grey.shade600,
                    end: selectedIndex == index
                        ? (isDark ? Colors.blue.shade300 : AppTheme.bluePrimary)
                        : (index == 2 ? AppTheme.bluePrimary : (isDark ? Colors.white.withAlpha(200)  : Colors.black45)),
                  ),
                  builder: (context, color, child) {
                    return Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
                        color: color,
                        height: 0.7,
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

  // Helper: interpolate bubble size based on distance from selected index
  static double _computeBubbleSize(int index, int selectedIndex) {
    // New rule: max 48. For the first two steps (distance 1-2) reduce 4 per step.
    // For any additional distance beyond 2, reduce only 2 per extra step.
    const double maxSize = 48.0;
    const double primaryStep = 4.0; // for distance 1..2
    const double secondaryStep = 2.0; // for distance >2
    final int distance = (selectedIndex - index).abs();
    final int primarySteps = distance.clamp(0, 2);
    final int extraSteps = (distance > 2) ? (distance - 2) : 0;
    final double size = maxSize - primarySteps * primaryStep - extraSteps * secondaryStep;
    // Clamp to avoid too small values
    return size.clamp(24.0, maxSize);
  }
}
