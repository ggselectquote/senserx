import 'package:senserx/application/core/definitions.dart';
import 'package:senserx/application/core/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:senserx/domain/enums/operation_mode.dart';

class ModeProvider extends ChangeNotifier {
  final SharedPreferencesService sharedPreferencesService;
  static final String _modeKey = Definitions.getSharedPrefKey('operation_mode');

  OperationMode _currentMode = OperationMode.checkout; // Default mode

  ModeProvider(this.sharedPreferencesService) {
    _loadMode();
  }

  OperationMode get currentMode => _currentMode;

  bool get isCheckinMode => _currentMode == OperationMode.checkin;

  Future<void> _loadMode() async {
    final storedMode = await sharedPreferencesService.getString(_modeKey);
    _currentMode = storedMode == OperationMode.checkin.toString()
        ? OperationMode.checkin
        : OperationMode.checkout;
    notifyListeners();
  }

  Future<void> toggleMode() async {
    _currentMode = _currentMode == OperationMode.checkout
        ? OperationMode.checkin
        : OperationMode.checkout;
    await _saveMode();
    notifyListeners();
  }

  Future<void> setMode(OperationMode mode) async {
    if (_currentMode != mode) {
      _currentMode = mode;
      await _saveMode();
      notifyListeners();
    }
  }

  Future<void> _saveMode() async {
    await sharedPreferencesService.setString(_modeKey, _currentMode.toString());
  }
}