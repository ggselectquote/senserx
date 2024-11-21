import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/application/snackbar_provider.dart';
import '../notifications/senserx_snackbar.dart';

class BodyWrapper extends StatelessWidget {
  final Widget child;
  final double paddingLeft;
  final double paddingRight;

  const BodyWrapper({
    super.key,
    required this.child,
    this.paddingLeft = 25.0,
    this.paddingRight = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SnackbarProvider>(
      builder: (context, snackbarNotifier, child) {
        if (snackbarNotifier.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SenseRxSnackbar(
              context: context,
              title: snackbarNotifier.title ?? '',
              message: snackbarNotifier.message!,
              isSuccess: snackbarNotifier.isSuccess,
              isError: snackbarNotifier.isError,
              isInfo: snackbarNotifier.isInfo,
            ).show();
            snackbarNotifier.clearSnackbar();
          });
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(paddingLeft, 0, paddingRight, 0),
          child: this.child,
        );
      },
    );
  }
}
