import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senserx/presentation/providers/application/global_context_provider.dart';

import '../../../providers/application/wifi_provider.dart';
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
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SingleChildScrollView(
                              child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: const ShelfProvisioningForm(
                                      initialLayoutId: null))));
                    });
              },
              child: const Icon(Icons.wifi),
            )
          : const SizedBox();
    });
  }
}
