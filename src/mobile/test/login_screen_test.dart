import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/screens/login-screen.dart';
import 'package:mobile/services/theme_controller.dart';
import 'package:mobile/services/language_controller.dart';
import 'package:mobile/utils/app_localizations.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(create: (_) => LanguageController()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('LoginScreen tests', () {
    testWidgets('Hiển thị thông báo lỗi khi nhập sai mật khẩu', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen(testMode: true)));
      final usernameField = find.byKey(const Key('login_username_field'));
      final passwordField = find.byKey(const Key('login_password_field'));
      expect(usernameField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      await tester.enterText(usernameField, 'demo');
      await tester.enterText(passwordField, 'wrong');
      final loginButton = find.text('Đăng nhập');
      await tester.tap(loginButton);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(seconds: 2)); // chờ future giả lập
      expect(find.text('Tên tài khoản hoặc mật khẩu không đúng'), findsOneWidget);
    });

    testWidgets('Thông báo lỗi giữ nguyên khi người dùng sửa input', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen(testMode: true)));
      final usernameField = find.byKey(const Key('login_username_field'));
      final passwordField = find.byKey(const Key('login_password_field'));
      await tester.enterText(usernameField, 'demo');
      await tester.enterText(passwordField, 'wrong');
      final loginButton = find.text('Đăng nhập');
      await tester.tap(loginButton);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Tên tài khoản hoặc mật khẩu không đúng'), findsOneWidget);
      // Sửa password nhưng chưa bấm login lại
      await tester.enterText(passwordField, 'wrongx');
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Tên tài khoản hoặc mật khẩu không đúng'), findsOneWidget);
    });
  });
}
