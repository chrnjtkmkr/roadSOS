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
    // Watch G-Force, Speed, Gyroscope streams reactively
    final gForceAsync = ref.watch(gForceStreamProvider);
    final speedAsync = ref.watch(speedStreamProvider);
    final gyroAsync = ref.watch(gyroscopeProvider);

    final gForce = gForceAsync.valueOrNull;
    final speed = speedAsync.valueOrNull;
    final gyro = gyroAsync.valueOrNull;

    if (gForce != null && speed != null && gyro != null) {
      final service = ref.read(crashDetectionServiceProvider);
      return service.analyze(
        gForceData: gForce,
        speedData: speed,
        gyroData: gyro,
      );
    }

    return CrashEvent.none();
  }
}

/// Provider for the live crash event/confidence state.
final crashEventProvider = NotifierProvider.autoDispose<CrashNotifier, CrashEvent>(() {
  return CrashNotifier();
});
