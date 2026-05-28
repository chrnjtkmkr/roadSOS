import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../providers/navigation_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  bool _loading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Simulate skeleton loader
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildSkeleton();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'New Delhi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.rose500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Greeting & Active Dot
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stay Safe, Priya',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Live Pulse Dot
                        _PulsingDot(color: AppColors.emerald400),
                        const SizedBox(width: 8),
                        const Text(
                          'Crash detection active',
                          style: TextStyle(
                            color: AppColors.emerald400,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Big Pulsing SOS Button Center
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/sos');
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing background rings
                        for (int i = 0; i < 3; i++)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final double progress = (_pulseController.value + (i * 0.33)) % 1.0;
                              return Transform.scale(
                                scale: 1.0 + (progress * 0.8),
                                child: Opacity(
                                  opacity: (1.0 - progress) * 0.5,
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.rose500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Solid core button
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.rose500,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.rose500.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.rose400.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Services Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  children: [
                    _buildServiceCard(
                      icon: Icons.local_hospital_outlined,
                      color: AppColors.rose400,
                      title: 'Ambulance',
                      subtitle: 'Find Ambulance',
                    ),
                    _buildServiceCard(
                      icon: Icons.favorite_border,
                      color: Colors.tealAccent,
                      title: 'Trauma Centre',
                      subtitle: 'Check readiness',
                    ),
                    _buildServiceCard(
                      icon: Icons.security,
                      color: Colors.amberAccent,
                      title: 'Police Station',
                      subtitle: 'Nearest station',
                    ),
                    _buildServiceCard(
                      icon: Icons.build_outlined,
                      color: Colors.greenAccent,
                      title: 'Vehicle Rescue',
                      subtitle: 'Towing & rescue',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // AI Chat FAB
          Positioned(
            bottom: 96,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                ref.read(currentTabProvider.notifier).state = 2; // Jump to Chat tab
              },
              backgroundColor: AppColors.indigo500,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: AppColors.indigo400.withOpacity(0.5), width: 1),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(currentTabProvider.notifier).state = 1; // Jump to Map tab
      },
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.slate400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSkeletonBlock(width: 100, height: 20),
                _buildSkeletonBlock(width: 40, height: 40, shape: BoxShape.circle),
              ],
            ),
            const SizedBox(height: 32),
            
            // Greeting Skeleton
            _buildSkeletonBlock(width: 180, height: 28),
            const SizedBox(height: 12),
            _buildSkeletonBlock(width: 140, height: 16),
            
            const Spacer(),
            
            // SOS Skeleton
            Center(
              child: _buildSkeletonBlock(width: 160, height: 160, shape: BoxShape.circle),
            ),
            
            const Spacer(),
            
            // Grid Skeleton
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: List.generate(
                4,
                (_) => _buildSkeletonBlock(width: double.infinity, height: 80, radius: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBlock({
    required double width,
    required double height,
    BoxShape shape = BoxShape.rectangle,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
      duration: const Duration(seconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_controller.value * 1.5),
              child: Opacity(
                opacity: 1.0 - _controller.value,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ],
    );
  }
}
