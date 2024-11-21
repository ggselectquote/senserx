import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:senserx/application/core/device_utilities.dart';
import 'package:senserx/presentation/ui/components/facility/shelf_provisioning_form.dart';

import '../../../providers/application/global_context_provider.dart';
import '../../../providers/application/wifi_provider.dart';
import '../../screens/facility_layout_screen.dart';

class PairShelfButton extends StatelessWidget {
  final String facilityId;
  final String facilityLayoutId;

  const PairShelfButton({
    Key? key,
    required this.facilityId,
    required this.facilityLayoutId,
  }) : super(key: key);

  Widget buildButton(BuildContext context, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.wifi),
      label: const Text('Pair Shelf'),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<WifiProvider, GlobalContextProvider>(builder: (context, wifiProvider, globalContextProvider, child) {
      return buildButton(
          context,
          wifiProvider.isConnectedToSenseShelf ? () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ShelfProvisioningForm(
                    initialLayoutId: globalContextProvider.currentView?.viewType == FacilityLayoutScreen ?
                    globalContextProvider.currentView?.id : null
                );
              },
            ).then((_) {
              Provider.of<GlobalContextProvider>(context, listen: false)
                  .updateCurrentView(null);
            });
          } : () {
            DeviceUtilities.openWifiSettings();
          }
      );
    });
  }
}

