import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'search/navigation_screen.dart';
import 'settings_screen.dart';
import 'services_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // home

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ServicesScreen(),
      const NavigationScreen(),
      const HomeScreen(),
      const _PlaceholderPage(label: 'schedule'),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          // Main content
          _pages[_selectedIndex],

          // Custom Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCustomBottomNav(loc, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav(AppLocalizations loc, bool isDark) {
    // Bottom nav background: frosted schedule-card-like look but slightly more transparent.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      const Color(0xFF1E293B).withAlpha(200), // slightly more transparent than card
                      const Color(0xFF1E293B).withAlpha(180),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withAlpha(220), // a bit more transparent than card
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
          child: SafeArea(
            child: Padding(
              // Reduced vertical padding to make the bar shorter
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NavItem(
                    iconData: Icons.apps_rounded,
                    label: loc.t('services'),
                    isActive: _selectedIndex == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _NavItem(
                    iconData: Icons.search_rounded,
                    label: loc.t('search'),
                    isActive: _selectedIndex == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _NavItem(
                    iconData: Icons.home_rounded,
                    label: loc.t('home'),
                    isActive: _selectedIndex == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _NavItem(
                    iconData: Icons.calendar_month_rounded,
                    label: loc.t('schedule'),
                    isActive: _selectedIndex == 3,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  _NavItem(
                    iconData: Icons.settings_rounded,
                    label: loc.t('settings'),
                    isActive: _selectedIndex == 4,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Nav Item Widget
class _NavItem extends StatelessWidget {
  final IconData iconData;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconData,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Each item expands evenly; inside we render a small rounded-square "bubble" above a tiny label.
    return Expanded(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 1.0, end: isActive ? 1.03 : 1.0),
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
            // Reduced padding to compact items
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
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
                      // Selected item is larger (48x48), others are 40x40
                      width: isActive ? 48 : 40,
                      height: isActive ? 48 : 40,
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
                          color: isActive
                              ? (isDark ? AppTheme.bluePrimary.withAlpha(200) : AppTheme.bluePrimary)
                              : (isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200),
                          width: isActive ? 1.4 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppTheme.bluePrimary.withAlpha(20)
                                : Colors.black.withAlpha(10),
                            blurRadius: isActive ? 12 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: TweenAnimationBuilder<Color?>(
                          duration: const Duration(milliseconds: 200),
                          tween: ColorTween(
                            begin: Colors.grey.shade600,
                            end: isActive
                                ? (isDark ? Colors.blue.shade300 : AppTheme.bluePrimary)
                                : Colors.grey.shade600,
                          ),
                          builder: (context, iconColor, _) {
                            return Icon(
                              iconData,
                              // Slightly larger icon for active item
                              size: isActive ? 20 : 18,
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
                    end: isActive
                        ? (isDark ? Colors.blue.shade300 : AppTheme.bluePrimary)
                        : Colors.grey.shade600,
                  ),
                  builder: (context, color, child) {
                    return Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC),
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 80), // Space for bottom nav
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            loc.t(label),
            style: TextStyle(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.t('under_development'),
            style: TextStyle(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
