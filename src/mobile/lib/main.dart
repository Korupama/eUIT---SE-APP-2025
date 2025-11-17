import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/modern_login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/chatbot.dart';
import 'services/theme_controller.dart';
import 'services/language_controller.dart';
import 'providers/home_provider.dart';
import 'utils/app_localizations.dart';
import 'utils/app_colors.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_preferences.dart';
// change_password_screen removed - change password now opens external auth site

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final languageController = context.watch<LanguageController>();
    final bool isDark = themeController.isDark;

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bluePrimary, brightness: Brightness.light),
      scaffoldBackgroundColor: Colors.grey.shade100,
      fontFamily: null,
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bluePrimary, brightness: Brightness.dark),
      scaffoldBackgroundColor: AppColors.navyDark,
      fontFamily: null,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eUIT In Development',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: languageController.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/': (context) => const ModernLoginScreen(),
        '/home': (context) => const MainScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notification_preferences': (context) => const NotificationPreferencesScreen(),
      },
      initialRoute: '/',
    );
  }
}
