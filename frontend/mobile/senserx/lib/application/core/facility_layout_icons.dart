

import 'package:flutter/material.dart';

class FacilityLayoutIcons {
  static Icon getTypeIcon(String type, {double? size = 36}) {
    switch (type.toLowerCase()) {
      case 'floor':
        return Icon(Icons.layers, color: Colors.blue, size: size);
      case 'room':
        return Icon(Icons.room, color: Colors.green, size: size);
      case 'section':
        return Icon(Icons.category, color: Colors.purple, size: size);
      case 'wall':
        return Icon(Icons.photo, color: Colors.brown, size: size);
      case 'wing':
        return Icon(Icons.account_box_outlined, color: Colors.orange, size: size);
      case 'unit':
        return Icon(Icons.event_seat, color: Colors.red, size: size);
      default:
        return Icon(Icons.build, color: Colors.grey, size: size);
    }
  }
}