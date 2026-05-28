import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: Stack(
        children: [
          // Top 60% Map Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.4 - 20, // Leave 40% for bottom panel with overlap
            child: Stack(
              children: [
                // Map Background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.network(
                      "https://images.unsplash.com/photo-1610309315045-8c0292ab5259?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkYXJrJTIwbmlnaHQlMjBtYXAlMjB2aWV3fGVufDF8fHx8MTc3OTI2NDAxMXww&ixlib=rb-4.1.0&q=80&w=1080",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.slate950,
                      ),
                    ),
                  ),
                ),
                
                // Back Button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0A0E27).withOpacity(0.8),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
                
                // Mock Pins and Route
                // Route Line
                Positioned(
                  top: 150,
                  left: 100,
                  child: CustomPaint(
                    size: const Size(150, 200),
                    painter: _DottedRoutePainter(),
                  ),
                ),
                
                // Victim Pin
                const Positioned(
                  top: 350,
                  left: 130,
                  child: _VictimPin(),
                ),
                
                // Ambulance Pin
                Positioned(
                  top: 250,
                  left: 230,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.local_hospital, color: AppColors.rose500, size: 20),
                  ),
                ),
                
                // Hospital Pin
                Positioned(
                  top: 130,
                  left: 100,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.emerald500,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'H',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom 40% Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.45, // Slight overlap
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.slate900.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 48,
                    height: 6,
                    margin: const EdgeInsets.only(top: 12, bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  
                  // ETA
                  const Text(
                    '8:42',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald500,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ambulance en route',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Cards
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Ambulance Card
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Unit DL-1A-4923',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Paramedic: Rajesh K.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.rose500.withOpacity(0.2),
                                  border: Border.all(color: AppColors.rose500.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ALS',
                                  style: TextStyle(
                                    color: AppColors.rose500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Hospital Card
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald500.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  'H',
                                  style: TextStyle(
                                    color: AppColors.emerald500,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AIIMS Trauma Centre',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.checkCircle2, color: AppColors.emerald500, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ER pre-alerted',
                                          style: TextStyle(
                                            color: AppColors.emerald500,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'HRS 9.2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Row(
                      children: [
                        Expanded(child: _buildActionButton(LucideIcons.phone, 'Call')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionButton(LucideIcons.share2, 'Share')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionButton(LucideIcons.heartPulse, 'First Aid')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VictimPin extends StatefulWidget {
  const _VictimPin();

  @override
  State<_VictimPin> createState() => _VictimPinState();
}

class _VictimPinState extends State<_VictimPin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
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
            return Opacity(
              opacity: 0.2 + (_controller.value * 0.3),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.rose500,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.rose500,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }
}

class _DottedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.rose500.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height); // Start at bottom left (hospital)
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.8, size.width, 0); // End at top right (victim)

    // Dash path
    const double dashWidth = 8, dashSpace = 6;
    double distance = 0;
    
    // We would use a library for accurate dashing, but for a mockup this approximates it
    // A simplified dash drawing using dashed path package or manual calculation is complex
    // Here we just draw a solid line since path dashing requires external packages in Flutter
    // Or we can draw discrete dots
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
