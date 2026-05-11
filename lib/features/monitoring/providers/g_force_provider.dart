import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/sensor_service.dart';
import '../../../services/g_force_service.dart';
import '../../../models/g_force_data.dart';
import 'sensor_provider.dart';

/// Provider for the [GForceService] instance.
final gForceServiceProvider = Provider<GForceService>((ref) {
  return GForceService();
});

/// StreamProvider for live G-force data.
/// Derived from the raw accelerometer stream.
final gForceStreamProvider = StreamProvider.autoDispose<GForceData>((ref) {
  final sensorService = ref.watch(sensorServiceProvider);
  final gForceService = ref.watch(gForceServiceProvider);

  // Map raw accelerometer events to GForceData
  return sensorService.rawAccelerometerStream.map(
    (data) => gForceService.calculateGForce(data),
  );
});

/// Notifier to track the maximum G-force recorded during the session.
/// This avoid circularity issues found in simple StateProviders.
class MaxGForceNotifier extends AutoDisposeNotifier<double> {
  @override
  double build() {
    // We listen to the G-force stream and update the state if a new max is found.
    // ref.listen is safe here as it listens to a different provider.
    ref.listen<AsyncValue<GForceData>>(gForceStreamProvider, (previous, next) {
      next.whenData((data) {
        if (data.gForce > state) {
          state = data.gForce;
        }
      });
    });
    
    return 0.0;
  }
}

/// Provider for the max G-force value.
final maxGForceProvider = NotifierProvider.autoDispose<MaxGForceNotifier, double>(() {
  return MaxGForceNotifier();
});
