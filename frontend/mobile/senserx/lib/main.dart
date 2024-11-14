import 'package:senserx/application/core/shared_preferences.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/providers/application/mode_provider.dart';
import 'package:senserx/presentation/ui/screens/animated_splash_screen.dart';
import 'package:senserx/presentation/ui/screens/facility_screen.dart';
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
      ChangeNotifierProvider(create: (context) => FacilityProvider()),
      ChangeNotifierProvider(create: (context) => FacilityLayoutProvider()),
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
        routes: {'/settings': (context) => const SettingsScreen()},
        home: AnimatedSplashScreen(
          nextScreen: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: const TabBarView(
                children: [
                  HomeScreen(title: "SenseRx"),
                  FacilityScreen(title: "Facility")
                ],
              ),
              bottomNavigationBar: Container(
                color: AppTheme.themeData.primaryColor,
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  indicatorColor: Colors.white,
                  tabs: const [
                     Tab(icon: Icon(Icons.assignment), text: "Inventory"),
                     Tab(icon: Icon(Icons.business_outlined), text: "Facility",),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
