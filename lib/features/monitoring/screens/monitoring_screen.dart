import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sensor_provider.dart';
import '../providers/g_force_provider.dart';
import '../providers/speed_provider.dart';
import '../providers/crash_provider.dart';
import '../providers/emergency_provider.dart';
import '../../../models/sensor_data.dart';
import '../../../models/g_force_data.dart';
import '../../../models/speed_data.dart';
import '../../../models/crash_event.dart';
import '../../../models/emergency_event.dart';
import '../../../services/emergency_service.dart';

/// Screen that displays live sensor data from the device.
/// Uses Material 3 design patterns and Riverpod for state.
class MonitoringScreen extends ConsumerWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the accelerometer, gyroscope and G-force streams
    final accelerometerAsync = ref.watch(accelerometerProvider);
    final gyroscopeAsync = ref.watch(gyroscopeProvider);
    final gForceAsync = ref.watch(gForceStreamProvider);
    final maxGForce = ref.watch(maxGForceProvider);
    final speedAsync = ref.watch(speedStreamProvider);
    final maxSpeed = ref.watch(maxSpeedProvider);
    final maxDecel = ref.watch(maxDecelerationProvider);
    final crashEvent = ref.watch(crashEventProvider);
    final emergencyAsync = ref.watch(emergencyStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Monitoring'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(context),
                const SizedBox(height: 20),
                _GForceMeterCard(
                  data: gForceAsync,
                  maxGForce: maxGForce,
                ),
                const SizedBox(height: 16),
                _CrashConfidenceCard(
                  event: crashEvent,
                ),
                const SizedBox(height: 16),
                _SpeedMonitoringCard(
                  data: speedAsync,
                  maxSpeed: maxSpeed,
                  maxDecel: maxDecel,
                ),
                const SizedBox(height: 16),
                _SensorDataCard(
                  title: 'Accelerometer',
                  subtitle: 'Linear acceleration (m/s²)',
                  icon: Icons.speed,
                  data: accelerometerAsync,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                _SensorDataCard(
                  title: 'Gyroscope',
                  subtitle: 'Rotational speed (rad/s)',
                  icon: Icons.sync,
                  data: gyroscopeAsync,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 24),
                _buildBatteryInfo(context),
              ],
            ),
          ),
          
          // Emergency Overlay
          emergencyAsync.when(
            data: (eEvent) {
              if (eEvent.state == EmergencyState.countingDown || 
                  eEvent.state == EmergencyState.triggered ||
                  eEvent.state == EmergencyState.cancelled) {
                return _EmergencyOverlay(event: eEvent);
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Active',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Monitoring motion sensors in real-time'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.battery_saver, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Optimized for low battery usage. Sensors are only active while this screen is visible.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable widget to display sensor data in a Card.
class _SensorDataCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AsyncValue<SensorData> data;
  final Color color;

  const _SensorDataCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            data.when(
              data: (sensorData) => _buildDataGrid(sensorData),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataGrid(SensorData sensorData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildValueItem('X-Axis', sensorData.x.toStringAsFixed(3)),
        _buildValueItem('Y-Axis', sensorData.y.toStringAsFixed(3)),
        _buildValueItem('Z-Axis', sensorData.z.toStringAsFixed(3)),
      ],
    );
  }

  Widget _buildValueItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// A specialized widget to display G-force with an animated meter.
class _GForceMeterCard extends StatelessWidget {
  final AsyncValue<GForceData> data;
  final double maxGForce;

  const _GForceMeterCard({
    required this.data,
    required this.maxGForce,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'G-Force Analysis',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MAX: ${maxGForce.toStringAsFixed(2)}G',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            data.when(
              data: (gData) => _buildMeter(context, gData),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeter(BuildContext context, GForceData gData) {
    // Normalize G-force for the progress indicator (cap at 10G for UI)
    final double normalizedValue = (gData.gForce / 10.0).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: CircularProgressIndicator(
                value: normalizedValue,
                strokeWidth: 12,
                backgroundColor: Colors.grey.withOpacity(0.1),
                color: gData.color,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gData.gForce.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const Text(
                  'G-FORCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: gData.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gData.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: gData.color, size: 20),
              const SizedBox(width: 8),
              Text(
                gData.label.toUpperCase(),
                style: TextStyle(
                  color: gData.color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A specialized widget to display Speed and Deceleration analysis.
class _SpeedMonitoringCard extends StatelessWidget {
  final AsyncValue<SpeedData> data;
  final double maxSpeed;
  final double maxDecel;

  const _SpeedMonitoringCard({
    required this.data,
    required this.maxSpeed,
    required this.maxDecel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Speed & Braking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'MAX: ${maxSpeed.toStringAsFixed(1)} km/h',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      'BRAKE: ${maxDecel.abs().toStringAsFixed(2)} m/s²',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            data.when(
              data: (sData) => _buildSpeedometer(context, sData),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _buildErrorState(err),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedometer(BuildContext context, SpeedData sData) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              sData.speed.toStringAsFixed(0),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 4),
            const Text(
              'km/h',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              'DECEL',
              '${sData.deceleration.toStringAsFixed(2)} m/s²',
              sData.color,
            ),
            _buildStatItem(
              'ACCURACY',
              '±${sData.accuracy.toStringAsFixed(1)}m',
              sData.accuracy > 20 ? Colors.red : Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sData.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              sData.label.toUpperCase(),
              style: TextStyle(
                color: sData.color,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Column(
      children: [
        const Icon(Icons.location_off, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text(
          'GPS Error: $error',
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// A specialized widget to display Crash Confidence Analysis.
class _CrashConfidenceCard extends StatelessWidget {
  final CrashEvent event;

  const _CrashConfidenceCard({
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: event.color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: event.color.withOpacity(0.5),
          width: event.confidenceScore > 0.5 ? 2 : 0,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Crash Intelligence',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONFIDENCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(event.confidenceScore * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: event.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.severityLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: event.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: event.confidenceScore,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: event.color,
                        ),
                        Icon(
                          _getIconForSeverity(event.severity),
                          color: event.color,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRIMARY TRIGGER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.triggerReason,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (event.confidenceScore > 0.5) ...[
              const SizedBox(height: 12),
              _buildWarningBanner(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'High impact detected. Preparing emergency protocols...',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSeverity(CrashSeverity severity) {
    switch (severity) {
      case CrashSeverity.low:
        return Icons.verified_user;
      case CrashSeverity.moderate:
        return Icons.info_outline;
      case CrashSeverity.high:
        return Icons.warning_amber_rounded;
      case CrashSeverity.critical:
        return Icons.emergency_share;
    }
  }
}

/// A full-screen overlay for Emergency Countdown and SOS.
class _EmergencyOverlay extends ConsumerWidget {
  final EmergencyEvent event;

  const _EmergencyOverlay({
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isTriggered = event.state == EmergencyState.triggered;
    final bool isCancelled = event.state == EmergencyState.cancelled;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isCancelled 
          ? Colors.green.withOpacity(0.95)
          : Colors.red.withOpacity(0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            children: [
              _buildHeader(context, isTriggered, isCancelled),
              const Spacer(),
              _buildMainContent(context, isTriggered, isCancelled),
              const Spacer(),
              if (!isTriggered && !isCancelled) _buildActionButtons(context, ref),
              if (isTriggered || isCancelled) 
                ElevatedButton(
                  onPressed: () => ref.read(emergencyServiceProvider).cancelEmergency(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isCancelled ? Colors.green : Colors.red,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTriggered, bool isCancelled) {
    String title = 'CRASH DETECTED';
    if (isTriggered) title = 'SOS TRIGGERED';
    if (isCancelled) title = 'SAFE';

    return Column(
      children: [
        Icon(
          isCancelled ? Icons.verified_user : Icons.emergency,
          color: Colors.white,
          size: 80,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, bool isTriggered, bool isCancelled) {
    if (isCancelled) {
      return const Column(
        children: [
          Text(
            'Emergency sequence cancelled.',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Glad you are safe!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      );
    }

    if (isTriggered) {
      return const Column(
        children: [
          Text(
            'EMERGENCY SERVICES NOTIFIED',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Text(
            'Sending your location and sensor data...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Text(
          'ARE YOU OKAY?',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator(
                value: event.countdownRemaining / 10.0,
                strokeWidth: 15,
                color: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
            Text(
              '${event.countdownRemaining}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          'Reason: ${event.triggerReason}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => ref.read(emergencyServiceProvider).cancelEmergency(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 70),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
          ),
          child: const Text(
            "I'M SAFE",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => ref.read(emergencyServiceProvider).triggerSos(),
          child: const Text(
            'CALL HELP NOW',
            style: TextStyle(color: Colors.white, fontSize: 18, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
