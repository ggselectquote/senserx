import 'package:flutter/material.dart';

class SnackbarProvider extends ChangeNotifier {
  String? _message;
  String? _title;
  bool _isSuccess = false;
  bool _isError = false;
  bool _isInfo = false;

  String? get message => _message;
  String? get title => _title;
  bool get isSuccess => _isSuccess;
  bool get isError => _isError;
  bool get isInfo => _isInfo;

  void showSnackbar(String message, {String? title, bool isSuccess = false, bool isError = false, bool isInfo = false}) {
    _message = message;
    _title = title;
    _isSuccess = isSuccess;
    _isError = isError;
    _isInfo = isInfo;
    notifyListeners();
  }

  void clearSnackbar() {
    _message = null;
    _title = null;
    _isSuccess = false;
    _isError = false;
    _isInfo = false;
  }
}
