import 'dart:convert';
import 'dart:io';

import 'package:senserx/application/core/shared_preferences.dart';
import 'package:senserx/application/facility/facility_layout_service.dart';
import 'package:senserx/application/facility/facility_service.dart';
import 'package:senserx/application/mobile_devices/mobile_device_service.dart';
import 'package:senserx/application/overrides/senserx_http_overrides.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';
import 'package:senserx/infrastructure/notifications/NotificationHandler.dart';
import 'package:senserx/infrastructure/permissions/permissions_handler.dart';
import 'package:senserx/infrastructure/wifi/wifi_monitor.dart';
import 'package:senserx/presentation/providers/application/global_context_provider.dart';
import 'package:senserx/presentation/providers/application/snackbar_provider.dart';
import 'package:senserx/presentation/providers/application/wifi_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_layout_provider.dart';
import 'package:senserx/presentation/providers/facility/facility_provider.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:senserx/presentation/providers/application/mode_provider.dart';
import 'package:senserx/presentation/ui/components/wifi/wifi_floating_action_button.dart';
import 'package:senserx/presentation/ui/screens/animated_splash_screen.dart';
import 'package:senserx/presentation/ui/screens/facility_layout_screen.dart';
import 'package:senserx/presentation/ui/screens/facility_screen.dart';
import 'package:senserx/presentation/ui/screens/home_screen.dart';
import 'package:senserx/presentation/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'domain/models/facility/facility_layout_model.dart';
import 'infrastructure/navigation/global_navigation_observer.dart';

void main() async {
  HttpOverrides.global = SenserxHttpOverrides();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env.dev");
  final sharedPrefsService = await SharedPreferencesService.getInstance();

  await PermissionHandler.checkAndRequestPermissions();

  final WifiMonitor wifiMonitor = WifiMonitor();
  wifiMonitor.startScanning();
  runApp(MultiProvider(
    providers: [
      Provider<SharedPreferencesService>.value(value: sharedPrefsService),
      ChangeNotifierProvider(create: (context) => GlobalContextProvider()),
      ChangeNotifierProvider(create: (context) => FacilityProvider()),
      ChangeNotifierProvider(create: (context) => SnackbarProvider()),
      ChangeNotifierProvider(create: (context) => FacilityLayoutProvider()),
      ChangeNotifierProvider(create: (context) => WifiProvider()),
      ChangeNotifierProxyProvider<SharedPreferencesService, ModeProvider>(
        create: (context) => ModeProvider(sharedPrefsService),
        update: (context, sharedPrefs, previous) =>
            previous ?? ModeProvider(sharedPrefs),
      ),
    ],
    child: const SenseRxApp(),
  ));
}

class SenseRxApp extends StatefulWidget {
  const SenseRxApp({super.key});

  @override
  _SenseRxAppState createState() => _SenseRxAppState();
}

class _SenseRxAppState extends State<SenseRxApp> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late FirebaseMessaging _firebaseMessaging;
  final navigatorKey = GlobalKey<NavigatorState>();
  final FacilityService _facilityService = FacilityService();
  final FacilityLayoutService facilityLayoutService = FacilityLayoutService();

  @override
  void initState() {
    NotificationHandler.initialize();
    super.initState();
    NotificationHandler.requestPermission();
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((token) async {
      MobileDeviceService mobileDeviceService = MobileDeviceService();
      if (token != null && token.isNotEmpty) {
        mobileDeviceService.fetchDeviceInfoAndRegister(token);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationPayload(message.data);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      NotificationHandler.showNotification(message);
      if (message.data.isNotEmpty &&
          message.data['facilityId'] != null &&
          message.data['facilityLayoutId'] != null) {
        FacilityLayoutProvider facilityLayoutProvider =
            Provider.of<FacilityLayoutProvider>(context, listen: false);
       FacilityProvider facilityProvider = Provider.of<FacilityProvider>(context, listen: false);
        var facilityId = message.data['facilityId'];
        FacilityModel facility = await _facilityService
            .getFacilityDetails(facilityId);
        List<FacilityLayoutModel> layouts = await facilityLayoutService
            .listFacilityLayoutsByFacilityUid(facilityId);
        facilityProvider.setFacility(facility);
        facilityLayoutProvider.setLayouts(layouts);
      }
    });
    FirebaseMessaging.onBackgroundMessage(
        NotificationHandler.firebaseMessagingBackgroundHandler);
  }

  void _handleNotificationPayload(Map<String, dynamic> data) async {
    final facilityId = data['facilityId'];
    final facilityLayoutId = data['facilityLayoutId'];

    if (facilityId != null && facilityLayoutId != null) {
      FacilityService facilityService = FacilityService();
      var facility = await facilityService.getFacilityDetails(facilityId);
      var facilityLayout = await facilityService.findChildLayoutByUID(
          facilityId, facilityLayoutId);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => FacilityLayoutScreen(
            facility: facility,
            layout: facilityLayout,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SenseRx',
        theme: AppTheme.themeData,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        routes: {'/settings': (context) => const SettingsScreen()},
        navigatorObservers: [GlobalNavigatorObserver()],
        home: AnimatedSplashScreen(
            nextScreen: DefaultTabController(
                length: 2,
                child: Scaffold(
                  floatingActionButton: const WiFiFloatingActionButton(),
                  body: const TabBarView(
                    children: [
                      HomeScreen(title: "Inventory"),
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
                        Tab(
                          icon: Icon(Icons.business_outlined),
                          text: "Facility",
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
