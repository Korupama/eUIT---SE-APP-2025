import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC);
    final card = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ chi tiết'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.bluePrimary,
                child: const Text('NV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text('Nguyễn Văn A', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 18)),
              const SizedBox(height: 6),
              Text('MSSV: B1234567', style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
              const SizedBox(height: 12),
              const Text('Thông tin chi tiết hồ sơ sẽ có trong bản cập nhật sau.'),
            ],
          ),
        ),
      ),
    );
  }
}

