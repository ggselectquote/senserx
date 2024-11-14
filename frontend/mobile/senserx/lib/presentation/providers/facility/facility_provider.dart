import 'package:flutter/material.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';

class FacilityProvider with ChangeNotifier {
  FacilityModel? _facility;
  bool _isLoading = true;

  FacilityModel? get facility => _facility;
  bool get isLoading => _isLoading;

  void setFacility(FacilityModel facility) {
    _facility = facility;
    _isLoading = false;
    notifyListeners();
  }

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }
}