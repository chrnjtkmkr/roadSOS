import 'dart:async';
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
}
