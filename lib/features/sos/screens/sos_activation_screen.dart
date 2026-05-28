import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'live_tracking_screen.dart'; // I will create this next

class SosActivationScreen extends StatefulWidget {
  const SosActivationScreen({super.key});

  @override
  State<SosActivationScreen> createState() => _SosActivationScreenState();
}

class _SosActivationScreenState extends State<SosActivationScreen> with TickerProviderStateMixin {
  int _countdown = 10;
  int _statusStep = 0;
  Timer? _timer;
  
  late AnimationController _progressController;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _startCountdown();
    _startStatusSequence();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _navigateToTracking();
      }
    });
  }

  void _startStatusSequence() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _statusStep = 1);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _statusStep = 2);
    });
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) setState(() => _statusStep = 3);
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _statusStep = 4);
    });
  }

  void _navigateToTracking() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LiveTrackingScreen()),
    );
  }

  void _cancelSos() {
    _timer?.cancel();
    _progressController.stop();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: _cancelSos,
                    icon: const Icon(LucideIcons.x, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Countdown Ring
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: 1.0 - _progressController.value,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            color: Colors.white,
                            strokeCap: StrokeCap.round,
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_countdown',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Location Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AUTO-DETECTED LOCATION',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'NH-48, near Cyber Hub Flyover',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Gurugram, Haryana',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Status Messages
              SizedBox(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Column(
                    children: [
                      if (_statusStep >= 1) _buildStatusItem('Locating nearest ambulance...', AppColors.amber300, isPulsing: _statusStep == 1),
                      if (_statusStep >= 2) _buildStatusItem('Ambulance dispatched!', AppColors.emerald500, isBold: true, isLarge: true),
                      if (_statusStep >= 3) _buildStatusItem('Family notified ✓', AppColors.emerald500),
                      if (_statusStep >= 4) _buildStatusItem('Hospital pre-alerted ✓', AppColors.emerald500),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Cancel Button Text
              TextButton(
                onPressed: _cancelSos,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    'Tap to cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(String text, Color color, {bool isPulsing = false, bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isPulsing) 
            _PulsingDot(color: color)
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isLarge ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
