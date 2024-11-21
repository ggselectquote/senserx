import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:senserx/application/core/definitions.dart';
import 'package:senserx/infrastructure/storage/offline_storage.dart';
import 'package:senserx/presentation/ui/components/facility/shelf_provisioning_form.dart';

import '../../application/core/shared_preferences.dart';
import '../../application/facility/facility_layout_service.dart';
import '../../presentation/providers/application/global_context_provider.dart';
import '../../presentation/providers/application/wifi_provider.dart';
import '../../presentation/ui/screens/facility_layout_screen.dart';

class WifiMonitor {
  static final WifiMonitor _instance = WifiMonitor._internal();
  DateTime? _lastFormDismissalTime;
  final OfflineStorage offlineStorage = OfflineStorage();
  final FacilityLayoutService facilityLayoutService = FacilityLayoutService();
  DateTime? lastFetched;
  String facilityId = dotenv.env['FACILITY_ID'] ?? "";
  late SharedPreferencesService _sharedPrefs;
  late WifiProvider _wifiProvider;

  factory WifiMonitor() {
    return _instance;
  }

  WifiMonitor._internal() {
    _initSharedPrefs();
  }

  Future<void> _initSharedPrefs() async {
    _sharedPrefs = await SharedPreferencesService.getInstance();
  }

  Isolate? _isolate;
  final ReceivePort _receivePort = ReceivePort();
  BuildContext? _context;
  bool _isFormShowing = false;

  void setContext(BuildContext context) {
    _context = context;
    _wifiProvider = Provider.of<WifiProvider>(context, listen: false);
  }

  void clearContext() {
    _context = null;
  }

  Future<void> startScanning() async {
    await offlineStorage.init();

    _receivePort.listen((message) {
      if (message is String && message == 'Check WiFi SSID') {
        _checkSSID();
      }
    });
    _isolate = await Isolate.spawn(_wifiScanIsolate, _receivePort.sendPort);
  }

  Future<void> _fetchAndStoreFacilityLayouts(String currentFacilityId) async {
    try {
      final layouts = await facilityLayoutService
          .fetchAndStoreFacilityLayouts(currentFacilityId);
      await offlineStorage.storeFacilityLayouts(layouts);
    } catch (e) {
      print("Error fetching facility layouts: $e");
    }
  }

  void stopScanning() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  static void _wifiScanIsolate(SendPort sendPort) async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 250));
      sendPort.send('Check WiFi SSID');
    }
  }

  Future<void> _checkSSID() async {
    try {
      if (await _wifiProvider.checkWifiConnection()) {
        if (await canShowNotification()) {
          _showNotification();
        }
      } else {
        if (await NetworkInfo().getWifiIP() != null &&
            await shouldRefreshFacilityLayouts()) {
          await _fetchAndStoreFacilityLayouts(facilityId);
          _sharedPrefs.setString(
              Definitions.LAST_SYNC_TIME, DateTime.now().toString());
        }
      }
    } catch (e) {
      print("Exception detecting wifi...${e.toString()}");
    }
  }

  Future<bool> shouldRefreshFacilityLayouts() async {
    var shouldFetch = _sharedPrefs.getBool(Definitions.SHOULD_FETCH);
    if (shouldFetch != null && shouldFetch) {
      _sharedPrefs.setBool(Definitions.SHOULD_FETCH, false);
      return true;
    }
    var lastSyncTime = _sharedPrefs.getString(Definitions.LAST_SYNC_TIME);
    if (lastSyncTime == null) return true;
    DateTime? dateTime = DateTime.tryParse(lastSyncTime);
    if (dateTime == null) return true;
    Duration timeSinceLastSync = DateTime.now().difference(dateTime);
    return timeSinceLastSync.inMinutes >= 5;
  }

  Future<bool> canShowNotification() async {
    final now = DateTime.now();
    if (_isFormShowing) {
      return false;
    }
    if (_lastFormDismissalTime != null &&
        now.difference(_lastFormDismissalTime!).inSeconds < 25) {
      return false;
    }
    return true;
  }

  void _showNotification() {
    if (_context != null) {
      _isFormShowing = true;
      final globalContextProvider = Provider.of<GlobalContextProvider>(_context!, listen: false);
      String? currentLayoutId;
      if (globalContextProvider.currentView?.viewType == FacilityLayoutScreen) {
        currentLayoutId = globalContextProvider.currentView?.id;
      }
      showDialog(
        context: _context!,
        builder: (BuildContext context) => ShelfProvisioningForm(initialLayoutId: currentLayoutId),
      ).then((_) {
        _lastFormDismissalTime = DateTime.now();
        _isFormShowing = false;
      });
    } else if (_isFormShowing) {
    } else {
      print("No valid context available for showing notification.");
    }
  }
}
