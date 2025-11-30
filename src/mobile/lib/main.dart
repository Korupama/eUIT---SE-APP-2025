import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/modern_login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/chatbot.dart';
import 'screens/notifications_screen.dart';
import 'services/theme_controller.dart';
import 'services/language_controller.dart';
import 'providers/home_provider.dart';
import 'utils/app_localizations.dart';
import 'utils/app_colors.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_preferences.dart';
import 'screens/services_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file; ignore errors silently if missing.
  try {
    await dotenv.load(fileName: 'env/.env');
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        // Single shared AuthService instance for the whole app
        Provider<AuthService>(create: (_) => AuthService(), lazy: false),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
        // Inject the shared AuthService into HomeProvider so it doesn't create its own
        ChangeNotifierProvider(create: (context) => HomeProvider(auth: context.read<AuthService>())),
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
        '/services': (context) => const ServicesScreen(),
        '/home': (context) => const MainScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notification_preferences': (context) => const NotificationPreferencesScreen(),
      },
      initialRoute: '/',
    );
  }
}
