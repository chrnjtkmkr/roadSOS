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
  final isSimulated = ref.watch(sensorSimulationProvider);

  final rawStream = isSimulated
      ? sensorService.getSimulatedRawAccelerometerStream()
      : sensorService.rawAccelerometerStream;

  // Map raw accelerometer events to GForceData
  return rawStream.map(
    (data) => gForceService.calculateGForce(data),
  );
});

/// Provider for the max G-force value.
final maxGForceProvider = StateProvider.autoDispose<double>((ref) {
  return 0.0;
});

