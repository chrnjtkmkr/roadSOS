import 'package:flutter/material.dart';

/// Enum representing the severity of an impact based on G-force.
enum ImpactLevel {
  normal,
  moderate,
  severe,
}

/// Model representing processed G-force data.
class GForceData {
  final double gForce;
  final DateTime timestamp;
  final ImpactLevel impactLevel;

  GForceData({
    required this.gForce,
    required this.timestamp,
    required this.impactLevel,
  });

  /// Get color associated with the impact level.
  Color get color {
    switch (impactLevel) {
      case ImpactLevel.normal:
        return Colors.green;
      case ImpactLevel.moderate:
        return Colors.orange;
      case ImpactLevel.severe:
        return Colors.red;
    }
  }

  /// Get label for the impact level.
  String get label {
    switch (impactLevel) {
      case ImpactLevel.normal:
        return 'Normal';
      case ImpactLevel.moderate:
        return 'Moderate Impact';
      case ImpactLevel.severe:
        return 'Severe Impact';
    }
  }
}
