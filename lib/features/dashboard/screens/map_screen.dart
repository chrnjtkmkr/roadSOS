import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _activeFilter = "All";
  bool _sheetExpanded = true;

  final List<String> _filters = const ["All", "Trauma L1", "ICU", "Blood Bank", "Nearest"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dark Map background simulation
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.network(
                "https://images.unsplash.com/photo-1610309315045-8c0292ab5259?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkYXJrJTIwbmlnaHQlMjBtYXAlMjB2aWV3fGVufDF8fHx8MTc3OTI2NDAxMXww&ixlib=rb-4.1.0&q=80&w=1080",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.slate950,
                ),
              ),
            ),
          ),
          
          // Map Pins overlay
          // User position pin
          const Positioned(
            top: 300,
            left: 180,
            child: _UserLocationPin(),
          ),
          
          // Hospital Pin 1: AIIMS (Green)
          Positioned(
            top: 210,
            left: 90,
            child: _buildHospitalPin("✚ 9.2", AppColors.emerald400),
          ),
          
          // Hospital Pin 2: Safdarjung (Yellow)
          Positioned(
            top: 360,
            left: 240,
            child: _buildHospitalPin("✚ 6.5", Colors.amberAccent),
          ),
          
          // Hospital Pin 3: Max (Red)
          Positioned(
            top: 150,
            left: 270,
            child: _buildHospitalPin("✚ 3.1", AppColors.rose400),
          ),

          // Search Bar & Filter Chips
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Input Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search hospitals...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeFilter = filter;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Sliding Draggable Bottom Sheet for Trauma Centers list
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _sheetExpanded ? 460 : 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.slate900.withOpacity(0.95),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Handle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sheetExpanded = !_sheetExpanded;
                          });
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom Sheet Title bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nearby Trauma Centres',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '3 found',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Hospital items list
                      if (_sheetExpanded)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 90),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildHospitalCard(
                                title: 'AIIMS Trauma Centre',
                                beds: '4 Beds',
                                otStatus: 'OT: Available',
                                statusColor: AppColors.emerald400,
                                score: '9.2',
                                scoreColor: AppColors.emerald400,
                                distance: '3.2 km away',
                                eta: 'ETA: 8 mins',
                              ),
                              const SizedBox(height: 16),
                              _buildHospitalCard(
                                title: 'Safdarjung Hospital',
                                beds: '1 Bed',
                                otStatus: 'OT: Busy',
                                statusColor: Colors.amberAccent,
                                score: '6.5',
                                scoreColor: Colors.amberAccent,
                                distance: '4.5 km away',
                                eta: 'ETA: 14 mins',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalPin(String score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 8),
              const SizedBox(width: 2),
              Text(
                score.substring(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard({
    required String title,
    required String beds,
    required String otStatus,
    required Color statusColor,
    required String score,
    required Color scoreColor,
    required String distance,
    required String eta,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        beds,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.white24)),
                      const SizedBox(width: 8),
                      Text(
                        otStatus,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // HRS Indicator Gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: double.parse(score) / 10.0,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    score,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                distance,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
              Text(
                eta,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation, color: Colors.white, size: 16),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rose500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Pre-Alert ER'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserLocationPin extends StatefulWidget {
  const _UserLocationPin();

  @override
  State<_UserLocationPin> createState() => _UserLocationPinState();
}

class _UserLocationPinState extends State<_UserLocationPin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
              scale: 1.0 + (_controller.value * 2.0),
              child: Opacity(
                opacity: (1.0 - _controller.value) * 0.6,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.indigo400.withOpacity(0.4),
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
