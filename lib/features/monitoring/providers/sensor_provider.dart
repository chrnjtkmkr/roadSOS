import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/sensor_service.dart';
import '../../../models/sensor_data.dart';

/// Provider for the [SensorService] instance.
final sensorServiceProvider = Provider<SensorService>((ref) {
  return SensorService();
});

/// StreamProvider for live accelerometer data.
/// Auto-disposes the stream subscription when no longer listened to.
final accelerometerProvider = StreamProvider.autoDispose<SensorData>((ref) {
  final service = ref.watch(sensorServiceProvider);
  
  // Optimization: The autoDispose modifier ensures that the sensor stream 
  // is cancelled when the user leaves the MonitoringScreen, saving battery.
  return service.userAccelerometerStream;
});

/// StreamProvider for live gyroscope data.
final gyroscopeProvider = StreamProvider.autoDispose<SensorData>((ref) {
  final service = ref.watch(sensorServiceProvider);
  return service.gyroscopeStream;
});
