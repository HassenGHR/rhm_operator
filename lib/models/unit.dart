import 'package:flutter/material.dart';

import '../utils/constants.dart';

class Unit {
  final String id;
  final String name;
  final DateTime lastUpdated;
  final UnitStatus status;
  final Map<String, String> parameters;
  final IconData icon;

  Unit({
    required this.id,
    required this.name,
    required this.lastUpdated,
    required this.status,
    required this.parameters,
    required this.icon,
  });

  // Convert from JSON (for API or storage)
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      name: json['name'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      status: UnitStatus.values[json['status'] as int],
      parameters: Map<String, String>.from(json['parameters'] as Map),
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
    );
  }

  // Convert to JSON (for API or storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status.index,
      'parameters': parameters,
      'iconCodePoint': icon.codePoint,
    };
  }
}
