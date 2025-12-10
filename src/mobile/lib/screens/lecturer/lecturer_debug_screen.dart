import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/lecturer_provider.dart';

/// Debug screen to test API calls
class LecturerDebugScreen extends StatefulWidget {
  const LecturerDebugScreen({super.key});

  @override
  State<LecturerDebugScreen> createState() => _LecturerDebugScreenState();
}

class _LecturerDebugScreenState extends State<LecturerDebugScreen> {
  String _log = '';

  void _addLog(String message) {
    setState(() {
      _log += '${DateTime.now().toString().substring(11, 19)} - $message\n';
    });
  }

  Future<void> _testTeachingClasses() async {
    _addLog('🔍 Testing fetchTeachingClasses...');
    try {
      final provider = context.read<LecturerProvider>();
      await provider.fetchTeachingClasses();
      _addLog('✅ Classes count: ${provider.teachingClasses.length}');
      for (var c in provider.teachingClasses) {
        _addLog('  - ${c.maMon} ${c.tenMon} (${c.nhom})');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testSchedule() async {
    _addLog('🔍 Testing fetchSchedule...');
    try {
      final provider = context.read<LecturerProvider>();
      await provider.fetchSchedule();
      _addLog('✅ Schedule count: ${provider.teachingSchedule.length}');
      for (var s in provider.teachingSchedule) {
        _addLog('  - ${s.maMon} ${s.tenMon} (Thứ ${s.thu})');
      }
      _addLog('Next class: ${provider.nextClass?.tenMon ?? "None"}');
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _testProfile() async {
    _addLog('🔍 Testing fetchLecturerProfile...');
    try {
      final provider = context.read<LecturerProvider>();
      await provider.fetchLecturerProfile();
      _addLog('✅ Profile: ${provider.lecturerProfile?.hoTen ?? "None"}');
      _addLog('  MaGV: ${provider.lecturerProfile?.maGv}');
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug API Calls'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _testProfile,
                  child: const Text('Test Profile API'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testTeachingClasses,
                  child: const Text('Test Teaching Classes API'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _testSchedule,
                  child: const Text('Test Schedule API'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _log = '';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Clear Log'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  _log.isEmpty ? 'Tap buttons above to test APIs...' : _log,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
