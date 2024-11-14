import 'package:flutter/material.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';

class FacilityLayoutProvider with ChangeNotifier {
  List<FacilityLayoutModel> _layouts = [];
  bool _isLoading = true;

  List<FacilityLayoutModel> get layouts => _layouts;
  bool get isLoading => _isLoading;

  void setLayouts(List<FacilityLayoutModel> layouts) {
    _layouts = layouts;
    _isLoading = false;
    notifyListeners();
  }

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void addLayout(FacilityLayoutModel layout) {
    if (layout.parentId == null || layout.parentId!.isEmpty) {
      _layouts.add(layout);
    } else {
      _addLayoutRecursively(layout, _layouts);
    }
    notifyListeners();
  }

  void _addLayoutRecursively(FacilityLayoutModel layout, List<FacilityLayoutModel> layouts) {
    for (var i = 0; i < layouts.length; i++) {
      FacilityLayoutModel currentLayout = layouts[i];

      if (currentLayout.uid == layout.parentId) {
        currentLayout.children ??= [];
        if (!currentLayout.children!.any((child) => child.uid == layout.uid)) {
          currentLayout.children!.add(layout);
        }
        if (!currentLayout.subLayouts!.contains(layout.uid)) {
          currentLayout.subLayouts!.add(layout.uid);
        }
        layouts[i] = currentLayout;
        return;
      }
      if (currentLayout.children != null && currentLayout.children!.isNotEmpty) {
        _addLayoutRecursively(layout, currentLayout.children!);
      }
    }
  }

  void removeLayout(String layoutId) {
    _removeLayoutRecursively(layoutId, _layouts);
    _layouts.removeWhere((layout) => layout.uid == layoutId);
    notifyListeners();
  }


  void _removeLayoutRecursively(String layoutId, List<FacilityLayoutModel> layouts) {
    for (var i = 0; i < layouts.length; i++) {
      FacilityLayoutModel layout = layouts[i];
      if (layout.uid == layoutId) {
        layouts.removeAt(i);
        return;
      }

      if (layout.children != null && layout.children!.isNotEmpty) {
        layout.children!.removeWhere((child) => child.uid == layoutId);
        layout.subLayouts!.remove(layoutId);
        _removeLayoutRecursively(layoutId, layout.children!);
      }
    }
  }

  FacilityLayoutModel? findLayoutByUid(String uid) {
    FacilityLayoutModel? layout = _layouts.firstWhere((l) => l.uid == uid);

    for (final parent in _layouts) {
      if (parent.children != null) {
        layout = parent.children!.firstWhere((child) => child.uid == uid);
      }
    }

    return layout?.uid == null ? null : layout;
  }

  void _addOrUpdateLayout(FacilityLayoutModel layout) {
    final index = _layouts.indexWhere((l) => l.uid == layout.uid);
    if (index != -1) {
      _layouts[index] = layout;
    } else {
      _layouts.add(layout);
    }
  }
}
