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
  
  // Listen to crash events to decide when to initiate countdown
  ref.listen<CrashEvent>(crashEventProvider, (previous, next) {
    if (next.confidenceScore >= 0.8 && next.maxGForce >= 5.0) {
      // Trigger countdown if confidence is high and G-force is significant
      service.initiateCountdown(next);
    }
  });

  return service.emergencyStream;
});
