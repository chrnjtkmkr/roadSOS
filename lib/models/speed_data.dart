import 'package:flutter/material.dart';

/// Enum representing the state of motion based on deceleration.
enum DecelerationState {
  stationary,
  cruising,
  mildBraking,
  moderateBraking,
  severeDeceleration,
}

/// Model representing processed GPS speed and deceleration data.
class SpeedData {
  final double speed; // Speed in km/h
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double deceleration; // Change in speed (m/s²)
  final double accuracy; // GPS accuracy in meters

  SpeedData({
    required this.speed,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.deceleration,
    required this.accuracy,
  });

  /// Factory constructor for initial/empty state.
  factory SpeedData.empty() => SpeedData(
        speed: 0.0,
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        deceleration: 0.0,
        accuracy: 0.0,
      );

  /// Determine the current motion state based on speed and deceleration thresholds.
  DecelerationState get state {
    if (speed < 1.0) return DecelerationState.stationary;
    
    // Thresholds for deceleration (measured in m/s²)
    // Negative value indicates slowing down.
    final absDecel = deceleration.abs();
    
    if (deceleration >= 0) return DecelerationState.cruising;
    
    if (absDecel < 1.5) return DecelerationState.mildBraking;
    if (absDecel < 3.5) return DecelerationState.moderateBraking;
    return DecelerationState.severeDeceleration;
  }

  /// Get color associated with the motion state.
  Color get color {
    switch (state) {
      case DecelerationState.stationary:
        return Colors.blueGrey;
      case DecelerationState.cruising:
        return Colors.green;
      case DecelerationState.mildBraking:
        return Colors.orangeAccent;
      case DecelerationState.moderateBraking:
        return Colors.orange;
      case DecelerationState.severeDeceleration:
        return Colors.red;
    }
  }

  /// Get human-readable label for the state.
  String get label {
    switch (state) {
      case DecelerationState.stationary:
        return 'Stationary';
      case DecelerationState.cruising:
        return 'Cruising';
      case DecelerationState.mildBraking:
        return 'Mild Braking';
      case DecelerationState.moderateBraking:
        return 'Moderate Braking';
      case DecelerationState.severeDeceleration:
        return 'Severe Deceleration';
    }
  }
}
