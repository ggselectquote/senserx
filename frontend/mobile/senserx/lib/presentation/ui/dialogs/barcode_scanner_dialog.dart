import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerDialog {
  static Future<String?> scan(BuildContext context) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        ScanResult result = await BarcodeScanner.scan();
        return result.rawContent;
      } catch (e) {
        print('Error: $e');
        return null;
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Camera Permission'),
          content: const Text('This app needs camera access to scan barcodes'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return null;
    }
  }
}