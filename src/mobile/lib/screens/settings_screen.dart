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
        title: Text(loc.t('logout_title')),
        content: Text(loc.t('logout_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.t('close'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.t('confirm'))),
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
                                Text(loc.t('student_name_placeholder'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(loc.t('student_id_placeholder'), style: TextStyle(color: secondary, fontSize: 12)),
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
              _buildSectionTitle(loc.t('interface_language'), isDark),
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
                            loc.t('theme_mode_label'),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            themeController.isDark ? loc.t('dark_mode') : loc.t('light_mode'),
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
                            loc.t('language'),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            languageController.locale.languageCode == 'vi' ? loc.t('vietnamese') : loc.t('english'),
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
              _buildSectionTitle(loc.t('notifications'), isDark),
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
                          title: Text(loc.t('push_notifications'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          value: _pushNotifications,
                          onChanged: (v) => _setPushPref(v),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(loc.t('notification_customization'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.pushNamed(context, '/notification_preferences'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Group 3: Account & Security
              _buildSectionTitle(loc.t('account_security'), isDark),
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
                          title: Text(loc.t('change_password'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.open_in_new_rounded),
                          onTap: () async {
                            final url = Uri.parse('https://auth.uit.edu.vn/');
                            try {
                              final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                              if (!launched && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context).t('link_open_failed')), backgroundColor: AppTheme.error),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${AppLocalizations.of(context).t('error_prefix')}${e.toString()}'), backgroundColor: AppTheme.error),
                                );
                              }
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(loc.t('logout'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.exit_to_app_rounded),
                          onTap: _confirmLogout,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Group 4: About
              _buildSectionTitle(loc.t('about_app'), isDark),
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
                          title: Text(loc.t('version'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          subtitle: const Text('1.0.0'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(loc.t('send_feedback'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () async {
                            final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: 'support@example.com',
                              queryParameters: {
                                'subject': loc.t('feedback_subject'),
                              },
                            );
                            try {
                              final launched = await launchUrl(emailUri);
                              if (!launched && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.t('link_open_failed')), backgroundColor: AppTheme.error));
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.t('error_prefix')}${e.toString()}'), backgroundColor: AppTheme.error));
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(loc.t('privacy_policy'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.open_in_new_rounded),
                          onTap: () async {
                            final url = Uri.parse('https://example.com/privacy');
                            try {
                              final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                              if (!launched && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.t('link_open_failed')), backgroundColor: AppTheme.error));
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.t('error_prefix')}${e.toString()}'), backgroundColor: AppTheme.error));
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
