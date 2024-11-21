import 'package:flutter/material.dart';

import '../../../domain/models/application/current_view.dart';

class GlobalContextProvider extends ChangeNotifier {
  BuildContext? _currentContext;
  CurrentView? _currentView;

  BuildContext? get currentContext => _currentContext;
  CurrentView? get currentView => _currentView;

  void updateContext(BuildContext context) {
    _currentContext = context;
    notifyListeners();
  }

  void updateCurrentView(Type? viewType, {String? id}) {
    if(viewType == null) {
      _currentView = null;
    } else {
      _currentView = CurrentView(viewType: viewType, id: id);
    }
    notifyListeners();
  }
}
