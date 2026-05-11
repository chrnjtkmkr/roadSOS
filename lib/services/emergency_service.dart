import 'dart:async';
import 'dart:developer' as developer;
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/emergency_event.dart';
import '../models/crash_event.dart';

/// Service responsible for managing the emergency countdown and SOS flow.
class EmergencyService {
  Timer? _countdownTimer;
  StreamController<EmergencyEvent>? _controller;
  EmergencyEvent _currentEvent = EmergencyEvent.none();

  // Cooldown to prevent repeated triggers
  DateTime? _lastSosTime;
  static const Duration cooldownDuration = Duration(seconds: 30);

  Stream<EmergencyEvent> get emergencyStream {
    _controller ??= StreamController<EmergencyEvent>.broadcast();
    return _controller!.stream;
  }

  /// Start the emergency countdown if criteria are met.
  void initiateCountdown(CrashEvent crash) {
    // Check cooldown
    if (_lastSosTime != null && 
        DateTime.now().difference(_lastSosTime!) < cooldownDuration) {
      developer.log('SOS Cooldown active. Ignoring trigger.', name: 'EmergencyService');
      return;
    }

    if (_currentEvent.state == EmergencyState.countingDown) return;

    developer.log('INITIATING EMERGENCY COUNTDOWN. Confidence: ${crash.confidenceScore}', name: 'EmergencyService');
    
    _currentEvent = EmergencyEvent(
      timestamp: DateTime.now(),
      severity: crash.severity,
      countdownRemaining: 10,
      triggerReason: crash.triggerReason,
      emergencyTriggered: false,
      state: EmergencyState.countingDown,
      confidenceAtTrigger: crash.confidenceScore,
    );
    
    _controller?.add(_currentEvent);
    _startTimer();
    _startAlerts();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentEvent.countdownRemaining > 1) {
        _currentEvent = _currentEvent.copyWith(
          countdownRemaining: _currentEvent.countdownRemaining - 1,
        );
        _controller?.add(_currentEvent);
      } else {
        triggerSos();
      }
    });
  }

  void _startAlerts() {
    WakelockPlus.enable();
    // Continuous vibration pattern
    Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
  }

  void _stopAlerts() {
    WakelockPlus.disable();
    Vibration.cancel();
    _countdownTimer?.cancel();
  }

  void cancelEmergency() {
    developer.log('EMERGENCY CANCELLED BY USER', name: 'EmergencyService');
    _stopAlerts();
    _currentEvent = _currentEvent.copyWith(
      state: EmergencyState.cancelled,
      countdownRemaining: 0,
    );
    _controller?.add(_currentEvent);
    
    // Reset to none after a short delay to clear UI
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentEvent.state == EmergencyState.cancelled) {
        _currentEvent = EmergencyEvent.none();
        _controller?.add(_currentEvent);
      }
    });
  }

  void triggerSos() {
    developer.log('!!! SOS TRIGGERED !!!', name: 'EmergencyService');
    _stopAlerts();
    _lastSosTime = DateTime.now();
    _currentEvent = _currentEvent.copyWith(
      state: EmergencyState.triggered,
      emergencyTriggered: true,
      countdownRemaining: 0,
    );
    _controller?.add(_currentEvent);
  }

  void dispose() {
    _stopAlerts();
    _controller?.close();
  }
}
