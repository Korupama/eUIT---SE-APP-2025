import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_controller.dart';
import '../services/language_controller.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../theme/app_colors.dart';
import '../utils/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.testMode = false});
  final bool testMode;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);

  bool _rememberMe = false;
  bool _isLoading = false; // loading state for auth

  String? _errorMessage; // unified error message shown under password

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _usernameFocused = false;
  bool _passwordFocused = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadRemembered();
    _usernameFocus.addListener(() => setState(() => _usernameFocused = _usernameFocus.hasFocus));
    _passwordFocus.addListener(() => setState(() => _passwordFocused = _passwordFocus.hasFocus));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _obscurePasswordNotifier.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
    required Color labelColor,
    required Color prefixIconColor,
    required Color fillColor,
    required Color focusedBorderColor,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      labelText: label, // TODO: Localize this string
      labelStyle: TextStyle(color: labelColor),
      prefixIcon: Icon(prefixIcon, color: prefixIconColor),
      suffixIcon: suffixIcon,
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
    );
  }

  Future<void> _persistRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_enabled', true);
      await prefs.setString('remember_username', _usernameController.text.trim());
    } else {
      await prefs.remove('remember_enabled');
      await prefs.remove('remember_username');
    }
  }

  Future<void> _loadRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRemember = prefs.getBool('remember_enabled') ?? false;
    final savedUsername = prefs.getString('remember_username') ?? '';
    if (savedRemember && savedUsername.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _usernameController.text = savedUsername;
      });
    }
  }

  // TODO: Add widget tests for this login flow
  Future<void> _onLoginPressed(AppLocalizations loc) async {
    if (_isLoading) return;

    if (_usernameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên tài khoản'); // TODO: Localize this string
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mật khẩu'); // TODO: Localize this string
      return;
    }

    try {
      setState(() => _isLoading = true);
      await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      await _persistRemembered();
      if (!mounted) return;
      setState(() => _errorMessage = null); // clear previous error
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordController.clear();
        _errorMessage = 'Tên tài khoản hoặc mật khẩu không đúng'; // Friendly message; TODO: Localize
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchForgotPasswordUrl() async {
    final Uri url = Uri.parse('https://auth.uit.edu.vn/ForgotPassword.aspx');
    if (!await launchUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở đường dẫn: ${url.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final languageController = context.watch<LanguageController>();
    final bool isDark = themeController.isDark;
    final loc = AppLocalizations(languageController.locale);

    final Color backgroundColor = isDark ? AppColors.navyDark : AppColorsTheme.background;
    final Color primaryTextColor = isDark ? Colors.white : AppColors.bluePrimary;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final Color hintColor = isDark ? AppColors.hintDark : Colors.grey.shade600;
    final Color inputFillColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    final Color focusedBorderColor = AppColors.bluePrimary;
    final Color adjustedUserFill = _usernameFocused
        ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white)
        : inputFillColor;
    final Color adjustedPassFill = _passwordFocused
        ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white)
        : inputFillColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            if (!widget.testMode)
                              SvgPicture.asset(
                                'assets/icons/logo-uit.svg',
                                height: 70,
                                colorFilter: const ColorFilter.mode(AppColors.bluePrimary, BlendMode.srcIn),
                              )
                            else
                              const Icon(Icons.school, size: 70, color: Colors.white54),
                            const SizedBox(height: 12),
                            Text(
                              'TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN', // TODO: Localize this string
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            loc.t('login'),
                            style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Username Field (TextFormField + validator)
                        TextField(
                          key: const Key('login_username_field'),
                          focusNode: _usernameFocus,
                          controller: _usernameController,
                          onSubmitted: (_) => _onLoginPressed(loc),
                          style: TextStyle(color: primaryTextColor),
                          cursorColor: focusedBorderColor,
                          decoration: _inputDecoration(
                            label: loc.t('username'),
                            prefixIcon: Icons.person_outline,
                            labelColor: hintColor,
                            prefixIconColor: hintColor,
                            fillColor: adjustedUserFill,
                            focusedBorderColor: focusedBorderColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Field (TextFormField + validator)
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscurePasswordNotifier,
                          builder: (context, obscure, _) {
                            return TextField(
                              key: const Key('login_password_field'),
                              focusNode: _passwordFocus,
                              controller: _passwordController,
                              onSubmitted: (_) => _onLoginPressed(loc),
                              style: TextStyle(color: primaryTextColor),
                              cursorColor: focusedBorderColor,
                              obscureText: obscure,
                              decoration: _inputDecoration(
                                label: loc.t('password'),
                                prefixIcon: Icons.lock_outline,
                                labelColor: hintColor,
                                prefixIconColor: hintColor,
                                fillColor: adjustedPassFill,
                                focusedBorderColor: focusedBorderColor,
                                suffixIcon: IconButton(
                                  tooltip: obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu', // TODO: Localize this string
                                  onPressed: () => _obscurePasswordNotifier.value = !obscure,
                                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: hintColor),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.bluePrimary,
                              onChanged: (val) => setState(() => _rememberMe = val ?? false),
                            ),
                            Text(
                              loc.t('remember_me'),
                              style: TextStyle(color: secondaryTextColor, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: isDark
                                  ? const LinearGradient(
                                      colors: [AppColors.bluePrimary, AppColors.accentPurple],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )
                                  : null,
                              color: isDark ? null : AppColors.bluePrimary,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _isLoading ? null : () => _onLoginPressed(loc),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.login, size: 20, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Đăng nhập', // TODO: Localize this string
                                            style: _Styles.loginButtonText,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: _isLoading ? null : _launchForgotPasswordUrl,
                          style: TextButton.styleFrom(
                            foregroundColor: secondaryTextColor,
                            textStyle: _Styles.forgotText,
                          ),
                          child: const Text('Quên mật khẩu?'), // TODO: Localize this string
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // THEME & LANGUAGE TOGGLES stay unchanged below
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Consumer<LanguageController>(
                    builder: (context, langCtrl, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Language toggle
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.navyDarker : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isDark
                                  ? null
                                  : const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: langCtrl.toggle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'VI',
                                      style: TextStyle(
                                        color: langCtrl.locale.languageCode == 'vi' ? AppColors.bluePrimary : secondaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(width: 1, height: 16, color: Colors.grey.shade400),
                                    const SizedBox(width: 8),
                                    Text(
                                      'EN',
                                      style: TextStyle(
                                        color: langCtrl.locale.languageCode == 'en' ? AppColors.bluePrimary : secondaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Theme switch without border
                          Semantics(
                            label: isDark ? 'Chế độ tối đang bật' : 'Chế độ sáng đang bật',
                            toggled: isDark,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.navyDarker : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(24),
                                // removed border
                                boxShadow: isDark
                                    ? null
                                    : const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Switch(
                                value: isDark,
                                onChanged: (bool value) => themeController.toggle(value),
                                activeTrackColor: AppColors.bluePrimary,
                                inactiveTrackColor: Colors.grey.shade500,
                                activeThumbColor: Colors.white,
                                inactiveThumbColor: Colors.grey.shade300,
                                thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                                  final selected = states.contains(WidgetState.selected);
                                  return selected
                                      ? Icon(Icons.dark_mode, size: 16, color: Colors.yellow.shade600)
                                      : const Icon(Icons.light_mode, size: 16, color: AppColors.bluePrimary);
                                }),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Styles {
  static const TextStyle loginButtonText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  static const TextStyle forgotText = TextStyle(fontSize: 13);
}
