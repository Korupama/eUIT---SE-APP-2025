// ...existing code...

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_controller.dart';
import '../services/language_controller.dart';
import '../services/auth_service.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadPushPref();
  }

  Future<void> _loadPushPref() async {
    // Try to load persisted preference (best-effort)
    try {
      // Use SharedPreferences if available in the project
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool('push_notifications_enabled');
      if (val != null) setState(() => _pushNotifications = val);
    } catch (_) {
      // ignore if SharedPreferences not present at runtime
    }
  }

  Future<void> _setPushPref(bool value) async {
    setState(() => _pushNotifications = value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications_enabled', value);
    } catch (_) {}
  }

  void _showThemeDialog() {
    final themeController = context.read<ThemeController>();
    final isDark = themeController.isDark;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        String selected = isDark ? 'dark' : 'light';
        return AlertDialog(
          title: Text('Chế độ giao diện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sáng'),
                trailing: selected == 'light' ? const Icon(Icons.check) : null,
                onTap: () {
                  themeController.toggle(false);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: const Text('Tối'),
                trailing: selected == 'dark' ? const Icon(Icons.check) : null,
                onTap: () {
                  themeController.toggle(true);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: const Text('Hệ thống'),
                trailing: null,
                onTap: () {
                  final platformDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
                  themeController.toggle(platformDark);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context).t('close')),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    final languageController = context.read<LanguageController>();
    final current = languageController.locale.languageCode;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Ngôn ngữ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tiếng Việt'),
                trailing: current == 'vi' ? const Icon(Icons.check) : null,
                onTap: () {
                  languageController.setLocale(const Locale('vi'));
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: current == 'en' ? const Icon(Icons.check) : null,
                onTap: () {
                  languageController.setLocale(const Locale('en'));
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context).t('close')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final loc = AppLocalizations.of(context);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.t('close'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Đồng ý')),
        ],
      ),
    );

    if (res == true) {
      final auth = AuthService();
      await auth.deleteToken();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeController = context.watch<ThemeController>();
    final languageController = context.watch<LanguageController>();

    final bg = isDark ? AppTheme.darkBackground : const Color(0xFFF7F8FC);
    final card = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final secondary = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('settings')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Header
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.bluePrimary,
                    child: const Text('NV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nguyễn Văn A', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('MSSV: B1234567', style: TextStyle(color: secondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: secondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Group 1: Interface & Language
          _buildSectionTitle('Giao diện & Ngôn ngữ'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Chế độ giao diện'),
                  subtitle: Text(themeController.isDark ? 'Tối' : 'Sáng'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showThemeDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Ngôn ngữ'),
                  subtitle: Text(languageController.locale.languageCode == 'vi' ? 'Tiếng Việt' : 'English'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showLanguageDialog,
                ),
              ],
            ),
          ),

          // Group 2: Notifications
          _buildSectionTitle('Thông báo'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Nhận thông báo đẩy'),
                  value: _pushNotifications,
                  onChanged: (v) => _setPushPref(v),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Tùy chỉnh thông báo'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, '/notification_preferences'),
                ),
              ],
            ),
          ),

          // Group 3: Account & Security
          _buildSectionTitle('Tài khoản & Bảo mật'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, '/change_password'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Đăng xuất'),
                  trailing: const Icon(Icons.exit_to_app_rounded),
                  onTap: _confirmLogout,
                ),
              ],
            ),
          ),

          // Group 4: About
          _buildSectionTitle('Về ứng dụng'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Phiên bản'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Gửi phản hồi & Báo lỗi'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'support@example.com',
                      queryParameters: {
                        'subject': 'Phản hồi eUIT',
                      },
                    );
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Chính sách bảo mật'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () async {
                    final url = Uri.parse('https://example.com/privacy');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
      ),
    );
  }
}
