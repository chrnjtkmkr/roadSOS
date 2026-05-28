import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/emergency_service.dart';
import '../../../models/emergency_event.dart';
import '../../../models/crash_event.dart';
import 'crash_provider.dart';

/// Provider for the [EmergencyService] instance.
final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  final service = EmergencyService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// StreamProvider for the live emergency state.
final emergencyStreamProvider = StreamProvider.autoDispose<EmergencyEvent>((ref) {
  final service = ref.watch(emergencyServiceProvider);
  return service.emergencyStream;
});
