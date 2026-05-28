import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/sensor_service.dart';
import '../../../models/sensor_data.dart';

/// Provider for the [SensorService] instance.
final sensorServiceProvider = Provider<SensorService>((ref) {
  return SensorService();
});

/// Provider to toggle between physical sensors and simulated demo ride.
/// Defaults to true on web (as web does not support mobile motion APIs over plain HTTP),
/// but can be toggled by the user in the UI.
final sensorSimulationProvider = StateProvider<bool>((ref) {
  return kIsWeb;
});

/// StreamProvider for live accelerometer data.
/// Auto-disposes the stream subscription when no longer listened to.
final accelerometerProvider = StreamProvider.autoDispose<SensorData>((ref) {
  final service = ref.watch(sensorServiceProvider);
  final isSimulated = ref.watch(sensorSimulationProvider);
  
  if (isSimulated) {
    return service.getSimulatedUserAccelerometerStream();
  }
  return service.userAccelerometerStream;
});

/// StreamProvider for live gyroscope data.
final gyroscopeProvider = StreamProvider.autoDispose<SensorData>((ref) {
  final service = ref.watch(sensorServiceProvider);
  final isSimulated = ref.watch(sensorSimulationProvider);
  
  if (isSimulated) {
    return service.getSimulatedGyroscopeStream();
  }
  return service.gyroscopeStream;
});
