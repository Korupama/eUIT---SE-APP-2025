import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/modern_login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/lecturer/lecturer_main_screen.dart';
import 'screens/lecturer/lecturer_profile_screen.dart';
import 'screens/lecturer/lecturer_class_list_screen.dart';
import 'screens/lecturer/lecturer_schedule_screen.dart';
import 'screens/lecturer/lecturer_class_detail_screen.dart';
import 'screens/lecturer/lecturer_grade_management_screen.dart';
import 'screens/lecturer/lecturer_appeals_screen.dart';
import 'screens/lecturer/lecturer_documents_screen.dart';
import 'screens/lecturer/lecturer_exam_schedule_screen.dart';
import 'screens/lecturer/lecturer_edit_profile_screen.dart';
import 'screens/lecturer/lecturer_change_password_screen.dart';
import 'screens/lecturer/lecturer_confirmation_letter_screen.dart';
import 'screens/chatbot.dart';
import 'screens/notifications_screen.dart';
import 'services/theme_controller.dart';
import 'services/language_controller.dart';
import 'providers/home_provider.dart';
import 'providers/lecturer_provider.dart';
import 'utils/app_localizations.dart';
import 'utils/app_colors.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_preferences.dart';
import 'screens/services_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'models/teaching_class.dart';

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
        ChangeNotifierProvider(
          create: (context) => HomeProvider(auth: context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LecturerProvider(auth: context.read<AuthService>()),
        ),
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.bluePrimary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey.shade100,
      fontFamily: null,
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.bluePrimary,
        brightness: Brightness.dark,
      ),
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
        '/lecturer_home': (context) => const LecturerMainScreen(),
        '/lecturer_profile': (context) => const LecturerProfileScreen(),
        '/lecturer_grade_management': (context) =>
            const LecturerGradeManagementScreen(),
        '/lecturer_appeals': (context) => const LecturerAppealsScreen(),
        '/lecturer_documents': (context) => const LecturerDocumentsScreen(),
        '/lecturer_exam_schedule': (context) =>
            const LecturerExamScheduleScreen(),
        '/lecturer_edit_profile': (context) =>
            const LecturerEditProfileScreen(),
        '/lecturer_change_password': (context) =>
            const LecturerChangePasswordScreen(),
        '/lecturer_confirmation_letter': (context) =>
            const LecturerConfirmationLetterScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notification_preferences': (context) =>
            const NotificationPreferencesScreen(),
      },
      onGenerateRoute: (settings) {
        // Routes with showBackButton parameter
        if (settings.name == '/lecturer_class_list') {
          return MaterialPageRoute(
            builder: (context) =>
                const LecturerClassListScreen(showBackButton: true),
          );
        }
        if (settings.name == '/lecturer_schedule') {
          return MaterialPageRoute(
            builder: (context) =>
                const LecturerScheduleScreen(showBackButton: true),
          );
        }
        // Route with custom arguments
        if (settings.name == '/lecturer_class_detail') {
          final classInfo = settings.arguments as TeachingClass;
          return MaterialPageRoute(
            builder: (context) =>
                LecturerClassDetailScreen(classInfo: classInfo),
          );
        }
        return null;
      },
      initialRoute: '/',
    );
  }
}
