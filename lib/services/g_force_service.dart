import 'dart:math' as math;
import 'dart:developer' as developer;
import '../models/sensor_data.dart';
import '../models/g_force_data.dart';

/// Service responsible for analyzing G-force from accelerometer data.
/// Uses physics-based calculations to determine impact severity.
class GForceService {
  static const double gravity = 9.81;

  /// Calculates G-force from raw accelerometer data.
  /// Physics: G = sqrt(x² + y² + z²) / 9.81
  GForceData calculateGForce(SensorData data) {
    // Magnitude of the acceleration vector
    final double magnitude = math.sqrt(
      math.pow(data.x, 2) + math.pow(data.y, 2) + math.pow(data.z, 2),
    );

    // Convert to G-force
    final double gForce = magnitude / gravity;

    // Classify impact level
    final ImpactLevel level = _classifyImpact(gForce);

    // Debug logging for significant forces
    if (gForce > 2.0) {
      developer.log(
        'Significant G-Force detected: ${gForce.toStringAsFixed(2)}G ($level)',
        name: 'GForceService',
      );
    }

    return GForceData(
      gForce: gForce,
      timestamp: data.timestamp,
      impactLevel: level,
    );
  }

  /// Classifies the G-force into impact levels.
  /// Normal < 2G
  /// Moderate 2G–5G
  /// Severe > 5G
  ImpactLevel _classifyImpact(double gForce) {
    if (gForce < 2.0) {
      return ImpactLevel.normal;
    } else if (gForce < 5.0) {
      return ImpactLevel.moderate;
    } else {
      return ImpactLevel.severe;
    }
  }
}
