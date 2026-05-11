import 'package:flutter/material.dart';

/// Enum representing the severity risk of a detected crash.
enum CrashSeverity {
  low,
  moderate,
  high,
  critical,
}

/// Model representing a detected crash event with confidence scoring.
class CrashEvent {
  final double confidenceScore; // 0.0 to 1.0 (or 0-100%)
  final double maxGForce;
  final double speedAtImpact;
  final double peakDeceleration;
  final double gyroIntensity;
  final DateTime timestamp;
  final CrashSeverity severity;
  final String triggerReason;

  CrashEvent({
    required this.confidenceScore,
    required this.maxGForce,
    required this.speedAtImpact,
    required this.peakDeceleration,
    required this.gyroIntensity,
    required this.timestamp,
    required this.severity,
    required this.triggerReason,
  });

  /// Factory constructor for initial/no-crash state.
  factory CrashEvent.none() => CrashEvent(
        confidenceScore: 0.0,
        maxGForce: 0.0,
        speedAtImpact: 0.0,
        peakDeceleration: 0.0,
        gyroIntensity: 0.0,
        timestamp: DateTime.now(),
        severity: CrashSeverity.low,
        triggerReason: 'No impact detected',
      );

  /// Get color associated with the crash severity.
  Color get color {
    switch (severity) {
      case CrashSeverity.low:
        return Colors.green;
      case CrashSeverity.moderate:
        return Colors.yellow;
      case CrashSeverity.high:
        return Colors.orange;
      case CrashSeverity.critical:
        return Colors.red;
    }
  }

  /// Get human-readable label for the severity.
  String get severityLabel {
    switch (severity) {
      case CrashSeverity.low:
        return 'Low Risk';
      case CrashSeverity.moderate:
        return 'Moderate Risk';
      case CrashSeverity.high:
        return 'High Risk';
      case CrashSeverity.critical:
        return 'Critical';
    }
  }
}
