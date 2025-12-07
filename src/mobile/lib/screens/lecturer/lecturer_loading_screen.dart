import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/home_provider.dart';
import '../../services/auth_service.dart';
import 'lecturer_main_screen.dart';

class LecturerLoadingScreen extends StatefulWidget {
  const LecturerLoadingScreen({super.key});

  @override
  State<LecturerLoadingScreen> createState() => _LecturerLoadingScreenState();
}

class _LecturerLoadingScreenState extends State<LecturerLoadingScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_started) {
        _started = true;
        _prefetchAndNavigate();
      }
    });
  }

  Future<void> _prefetchAndNavigate() async {
    final auth = context.read<AuthService>();
    final lecturer = context.read<LecturerProvider>();
    // some lecturer screens may also need schedule/home data
    LecturerProvider? lp;
    ScheduleProvider? sp;
    HomeProvider? hp;
    try {
      lp = context.read<LecturerProvider>();
    } catch (_) {}
    try {
      sp = context.read<ScheduleProvider>();
    } catch (_) {}
    try {
      hp = context.read<HomeProvider>();
    } catch (_) {}

    try {
      // verify role still lecturer (defensive)
      final role = await auth.getRole();
      if (role != 'lecturer') {
        // if role mismatch, just navigate back to login or main
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
        return;
      }

      // run prefetch tasks relevant to lecturer in parallel
      final futures = <Future>[];
      if (lp != null) futures.add(lp.prefetch());
      if (sp != null) futures.add(sp.prefetch());
      if (hp != null) futures.add(hp.prefetch());

      await Future.wait(futures);
    } catch (e) {
      // Non-fatal: show simple SnackBar then continue
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        try {
          messenger.showSnackBar(SnackBar(content: Text('Tải dữ liệu giảng viên thất bại: $e')));
        } catch (_) {}
      }
    } finally {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/lecturer_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 12),
            Text('Đang tải dữ liệu giảng viên...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

