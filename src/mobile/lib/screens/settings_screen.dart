import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_controller.dart';
import '../services/language_controller.dart';
import '../services/auth_service.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_switch.dart';
import '../widgets/language_switch.dart';
import '../widgets/animated_background.dart';

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

  // Theme is controlled directly via ThemeSwitch widget now.

  // Language is controlled directly via LanguageSwitch widget now.

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
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final secondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('settings')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: Stack(
        children: [
          // Use the same animated background as HomeScreen; pass current isDark
          if (isDark)
            const Positioned.fill(
              child: AnimatedBackground(isDark: true),
            ),
          ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 84),
            children: [
              // Header (make it visually match HomeScreen header)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkBackground.withAlpha(242)
                            : Colors.white.withAlpha(229),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200.withAlpha(204),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Use same gradient avatar as HomeScreen (48x48 with icon)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                              ),
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nguyễn Văn A', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('MSSV: B1234567', style: TextStyle(color: secondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: secondary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Group 1: Interface & Language
              _buildSectionTitle('Giao diện & Ngôn ngữ', isDark),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Chế độ giao diện',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            themeController.isDark ? 'Tối' : 'Sáng',
                            style: TextStyle(color: secondary, fontSize: 12),
                          ),
                          trailing: ThemeSwitch(
                            isDark: themeController.isDark,
                            onToggle: () => themeController.toggleTheme(),
                          ),
                          onTap: () => themeController.toggleTheme(),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Ngôn ngữ',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            languageController.locale.languageCode == 'vi' ? 'Tiếng Việt' : 'English',
                            style: TextStyle(color: secondary, fontSize: 12),
                          ),
                          trailing: LanguageSwitch(
                            isVietnamese: languageController.locale.languageCode == 'vi',
                            onToggle: () => languageController.toggleLanguage(),
                          ),
                          onTap: () => languageController.toggleLanguage(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Group 2: Notifications
              _buildSectionTitle('Thông báo', isDark),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Nhận thông báo đẩy', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          value: _pushNotifications,
                          onChanged: (v) => _setPushPref(v),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text('Tùy chỉnh thông báo', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pushNamed(context, '/notification_preferences'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Group 3: Account & Security
              _buildSectionTitle('Tài khoản & Bảo mật', isDark),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Đổi mật khẩu', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.open_in_new_rounded),
                          onTap: () async {
                            final url = Uri.parse('https://auth.uit.edu.vn/');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text('Đăng xuất', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.exit_to_app_rounded),
                          onTap: _confirmLogout,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Group 4: About
              _buildSectionTitle('Về ứng dụng', isDark),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Phiên bản', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          subtitle: const Text('1.0.0'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text('Gửi phản hồi & Báo lỗi', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
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
                          title: Text('Chính sách bảo mật', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
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
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  // Section title that matches HomeScreen style
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
