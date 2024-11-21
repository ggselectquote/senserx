import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/presentation/providers/application/global_context_provider.dart';

import '../../../providers/application/wifi_provider.dart';
import '../../screens/facility_layout_screen.dart';
import '../facility/shelf_provisioning_form.dart';

class WiFiFloatingActionButton extends StatelessWidget {
  const WiFiFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WifiProvider, GlobalContextProvider>(builder: (context, wifiProvider, globalContextProvider, child) {
      return wifiProvider.isConnectedToSenseShelf
          ? FloatingActionButton(
              backgroundColor: Colors.blue[400],
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ShelfProvisioningForm(
                        initialLayoutId: globalContextProvider.currentView?.viewType == FacilityLayoutScreen ?
                        globalContextProvider.currentView?.id : null
                    );
                  },
                );
              },
              child: const Icon(Icons.wifi),
            )
          : const SizedBox();
    });
  }
}
