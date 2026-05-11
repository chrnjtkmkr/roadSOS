/// Model representing raw data from motion sensors (accelerometer/gyroscope).
class SensorData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  SensorData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  /// Factory constructor to create an initial state (all zeros).
  factory SensorData.empty() => SensorData(
        x: 0.0,
        y: 0.0,
        z: 0.0,
        timestamp: DateTime.now(),
      );

  /// Formats the sensor values for display with limited precision.
  String get formattedValues =>
      'X: ${x.toStringAsFixed(2)}, Y: ${y.toStringAsFixed(2)}, Z: ${z.toStringAsFixed(2)}';
}
