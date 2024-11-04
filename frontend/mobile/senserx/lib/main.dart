import 'package:senserx/application/core/shared_preferences.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/providers/mode_provider.dart';
import 'package:senserx/presentation/ui/screens/animated_splash_screen.dart';
import 'package:senserx/presentation/ui/screens/home_screen.dart';
import 'package:senserx/presentation/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env.dev");
  final sharedPrefsService = await SharedPreferencesService.getInstance();

  runApp(MultiProvider(
    providers: [
      Provider<SharedPreferencesService>.value(value: sharedPrefsService),
      ChangeNotifierProxyProvider<SharedPreferencesService, ModeProvider>(
        create: (context) => ModeProvider(sharedPrefsService),
        update: (context, sharedPrefs, previous) =>
        previous ?? ModeProvider(sharedPrefs),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenseRx',
      theme: AppTheme.themeData,
      routes: {
        '/settings': (context) => const SettingsScreen()
      },
      home: const AnimatedSplashScreen(
          nextScreen: HomeScreen(title: "SenseRx")),
    );
  }
}
