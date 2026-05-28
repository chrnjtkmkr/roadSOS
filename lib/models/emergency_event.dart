import 'crash_event.dart';

/// Enum representing the state of the emergency countdown.
enum EmergencyState {
  none,
  countingDown,
  cancelled,
  triggered,
}

/// Model representing an emergency event and its current flow state.
class EmergencyEvent {
  final DateTime timestamp;
  final CrashSeverity severity;
  final int countdownRemaining;
  final String triggerReason;
  final bool emergencyTriggered;
  final EmergencyState state;
  final double confidenceAtTrigger;

  EmergencyEvent({
    required this.timestamp,
    required this.severity,
    required this.countdownRemaining,
    required this.triggerReason,
    required this.emergencyTriggered,
    required this.state,
    required this.confidenceAtTrigger,
  });

  /// Factory constructor for initial/empty state.
  factory EmergencyEvent.none() => EmergencyEvent(
        timestamp: DateTime.now(),
        severity: CrashSeverity.low,
        countdownRemaining: 10,
        triggerReason: '',
        emergencyTriggered: false,
        state: EmergencyState.none,
        confidenceAtTrigger: 0.0,
      );

  EmergencyEvent copyWith({
    DateTime? timestamp,
    CrashSeverity? severity,
    int? countdownRemaining,
    String? triggerReason,
    bool? emergencyTriggered,
    EmergencyState? state,
    double? confidenceAtTrigger,
  }) {
    return EmergencyEvent(
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      countdownRemaining: countdownRemaining ?? this.countdownRemaining,
      triggerReason: triggerReason ?? this.triggerReason,
      emergencyTriggered: emergencyTriggered ?? this.emergencyTriggered,
      state: state ?? this.state,
      confidenceAtTrigger: confidenceAtTrigger ?? this.confidenceAtTrigger,
    );
  }
}
