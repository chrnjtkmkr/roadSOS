import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/speed_service.dart';
import '../../../models/speed_data.dart';

/// Provider for the [SpeedService] instance.
final speedServiceProvider = Provider<SpeedService>((ref) {
  return SpeedService();
});

/// StreamProvider for live speed and location data.
/// Auto-disposes to save battery and stop GPS tracking when not needed.
final speedStreamProvider = StreamProvider.autoDispose<SpeedData>((ref) {
  final service = ref.watch(speedServiceProvider);
  return service.speedStream;
});

/// Provider to track the maximum speed reached in the current session.
final maxSpeedProvider = NotifierProvider.autoDispose<MaxSpeedNotifier, double>(() {
  return MaxSpeedNotifier();
});

class MaxSpeedNotifier extends AutoDisposeNotifier<double> {
  @override
  double build() {
    ref.listen<AsyncValue<SpeedData>>(speedStreamProvider, (previous, next) {
      next.whenData((data) {
        if (data.speed > state) {
          state = data.speed;
        }
      });
    });
    return 0.0;
  }
}

/// Provider to track the maximum deceleration (strongest braking) in the session.
final maxDecelerationProvider = NotifierProvider.autoDispose<MaxDecelerationNotifier, double>(() {
  return MaxDecelerationNotifier();
});

class MaxDecelerationNotifier extends AutoDisposeNotifier<double> {
  @override
  double build() {
    ref.listen<AsyncValue<SpeedData>>(speedStreamProvider, (previous, next) {
      next.whenData((data) {
        // We look for the most negative deceleration (absolute max)
        if (data.deceleration < state) {
          state = data.deceleration;
        }
      });
    });
    return 0.0;
  }
}
