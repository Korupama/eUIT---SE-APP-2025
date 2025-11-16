import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

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
      const _PlaceholderPage(label: 'services'),
      const _PlaceholderPage(label: 'search'),
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkBackground.withAlpha(249) // 0.98 opacity
                : Colors.white.withAlpha(249), // 0.98 opacity
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withAlpha(26) // 0.1 opacity
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(76) // 0.3 opacity
                    : Colors.black.withAlpha(26), // 0.1 opacity
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center, // Changed from end to center
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
    return Expanded(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 1.0, end: isActive ? 1.05 : 1.0),
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
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4), // Minimal padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with active dot
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TweenAnimationBuilder<Color?>(
                      duration: const Duration(milliseconds: 200),
                      tween: ColorTween(
                        begin: Colors.grey.shade600,
                        end: isActive
                            ? (isDark ? Colors.blue.shade300 : AppTheme.bluePrimary)
                            : Colors.grey.shade600,
                      ),
                      builder: (context, color, child) {
                        return Icon(
                          iconData,
                          size: 20, // Further reduced from 22 to 20
                          color: color,
                        );
                      },
                    ),
                    if (isActive)
                      Positioned(
                        top: -5, // Adjusted from -6 to -5
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 3, // Reduced from 4 to 3
                            height: 3, // Reduced from 4 to 3
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.blue.shade300
                                  : AppTheme.bluePrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2), // Keep at 2
                // Label
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
                      style: TextStyle(
                        fontSize: 9, // Further reduced from 10 to 9
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: color,
                        height: 1.0, // Tighten line height
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
