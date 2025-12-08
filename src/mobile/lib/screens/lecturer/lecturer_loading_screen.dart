import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Loading screen for lecturer that prefetches all necessary data
/// before navigating to LecturerMainScreen
class LecturerLoadingScreen extends StatefulWidget {
  const LecturerLoadingScreen({super.key});

  @override
  State<LecturerLoadingScreen> createState() => _LecturerLoadingScreenState();
}

class _LecturerLoadingScreenState extends State<LecturerLoadingScreen>
    with SingleTickerProviderStateMixin {
  bool _started = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start prefetching after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        _prefetchAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _prefetchAndNavigate() async {
    if (!mounted) return;

    final auth = context.read<AuthService>();
    final lecturer = context.read<LecturerProvider>();

    try {
      // Verify role is still lecturer (defensive check)
      final role = await auth.getRole();
      if (role != 'lecturer') {
        if (!mounted) return;
        // Role mismatch - navigate to appropriate screen
        Navigator.of(context).pushReplacementNamed('/home');
        return;
      }

      // Prefetch lecturer data
      await lecturer.prefetch();

      // Small delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to lecturer main screen
      Navigator.of(context).pushReplacementNamed('/lecturer_home');
    } catch (e) {
      // On error, show message but still navigate (allow retry from main screen)
      if (!mounted) return;

      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tải dữ liệu thất bại: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (_) {
        // Ignore if scaffold not available
      }

      // Navigate anyway - user can refresh from main screen
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/lecturer_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                    const Color(0xFF334155),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.bluePrimary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Loading indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.bluePrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Loading text
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Text(
                      'Đang tải dữ liệu giảng viên...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Vui lòng đợi trong giây lát',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



