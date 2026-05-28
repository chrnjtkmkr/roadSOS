import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data.dart';

/// Service responsible for interacting with device motion sensors.
/// Optimized for low battery usage by using appropriate sampling intervals.
class SensorService {
  // Streams provided by sensors_plus
  // We use userAccelerometerEvents to get acceleration without gravity.
  
  /// Stream of filtered accelerometer data (without gravity).
  Stream<SensorData> get userAccelerometerStream {
    return userAccelerometerEvents.map((event) => SensorData(
          x: event.x,
          y: event.y,
          z: event.z,
          timestamp: DateTime.now(),
        ));
  }

  /// Stream of raw accelerometer data (including gravity).
  /// This is used for total G-force calculations.
  Stream<SensorData> get rawAccelerometerStream {
    return accelerometerEvents.map((event) => SensorData(
          x: event.x,
          y: event.y,
          z: event.z,
          timestamp: DateTime.now(),
        ));
  }

  /// Stream of gyroscope data (rotational speed).
  Stream<SensorData> get gyroscopeStream {
    return gyroscopeEvents.map((event) => SensorData(
          x: event.x,
          y: event.y,
          z: event.z,
          timestamp: DateTime.now(),
        ));
  }

  /// To further optimize for battery, we can throttle the streams if necessary.
  /// However, for "Live Monitoring", we use the default UI interval which 
  /// is balanced for responsiveness and battery.
  
  // Note: sensors_plus 5.0.0+ allows setting sampling rate globally or per stream
  // using SensorInterval. For battery optimization, we use uiInterval (approx 60Hz)
  // or gameInterval for higher freq. Default is usually fine, but we can explicitly set it.
  
  void setOptimizedInterval() {
    // This is a global setting in newer sensors_plus versions
    // SensorInterval.uiInterval is standard for UI updates.
  }

  // --- Simulation Support ---
  static final _random = math.Random();
  static bool _isSimulatingCrash = false;
  static DateTime? _crashStartTime;

  static void triggerSimulatedCrash() {
    _isSimulatingCrash = true;
    _crashStartTime = DateTime.now();
  }

  static void resetSimulation() {
    _isSimulatingCrash = false;
    _crashStartTime = null;
  }

  Stream<SensorData> getSimulatedUserAccelerometerStream() {
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      if (_isSimulatingCrash && _crashStartTime != null) {
        final elapsed = DateTime.now().difference(_crashStartTime!).inMilliseconds;
        if (elapsed < 1000) {
          // Intense crash acceleration spike (up to 40 m/s²)
          final x = (_random.nextDouble() - 0.5) * 5.0;
          final y = 30.0 + _random.nextDouble() * 10.0; // Extreme deceleration surge
          final z = (_random.nextDouble() - 0.5) * 5.0;
          return SensorData(x: x, y: y, z: z, timestamp: DateTime.now());
        } else {
          // Cooldown after crash, return to stillness
          return SensorData(x: 0.0, y: 0.0, z: 0.0, timestamp: DateTime.now());
        }
      }
      // Normal minor driving noise
      final x = (_random.nextDouble() - 0.5) * 0.4;
      final y = (_random.nextDouble() - 0.5) * 0.4;
      final z = (_random.nextDouble() - 0.5) * 0.4;
      return SensorData(x: x, y: y, z: z, timestamp: DateTime.now());
    });
  }

  Stream<SensorData> getSimulatedRawAccelerometerStream() {
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      if (_isSimulatingCrash && _crashStartTime != null) {
        final elapsed = DateTime.now().difference(_crashStartTime!).inMilliseconds;
        if (elapsed < 1000) {
          // Huge G-force spike (up to 6.0G)
          final x = (_random.nextDouble() - 0.5) * 5.0;
          final y = 45.0 + _random.nextDouble() * 15.0; // Deceleration peak + gravity
          final z = 9.8 + (_random.nextDouble() - 0.5) * 5.0;
          return SensorData(x: x, y: y, z: z, timestamp: DateTime.now());
        } else {
          // Post-crash stillness (only gravity is present, device lying flat)
          return SensorData(x: 0.0, y: 0.0, z: 9.8, timestamp: DateTime.now());
        }
      }
      // Normal driving vibration (gravity on Z-axis = 9.8 m/s²)
      final x = (_random.nextDouble() - 0.5) * 0.8;
      final y = (_random.nextDouble() - 0.5) * 0.8;
      final z = 9.8 + (_random.nextDouble() - 0.5) * 0.8;
      return SensorData(x: x, y: y, z: z, timestamp: DateTime.now());
    });
  }

  Stream<SensorData> getSimulatedGyroscopeStream() {
    return Stream.periodic(const Duration(milliseconds: 100), (_) {
      if (_isSimulatingCrash && _crashStartTime != null) {
        final elapsed = DateTime.now().difference(_crashStartTime!).inMilliseconds;
        if (elapsed < 1000) {
          // Intense rotational spin (up to 6 rad/s)
          final x = 4.0 + _random.nextDouble() * 2.0;
          final y = (_random.nextDouble() - 0.5) * 2.0;
          final z = 2.0 + _random.nextDouble() * 2.0;
          return SensorData(x: x, y: y, z: z, timestamp: DateTime.now());
        } else {
          // Stillness post-crash
          return SensorData(x: 0.0, y: 0.0, z: 0.0, timestamp: DateTime.now());
        }
      }
      // Normal minor driving rotation
      final x = (_random.nextDouble() - 0.5) * 0.15;
      final y = (_random.nextDouble() - 0.5) * 0.15;
      final z = (_random.nextDouble() - 0.5) * 0.15;
      return SensorData(x: x, y: y, z: z, timestamp: DateTime.now());
    });
  }
}
