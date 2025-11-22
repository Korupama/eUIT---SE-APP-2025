import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_controller.dart';
import '../services/language_controller.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/animated_background.dart';
import '../widgets/language_switch.dart';
import '../widgets/theme_switch.dart';
import '../widgets/shake_wrapper.dart';

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage; // keep for non-coded generic errors
  String? _errorKey; // holds localization key like 'invalid_credentials'
  bool _shakeUsername = false;
  bool _shakePassword = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _errorKey = null; // reset error key so it can re-localize
      _shakeUsername = false;
      _shakePassword = false;
    });

    if (!_formKey.currentState!.validate()) {
      // Trigger shake animation for empty fields
      if (_usernameController.text.trim().isEmpty) {
        setState(() => _shakeUsername = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _shakeUsername = false);
        });
      }
      if (_passwordController.text.isEmpty) {
        setState(() => _shakePassword = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _shakePassword = false);
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      await _authService.saveToken(token);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        final errorText = e.toString().replaceAll('Exception: ', '');
        setState(() {
          if (errorText == 'invalid_credentials') {
            _errorKey = 'invalid_credentials'; // store key only
            _errorMessage = null; // ensure old message cleared
          } else {
            _errorMessage = errorText; // fallback raw message
            _errorKey = null;
          }
          _passwordController.clear();
          _shakePassword = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _shakePassword = false);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final url = Uri.parse('https://auth.uit.edu.vn/ForgotPassword.aspx');
    try {
      // Try launching directly; some devices/emulators return false for canLaunchUrl
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.t('link_open_failed')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.t('error_prefix')}${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final languageController = context.watch<LanguageController>();
    final loc = AppLocalizations.of(context);
    final isDark = themeController.isDark;
    final isVietnamese = languageController.locale.languageCode == 'vi';

    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final secondaryTextColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Animated Background
          AnimatedBackground(isDark: isDark),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 16), // Reduced from 20

                      // Control buttons (Top Right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          LanguageSwitch(
                            isVietnamese: isVietnamese,
                            onToggle: () => languageController.toggleLanguage(),
                          ),
                          const SizedBox(width: 12),
                          ThemeSwitch(
                            isDark: isDark,
                            onToggle: () => themeController.toggleTheme(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40), // Reduced from 60

                      // Logo & Title
                      _buildLogoSection(textColor, secondaryTextColor, loc, isDark),

                      const SizedBox(height: 40), // Reduced from 60

                      // Login Form
                      _buildLoginForm(
                        isDark: isDark,
                        textColor: textColor,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        secondaryTextColor: secondaryTextColor,
                        loc: loc,
                      ),

                      const SizedBox(height: 32), // Reduced from 40
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(Color textColor, Color secondaryTextColor, AppLocalizations loc, bool isDark) {
    return Column(
      children: [
        Container(
          width: 80, // Reduced from 100
          height: 80, // Reduced from 100
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: AppTheme.glowShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced from 20
            child: SvgPicture.asset(
              'assets/icons/logo-uit.svg',
              colorFilter: const ColorFilter.mode(
                AppTheme.bluePrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20), // Reduced from 24
        Text(
          'UIT',
          style: AppTheme.headingLarge.copyWith(color: textColor),
        ),
        const SizedBox(height: 6), // Reduced from 8
        Text(
          loc.t('university_name'),
          style: AppTheme.bodyMedium.copyWith(
            color: isDark ? secondaryTextColor : Colors.black, // Black in light mode
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm({
    required bool isDark,
    required Color textColor,
    required Color cardColor,
    required Color borderColor,
    required Color secondaryTextColor,
    required AppLocalizations loc,
  }) {
    return Container(
      padding: const EdgeInsets.all(28), // Reduced from 32
      decoration: BoxDecoration(
        color: cardColor.withAlpha(127),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withAlpha(51)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc.t('login'),
              style: AppTheme.headingMedium.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28), // Reduced from 32

            // Username Field with Enter key navigation
            ShakeWrapper(
              shake: _shakeUsername,
              child: TextFormField(
                controller: _usernameController,
                style: TextStyle(color: textColor),
                textInputAction: TextInputAction.next, // Added for Enter key
                onFieldSubmitted: (_) {
                  // Move focus to password field when Enter is pressed
                  FocusScope.of(context).nextFocus();
                },
                decoration: _buildInputDecoration(
                  label: loc.t('username'),
                  icon: Icons.person_outline,
                  isDark: isDark,
                  borderColor: borderColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.t('please_enter_username');
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 18), // Reduced from 20

            // Password Field with Enter key to login
            ShakeWrapper(
              shake: _shakePassword,
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: textColor),
                textInputAction: TextInputAction.done, // Added for Enter key
                onFieldSubmitted: (_) {
                  // Trigger login when Enter is pressed on password field
                  _handleLogin();
                },
                decoration: _buildInputDecoration(
                  label: loc.t('password'),
                  icon: Icons.lock_outline,
                  isDark: isDark,
                  borderColor: borderColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: secondaryTextColor,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.t('please_enter_password');
                  }
                  return null;
                },
              ),
            ),

            // Error Message
            if (_errorKey != null || _errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorKey != null
                    ? loc.t(_errorKey!) // dynamic localization
                    : _errorMessage!,
                style: const TextStyle(
                  color: AppTheme.error,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 20), // Reduced from 24

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    setState(() => _rememberMe = !_rememberMe);
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                          activeColor: AppTheme.bluePrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.t('remember_me'),
                        style: AppTheme.bodyMedium.copyWith(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _handleForgotPassword,
                  child: Text(
                    loc.t('forgot_password'),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.bluePrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28), // Reduced from 32

            // Login Button
            _buildLoginButton(textColor, loc),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    required Color borderColor,
    Widget? suffixIcon,
  }) {
    final fillColor = isDark
        ? Colors.white.withAlpha(13)
        : Colors.black.withAlpha(5);

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
      ),
      prefixIcon: Icon(icon, color: AppTheme.bluePrimary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.bluePrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error, width: 2),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  Widget _buildLoginButton(Color textColor, AppLocalizations loc) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bluePrimary.withAlpha(76),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loc.t('logging_in'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        loc.t('login'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
