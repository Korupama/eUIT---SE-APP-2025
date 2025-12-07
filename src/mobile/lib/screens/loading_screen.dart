import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../providers/academic_provider.dart';
import '../providers/lecturer_provider.dart';
import '../providers/schedule_provider.dart';
import 'main_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  bool _started = false;
  bool _warpFlash = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Shader animation loop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        _runPrefetch();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runPrefetch() async {
    final home = context.read<HomeProvider>();
    final academic = context.read<AcademicProvider>();
    final lecturer = context.read<LecturerProvider>();
    final schedule = context.read<ScheduleProvider>();

    try {
      await Future.wait([
        home.prefetch(),
        academic.prefetch(),
        lecturer.prefetch(),
        schedule.prefetch(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tải dữ liệu thất bại: $e')),
        );
      }
    } finally {
      if (!mounted) return;

      // Warp flash animation
      setState(() => _warpFlash = true);
      await Future.delayed(const Duration(milliseconds: 350));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return ShaderBuilder(
                assetKey: 'assets/shaders/blackhole_interstellar.glsl',
                (context, shader, child) {
                  shader.setFloat(0, _controller.value * 6.2831);
                  shader.setFloat(1, size.width);
                  shader.setFloat(2, size.height);

                  return CustomPaint(
                    painter: _WarpPainter(shader),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _SpeedParticles(count: 40),
                    _buildLogoContent(),
                  ],
                ),
              );
            },
          ),

          // Warp flash when finish loading
          AnimatedOpacity(
            opacity: _warpFlash ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform.scale(
              scale: 1 + sin(_controller.value * 2 * pi) * 0.05,
              child: Transform.rotate(
                angle: _controller.value * pi,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 78,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          "Đang uốn cong không gian...",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _WarpPainter extends CustomPainter {
  final FragmentShader shader;
  _WarpPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _WarpPainter _) => true;
}

class _SpeedParticles extends StatelessWidget {
  final int count;
  const _SpeedParticles({required this.count});

  @override
  Widget build(BuildContext context) {
    final rnd = Random();
    return Stack(
      children: List.generate(count, (i) {
        final duration =
            Duration(milliseconds: 500 + rnd.nextInt(700));
        final startX = rnd.nextDouble();
        final width = 1.5 + rnd.nextDouble() * 2;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.2, end: -0.2),
          duration: duration,
          curve: Curves.linear,
          builder: (_, value, __) {
            return Positioned(
              left: startX * MediaQuery.of(context).size.width,
              top: value * MediaQuery.of(context).size.height,
              child: Container(
                width: width,
                height: width * 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.38),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
          onEnd: () {},
        );
      }),
    );
  }
}
