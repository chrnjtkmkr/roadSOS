import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/crash_detection_service.dart';
import '../../../models/crash_event.dart';
import '../../../models/g_force_data.dart';
import '../../../models/speed_data.dart';
import '../../../models/sensor_data.dart';
import 'sensor_provider.dart';
import 'g_force_provider.dart';
import 'speed_provider.dart';

/// Provider for the [CrashDetectionService] instance.
final crashDetectionServiceProvider = Provider<CrashDetectionService>((ref) {
  return CrashDetectionService();
});

/// Notifier that fuses all sensor streams to detect crash events.
class CrashNotifier extends AutoDisposeNotifier<CrashEvent> {
  @override
  CrashEvent build() {
    // Current latest values from all sensors
    GForceData? lastGForce;
    SpeedData? lastSpeed;
    SensorData? lastGyro;

    // Listen to G-Force
    ref.listen<AsyncValue<GForceData>>(gForceStreamProvider, (prev, next) {
      next.whenData((data) {
        lastGForce = data;
        _evaluate(lastGForce, lastSpeed, lastGyro);
      });
    });

    // Listen to Speed
    ref.listen<AsyncValue<SpeedData>>(speedStreamProvider, (prev, next) {
      next.whenData((data) {
        lastSpeed = data;
        _evaluate(lastGForce, lastSpeed, lastGyro);
      });
    });

    // Listen to Gyroscope
    ref.listen<AsyncValue<SensorData>>(gyroscopeProvider, (prev, next) {
      next.whenData((data) {
        lastGyro = data;
        _evaluate(lastGForce, lastSpeed, lastGyro);
      });
    });

    return CrashEvent.none();
  }

  void _evaluate(GForceData? g, SpeedData? s, SensorData? r) {
    if (g != null && s != null && r != null) {
      final service = ref.read(crashDetectionServiceProvider);
      final newEvent = service.analyze(
        gForceData: g,
        speedData: s,
        gyroData: r,
      );
      
      // We only update the state if confidence is significant or if we need to reset
      if (newEvent.confidenceScore > 0.1 || state.confidenceScore > 0) {
        state = newEvent;
      }
    }
  }
}

/// Provider for the live crash event/confidence state.
final crashEventProvider = NotifierProvider.autoDispose<CrashNotifier, CrashEvent>(() {
  return CrashNotifier();
});
