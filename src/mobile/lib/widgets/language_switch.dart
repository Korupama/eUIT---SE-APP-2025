import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class LanguageSwitch extends StatelessWidget {
  final bool isVietnamese;
  final VoidCallback onToggle;

  const LanguageSwitch({
    super.key,
    required this.isVietnamese,
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
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(51),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Background flag - shows flag of CURRENT language on opposite side
            Positioned(
              left: isVietnamese ? 34 : -4,
              top: 6,
              child: Opacity(
                opacity: 0.4,
                child: SvgPicture.asset(
                  isVietnamese
                      ? 'assets/icons/vn-flag-circle.svg'  // When VN selected, show VN flag on EN side
                      : 'assets/icons/en-flag-circle.svg',  // When EN selected, show EN flag on VN side
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Animated sliding circle with TEXT
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isVietnamese ? 4 : 32,
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bluePrimary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isVietnamese ? 'VN' : 'EN',
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
      ),
    );
  }
}

