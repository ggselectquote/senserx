import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:senserx/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SenseRxSnackbar {
  final BuildContext context;
  final String message;
  final String title;
  final bool isSuccess;
  final bool isError;
  final bool isInfo;
  final int durationInSeconds;
  final Position position;

  SenseRxSnackbar({
    required this.context,
    this.title = '',
    required this.message,
    this.isSuccess = false,
    this.isError = false,
    this.isInfo = false,
    this.durationInSeconds = 3,
    this.position = Position.top,
  });

  void show() {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    if (isSuccess) {
      backgroundColor = Colors.green;
      iconColor = Colors.green.shade900;
      icon = Icons.check_circle;
    } else if (isError) {
      backgroundColor = Colors.red;
      iconColor = Colors.red.shade900;
      icon = Icons.error;
    } else if (isInfo) {
      backgroundColor = AppTheme.themeData.primaryColor;
      iconColor = Colors.blue.shade400;

      icon = Icons.info;
    } else {
      backgroundColor = Colors.grey;
      iconColor = Colors.grey.shade900;
      icon = Icons.notifications;
    }

    CherryToast(
      width: double.infinity,
      borderRadius: 0,
      toastDuration: Duration(seconds: durationInSeconds),
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      themeColor: Colors.white,
      title: Text(
        title,
        style: AppTheme.themeData.textTheme.labelMedium?.copyWith(color: Colors.white),
      ),
      description: Text(
        message,
        style: AppTheme.themeData.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      toastPosition: position,
      animationDuration: const Duration(milliseconds: 250),
      autoDismiss: true,
    ).show(context);
  }
}