import 'package:flutter/material.dart';

enum FacilityLayout {
  floor,
  room,
  section,
  wall,
  wing,
  unit;

  /// Converts a string to a corresponding `LocationType`
  static FacilityLayout fromString(String type) {
    switch (type.toLowerCase()) {
      case 'floor':
        return FacilityLayout.floor;
      case 'room':
        return FacilityLayout.room;
      case 'section':
        return FacilityLayout.section;
      case 'wall':
        return FacilityLayout.wall;
      case 'wing':
        return FacilityLayout.wing;
      case 'unit':
        return FacilityLayout.unit;
      default:
        return FacilityLayout.unit;
    }
  }

  /// Returns the icon and color for the layout
  Icon get icon {
    switch (this) {
      case FacilityLayout.floor:
        return const Icon(Icons.layers, color: Colors.blue);
      case FacilityLayout.room:
        return const Icon(Icons.meeting_room, color: Colors.green);
      case FacilityLayout.section:
        return const Icon(Icons.category, color: Colors.purple);
      case FacilityLayout.wall:
        return const Icon(Icons.photo, color: Colors.brown);
      case FacilityLayout.wing:
        return const Icon(Icons.airplanemode_active, color: Colors.orange);
      case FacilityLayout.unit:
        return const Icon(Icons.house, color: Colors.red);
      default:
        return const Icon(Icons.build, color: Colors.grey);
    }
  }
}