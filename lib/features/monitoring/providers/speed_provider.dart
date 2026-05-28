import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/speed_service.dart';
import '../../../models/speed_data.dart';

import 'sensor_provider.dart';

/// Provider for the [SpeedService] instance.
final speedServiceProvider = Provider<SpeedService>((ref) {
  return SpeedService();
});

/// StreamProvider for live speed and location data.
/// Auto-disposes to save battery and stop GPS tracking when not needed.
final speedStreamProvider = StreamProvider.autoDispose<SpeedData>((ref) {
  final service = ref.watch(speedServiceProvider);
  final isSimulated = ref.watch(sensorSimulationProvider);

  if (isSimulated) {
    return service.getSimulatedSpeedStream();
  }
  return service.speedStream;
});

/// Provider to track the maximum speed reached in the current session.
final maxSpeedProvider = StateProvider.autoDispose<double>((ref) {
  return 0.0;
});

/// Provider to track the maximum deceleration (strongest braking) in the session.
final maxDecelerationProvider = StateProvider.autoDispose<double>((ref) {
  return 0.0;
});

