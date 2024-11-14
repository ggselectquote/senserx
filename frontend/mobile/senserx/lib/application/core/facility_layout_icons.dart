

import 'package:flutter/material.dart';

class FacilityLayoutIcons {
  static Icon getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'floor':
        return const Icon(Icons.layers, color: Colors.blue);
      case 'room':
        return const Icon(Icons.meeting_room, color: Colors.green);
      case 'section':
        return const Icon(Icons.category, color: Colors.purple);
      case 'wall':
        return const Icon(Icons.photo, color: Colors.brown);
      case 'wing':
        return const Icon(Icons.account_box_outlined, color: Colors.orange);
      case 'unit':
        return const Icon(Icons.event_seat, color: Colors.red);
      default:
        return const Icon(Icons.build, color: Colors.grey);
    }
  }
}