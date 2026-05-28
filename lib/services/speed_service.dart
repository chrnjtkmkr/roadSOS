import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import '../models/speed_data.dart';

/// Service responsible for GPS-based speed tracking and deceleration analysis.
/// Optimized for battery by managing stream subscriptions and using appropriate intervals.
class SpeedService {
  SpeedData? _lastData;

  /// Stream of processed speed and deceleration data.
  /// Handles permission checks and location services.
  Stream<SpeedData> get speedStream async* {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Location services are disabled.', name: 'SpeedService');
      yield* const Stream.empty();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        developer.log('Location permissions are denied', name: 'SpeedService');
        yield* const Stream.empty();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log('Location permissions are permanently denied', name: 'SpeedService');
      yield* const Stream.empty();
      return;
    }

    // Configure location settings for high frequency updates
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0, // Receive updates as often as possible
    );

    yield* Geolocator.getPositionStream(locationSettings: locationSettings).map((position) {
      final currentSpeedMs = position.speed; // Speed in m/s
      final currentSpeedKmh = currentSpeedMs * 3.6; // Convert to km/h
      final now = position.timestamp;

      double deceleration = 0.0;

      if (_lastData != null) {
        final timeDiffSeconds = now.difference(_lastData!.timestamp).inMilliseconds / 1000.0;
        
        if (timeDiffSeconds > 0) {
          // Physics: a = (v2 - v1) / t
          // Using m/s for physics calculation
          final prevSpeedMs = _lastData!.speed / 3.6;
          deceleration = (currentSpeedMs - prevSpeedMs) / timeDiffSeconds;
        }
      }

      final newData = SpeedData(
        speed: currentSpeedKmh,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: now,
        deceleration: deceleration,
        accuracy: position.accuracy,
      );

      // Log significant deceleration
      if (deceleration < -4.0) {
        developer.log(
          'Sudden braking detected: ${deceleration.toStringAsFixed(2)} m/s²',
          name: 'SpeedService',
        );
      }

      _lastData = newData;
      return newData;
    });
  }

  // --- Simulation Support ---
  static double _simulatedSpeedKmh = 72.0; // Cruising speed 72 km/h
  static bool _isSimulatingCrash = false;
  static DateTime? _crashStartTime;
  static final _random = math.Random();

  static void triggerSimulatedCrash() {
    _isSimulatingCrash = true;
    _crashStartTime = DateTime.now();
  }

  static void resetSimulation() {
    _isSimulatingCrash = false;
    _crashStartTime = null;
    _simulatedSpeedKmh = 72.0;
  }

  Stream<SpeedData> getSimulatedSpeedStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      double deceleration = 0.0;
      
      if (_isSimulatingCrash && _crashStartTime != null) {
        final elapsed = now.difference(_crashStartTime!).inMilliseconds;
        if (elapsed < 1000) {
          // Instant decel (e.g. -20 m/s² deceleration, speed goes to 0)
          deceleration = -20.0;
          _simulatedSpeedKmh = 0.0;
        } else {
          deceleration = 0.0;
          _simulatedSpeedKmh = 0.0;
        }
      } else {
        // Cruising around 70-75 km/h with minor fluctuations
        final change = (_random.nextDouble() - 0.5) * 4.0; // Speed change in km/h
        _simulatedSpeedKmh = (_simulatedSpeedKmh + change).clamp(65.0, 85.0);
        deceleration = (change / 3.6); // Convert km/h/s to m/s²
      }

      return SpeedData(
        speed: _simulatedSpeedKmh,
        latitude: 22.5726,
        longitude: 88.3639,
        timestamp: now,
        deceleration: deceleration,
        accuracy: 5.0,
      );
    });
  }
}
