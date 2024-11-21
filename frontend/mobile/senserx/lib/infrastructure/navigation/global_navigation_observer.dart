import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/infrastructure/wifi/wifi_monitor.dart';
import '../../presentation/providers/application/global_context_provider.dart';

class GlobalNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _scheduleContextUpdate(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _scheduleContextUpdate(previousRoute);
  }

  /// Context Update
  void _scheduleContextUpdate(Route<dynamic>? route) {
    if (route?.navigator?.context != null) {
      final context = route!.navigator!.context;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final globalProvider = Provider.of<GlobalContextProvider>(context, listen: false);
        globalProvider.updateContext(context);
        WifiMonitor().setContext(context);
      });
    }
  }
}
