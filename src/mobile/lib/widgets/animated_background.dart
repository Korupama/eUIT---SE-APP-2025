import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final bool isDark;

  const AnimatedBackground({
    super.key,
    required this.isDark,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Orbs Layer
        _buildOrb(
          controller: _orb1Controller,
          top: -100,
          left: -100,
          size: 300,
          colors: [AppTheme.bluePrimary, AppTheme.blueLight],
        ),
        _buildOrb(
          controller: _orb2Controller,
          top: 100,
          right: -50,
          size: 250,
          colors: [AppTheme.blueLight, AppTheme.blueDark],
        ),
        _buildOrb(
          controller: _orb3Controller,
          bottom: -80,
          left: 50,
          size: 280,
          colors: [AppTheme.blueDark, AppTheme.bluePrimary],
        ),

        // Grid Pattern Layer
        CustomPaint(
          painter: GridPainter(isDark: widget.isDark),
          size: Size.infinite,
        ),

        // Floating Particles Layer
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlesPainter(
                progress: _particleController.value,
                isDark: widget.isDark,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrb({
    required AnimationController controller,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required List<Color> colors,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.1).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colors[0].withAlpha(153),
                colors[1].withAlpha(76),
                colors[1].withAlpha(0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final bool isDark;

  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withAlpha(8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => isDark != oldDelegate.isDark;
}

class ParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final List<Particle> particles;

  ParticlesPainter({required this.progress, required this.isDark})
      : particles = List.generate(20, (index) => Particle(index));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppTheme.bluePrimary).withAlpha(102)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final position = particle.getPosition(size, progress);
      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) =>
      progress != oldDelegate.progress || isDark != oldDelegate.isDark;
}

class Particle {
  final int seed;
  final double size;
  final double speedX;
  final double speedY;
  final double startX;
  final double startY;

  Particle(this.seed)
      : size = 2 + (seed % 3).toDouble(),
        speedX = (seed % 5 - 2.5) * 0.3,
        speedY = (seed % 7 - 3.5) * 0.2,
        startX = (seed * 37 % 100) / 100.0,
        startY = (seed * 73 % 100) / 100.0;

  Offset getPosition(Size size, double progress) {
    final x = (startX * size.width + speedX * size.width * progress) % size.width;
    final y = (startY * size.height + speedY * size.height * progress) % size.height;
    return Offset(x, y);
  }
}

