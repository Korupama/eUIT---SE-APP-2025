import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/home_provider.dart';
import '../providers/lecturer_provider.dart';
import '../services/theme_controller.dart';
import '../services/language_controller.dart';
import '../services/auth_service.dart';
import '../utils/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_switch.dart';
import '../widgets/language_switch.dart';

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
      final auth = context.read<AuthService>();
      try {
        // Determine a username to show once on the login screen
        String? oneTimeUsername;
        try {
          final creds = await auth.getSavedCredentials();
          if (creds != null && creds['username'] != null && creds['username']!.isNotEmpty) {
            oneTimeUsername = creds['username'];
          }
        } catch (_) {}

        // If still null, try to obtain from HomeProvider studentCard if present
        try {
          final hp = context.read<HomeProvider>();
          final sc = hp.studentCard;
          if (oneTimeUsername == null && sc != null) {
            // Use mssv if available as a fallback username
            if (sc.mssv != null) oneTimeUsername = sc.mssv.toString();
          }
        } catch (_) {}

        // Store transient username (one-time) in AuthService
        if (oneTimeUsername != null && oneTimeUsername.isNotEmpty) {
          auth.setTransientLastUsername(oneTimeUsername);
        }

        // Remove any persisted credentials and remember flag so that logout
        // clears all account data. This ensures credentials are not persisted
        // after logout.
        await auth.deleteCredentials();
        await auth.setRememberMe(false);

        // Delete auth token — this triggers tokenNotifier and provider clears.
        await auth.deleteToken();

        // Clear provider state explicitly (best-effort)
        try {
          context.read<HomeProvider>().clear();
        } catch (_) {}
      } catch (_) {
        // ignore errors during logout cleanup
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<HomeProvider>();
    final themeController = context.watch<ThemeController>();
    final languageController = context.watch<LanguageController>();

    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final secondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildSettingsHeader(loc, isDark),
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 84.h),
          children: [
            // Header (profile card)
            GestureDetector(
              onTap: () {
                // Navigate to appropriate profile screen based on role
                final auth = context.read<AuthService>();
                auth.getRole().then((role) {
                  if (role == 'lecturer') {
                    Navigator.pushNamed(context, '/lecturer_edit_profile');
                  } else {
                    Navigator.pushNamed(context, '/profile');
                  }
                }).catchError((_) {
                  // Default to student profile
                  Navigator.pushNamed(context, '/profile');
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkBackground.withAlpha(242)
                          : Colors.white.withAlpha(229),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(26)
                            : Colors.grey.shade200.withAlpha(204),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppTheme.bluePrimary, AppTheme.blueLight],
                            ),
                          ),
                          child: Icon(Icons.person, color: Colors.white, size: 28.r),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // Check role first to determine which profile to show
                              return FutureBuilder<String?>(
                                future: context.read<AuthService>().getRole(),
                                builder: (context, snapshot) {
                                  final role = snapshot.data;

                                  if (role == 'lecturer') {
                                    // Show lecturer info
                                    try {
                                      final lecturerProvider = Provider.of<LecturerProvider>(context, listen: false);
                                      if (lecturerProvider.lecturerProfile != null) {
                                        final profile = lecturerProvider.lecturerProfile!;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profile.hoTen,
                                              style: TextStyle(
                                                color: textColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              'Mã GV: ${profile.maGv}',
                                              style: TextStyle(color: secondary, fontSize: 12.sp),
                                            ),
                                          ],
                                        );
                                      }
                                    } catch (e) {
                                      // Lecturer provider not available
                                    }
                                    // Lecturer but no profile yet
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loc.t('lecturer'),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          loc.t('loading_profile'),
                                          style: TextStyle(color: secondary, fontSize: 12.sp),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Show student info (default)
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.studentCard?.hoTen ?? loc.t('student_name'),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${loc.t('id')}: ${provider.studentCard?.mssv?.toString()}',
                                          style: TextStyle(color: secondary, fontSize: 12.sp),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: secondary, size: 24.r),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Group 1: Interface & Language
            _buildSectionTitle(loc.t('interface_language'), isDark),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                    borderRadius: BorderRadius.circular(16.r),
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
                            fontSize: 14.sp,
                          ),
                        ),
                        subtitle: Text(
                          themeController.isDark ? loc.t('dark_mode') : loc.t('light_mode'),
                          style: TextStyle(color: secondary, fontSize: 12.sp),
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
                            fontSize: 14.sp,
                          ),
                        ),
                        subtitle: Text(
                          languageController.locale.languageCode == 'vi' ? loc.t('vietnamese') : loc.t('english'),
                          style: TextStyle(color: secondary, fontSize: 12.sp),
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
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(loc.t('push_notifications'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        value: _pushNotifications,
                        onChanged: (v) => _setPushPref(v),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(loc.t('notification_customization'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        trailing: Icon(Icons.chevron_right_rounded, size: 24.r),
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
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(loc.t('change_password'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        trailing: Icon(Icons.open_in_new_rounded, size: 24.r),
                        onTap: () async {
                          const platform = MethodChannel('com.example.mobile/browser');
                          final url = 'https://auth.uit.edu.vn/';
                          try {
                            await platform.invokeMethod('openUrl', {'url': url});
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open browser: $e'),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(loc.t('logout'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        trailing: Icon(Icons.exit_to_app_rounded, size: 24.r),
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
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBackground.withAlpha(229) : Colors.white.withAlpha(242),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? Colors.white.withAlpha(26) : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(loc.t('version'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        subtitle: Text('1.0.0', style: TextStyle(fontSize: 12.sp)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(loc.t('send_feedback'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        trailing: Icon(Icons.chevron_right_rounded, size: 24.r),
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
                        title: Text(loc.t('privacy_policy'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                        trailing: Icon(Icons.open_in_new_rounded, size: 24.r),
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

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSettingsHeader(AppLocalizations loc, bool isDark) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56.h),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20.w,
        title: Text(
          loc.t('settings'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Section title that matches HomeScreen style
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
