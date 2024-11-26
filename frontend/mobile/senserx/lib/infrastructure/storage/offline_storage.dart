import 'package:hive_flutter/hive_flutter.dart';
import 'package:senserx/domain/models/offline/facility_layout_option.dart';

class OfflineStorage {
  static const String _boxName = 'facilityLayouts';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FacilityLayoutOptionAdapter());
    await Hive.openBox<FacilityLayoutOption>(_boxName);
  }

  Future<void> storeFacilityLayouts(List<FacilityLayoutOption> layouts) async {
    if(layouts.isEmpty) return;
    final box = Hive.box<FacilityLayoutOption>(_boxName);
    await box.clear();
    await box.addAll(layouts);
  }

  List<FacilityLayoutOption> getFacilityLayouts() {
    final box = Hive.box<FacilityLayoutOption>(_boxName);
    return box.values.toList();
  }
}
