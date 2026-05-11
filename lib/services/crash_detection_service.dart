import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;
import '../models/g_force_data.dart';
import '../models/speed_data.dart';
import '../models/sensor_data.dart';
import '../models/crash_event.dart';

/// Service responsible for sensor fusion and crash confidence scoring.
/// Combines G-Force, Speed, and Gyroscope data to filter false positives.
class CrashDetectionService {
  // Cooldown timer to prevent multiple triggers
  DateTime? _lastTriggerTime;
  static const Duration cooldownDuration = Duration(seconds: 30);

  // Stillness detection variables
  bool _isMonitoringStillness = false;
  double _stillnessScore = 0.0;
  
  // Rolling peak detection
  double _peakGInWindow = 0.0;
  DateTime? _peakTime;
  static const Duration windowDuration = Duration(seconds: 5);

  /// Processes fused sensor data to calculate crash confidence.
  CrashEvent analyze({
    required GForceData gForceData,
    required SpeedData speedData,
    required SensorData gyroData,
  }) {
    // 1. Check Cooldown
    if (_lastTriggerTime != null && 
        DateTime.now().difference(_lastTriggerTime!) < cooldownDuration) {
      return CrashEvent.none();
    }

    // 2. Rolling Peak Detection (Memory of recent high impact)
    final now = DateTime.now();
    if (gForceData.gForce > _peakGInWindow || 
        (_peakTime != null && now.difference(_peakTime!) > windowDuration)) {
      _peakGInWindow = gForceData.gForce;
      _peakTime = now;
    }

    // G-Force Confidence (40% weight) - use the peak in the window
    double gForceScore = ((_peakGInWindow - 1.5) / 5.0).clamp(0.0, 1.0);

    // Speed Drop Confidence (40% weight)
    // Deceleration in m/s². 0-3 m/s² is braking, 8.0+ m/s² is extreme impact
    double speedDropScore = (speedData.deceleration.abs() / 10.0).clamp(0.0, 1.0);

    // Gyroscope Anomaly Confidence (20% weight)
    // Rotational speed. > 5 rad/s suggests violent rotation/rollover
    final double gyroMagnitude = math.sqrt(
      math.pow(gyroData.x, 2) + math.pow(gyroData.y, 2) + math.pow(gyroData.z, 2),
    );
    double gyroScore = (gyroMagnitude / 5.0).clamp(0.0, 1.0);

    // 3. Weighted Fusion
    double totalConfidence = (gForceScore * 0.4) + 
                            (speedDropScore * 0.4) + 
                            (gyroScore * 0.2);

    // 4. Stillness Adjustment (Increase confidence if device is stable after impact)
    // If we have a significant impact (G > 3.0), we check for stillness.
    if (gForceData.gForce > 3.0 && speedData.speed < 2.0) {
      _stillnessScore = (_stillnessScore + 0.05).clamp(0.0, 0.2); // Accumulate stillness
    } else {
      _stillnessScore = (_stillnessScore - 0.01).clamp(0.0, 0.2); // Decay if moving
    }
    
    totalConfidence = (totalConfidence + _stillnessScore).clamp(0.0, 1.0);

    if (totalConfidence > 0.4) {
      developer.log(
        'ANALYSIS: Conf: ${(totalConfidence * 100).toStringAsFixed(1)}%, PeakG: ${_peakGInWindow.toStringAsFixed(1)}, Stillness: ${_stillnessScore.toStringAsFixed(2)}',
        name: 'CrashDetectionService',
      );
    }

    // 5. Severity Classification
    CrashSeverity severity = _classifySeverity(totalConfidence);
    String reason = _determineTriggerReason(gForceScore, speedDropScore, gyroScore);

    final event = CrashEvent(
      confidenceScore: totalConfidence,
      maxGForce: _peakGInWindow,
      speedAtImpact: speedData.speed,
      peakDeceleration: speedData.deceleration,
      gyroIntensity: gyroMagnitude,
      timestamp: DateTime.now(),
      severity: severity,
      triggerReason: reason,
    );

    // Log significant events
    if (totalConfidence > 0.3) {
      developer.log(
        'Crash Intelligence Analysis: ${(totalConfidence * 100).toStringAsFixed(1)}% confidence. Severity: $severity. Reason: $reason',
        name: 'CrashDetectionService',
      );
      
      // If confidence is very high, set cooldown
      if (totalConfidence > 0.7) {
        _lastTriggerTime = DateTime.now();
      }
    }

    return event;
  }

  CrashSeverity _classifySeverity(double confidence) {
    if (confidence < 0.2) return CrashSeverity.low;
    if (confidence < 0.5) return CrashSeverity.moderate;
    if (confidence < 0.8) return CrashSeverity.high;
    return CrashSeverity.critical;
  }

  String _determineTriggerReason(double g, double s, double r) {
    if (g > s && g > r) return 'Sudden high G-force impact';
    if (s > g && s > r) return 'Extreme deceleration detected';
    if (r > g && r > s) return 'Violent device rotation/rollover';
    return 'Combined sensor anomaly';
  }
}
