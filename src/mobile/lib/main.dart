import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'screens/lecturer/regulations_list_screen.dart';
import 'screens/lecturer/lecturer_confirmation_letter_screen.dart';
import 'screens/lecturer/lecturer_tuition_screen.dart';
import 'screens/lecturer/lecturer_absences_screen.dart';
import 'screens/lecturer/lecturer_makeup_classes_screen.dart';
import 'screens/lecturer/lecturer_debug_screen.dart';
import 'screens/chatbot.dart';
import 'screens/notifications_screen.dart';
import 'services/theme_controller.dart';
import 'services/language_controller.dart';
import 'providers/home_provider.dart';
import 'providers/lecturer_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/academic_provider.dart';
import 'utils/app_localizations.dart';
import 'utils/app_colors.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_preferences.dart';
import 'screens/services_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'models/teaching_class.dart';
import 'screens/loading_screen.dart';
import 'screens/lecturer/lecturer_loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file; ignore errors silently if missing.
  try {
    await dotenv.load(fileName: 'env/.env');
  } catch (_) {}

  // Initialize AuthService and load saved token before building UI
  await AuthService.initialize();

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
        // Student schedule provider
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(auth: AuthService()),
        ),
        // Academic provider for grades, tuition, training, content
        ChangeNotifierProvider(
          create: (_) => AcademicProvider(auth: AuthService()),
        ),
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

    return ScreenUtilInit(
      // Design size based on a medium phone (e.g., iPhone 12/13)
      designSize: const Size(400, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
          // Use a dedicated AuthGate widget as home so we don't recreate MaterialApp when token changes
          home: const AuthGate(),
          routes: {
            // Removed '/' as it is now handled by home
            '/services': (context) => const ServicesScreen(),
            '/home': (context) => const MainScreen(),
            '/lecturer_loading': (context) => const LecturerLoadingScreen(),
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
            '/lecturer_regulations': (context) => const RegulationsListScreen(),
            '/lecturer_confirmation_letter': (context) =>
                const LecturerConfirmationLetterScreen(),
            '/lecturer_tuition': (context) => const LecturerTuitionScreen(),
            '/lecturer_absences': (context) => const LecturerAbsencesScreen(),
            '/lecturer_makeup_classes': (context) =>
                const LecturerMakeupClassesScreen(),
            '/lecturer_debug': (context) => const LecturerDebugScreen(),
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
        );
      },
    );
  }
}

/// AuthGate listens to the in-memory token notifier and switches between
/// Login screen and RoleBasedHome without rebuilding MaterialApp.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _token;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _token = AuthService.tokenNotifier.value;
    _listener = () {
      if (!mounted) return;
      setState(() => _token = AuthService.tokenNotifier.value);
    };
    AuthService.tokenNotifier.addListener(_listener);
  }

  @override
  void dispose() {
    AuthService.tokenNotifier.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) return const ModernLoginScreen();
    // token present -> show RoleBasedHome which will resolve role and navigate accordingly
    return const RoleBasedHome();
  }
}

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    // First, check in-memory notifier (fast, avoids storage race)
    final inMemRole = AuthService.roleNotifier.value;
    if (inMemRole != null) {
      // ignore: avoid_print
      print('RoleBasedHome: inMemory role -> $inMemRole');
      if (inMemRole == 'lecturer') return const LecturerMainScreen();
      return const LoadingScreen();
    }

    // If in-memory role not set yet, fall back to storage / token decode
    return FutureBuilder<String?>(
      future: auth.getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final role = snapshot.data;
        // Debug logging to help diagnose role detection
        try {
          auth.getToken().then((t) {
            // ignore: avoid_print
            print('RoleBasedHome: token present=${t != null}');
          });
        } catch (_) {}
        // ignore: avoid_print
        print('RoleBasedHome: resolved role -> ${role ?? 'null'}');
        if (role == 'lecturer') {
          // For lecturers, show a dedicated loading screen that prefetched lecturer data
          return const LecturerLoadingScreen();
        }
        // Default: student or unknown -> use LoadingScreen which will prefetch then go to MainScreen
        return const LoadingScreen();
      },
    );
  }
}
