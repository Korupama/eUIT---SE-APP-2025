import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeSwitch extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeSwitch({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.primaryGradient
              : AppTheme.lightModeGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppTheme.bluePrimary : Colors.orange).withAlpha(76),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 16,
                  color: isDark ? AppTheme.bluePrimary : Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

