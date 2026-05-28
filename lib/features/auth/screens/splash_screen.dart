import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 12 * math.pi / 180).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
    
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: Stack(
        children: [
          // Background soft image blur fallback
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.network(
                "https://images.unsplash.com/photo-1776042675345-14404ffbcd29?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzb2Z0JTIwZGFyayUyMGZsdWlkJTIwYWJzdHJhY3R8ZW58MXx8fHwxNzc5MjY0NTAyfDA&ixlib=rb-4.1.0&q=80&w=1080",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.slate900,
                ),
              ),
            ),
          ),
          
          // Blur layer
          Positioned.fill(
            child: Container(
              color: AppColors.slate950.withOpacity(0.8),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Soft glow ring
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.rose500.withOpacity(0.15),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.rose500.withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Rotated shield container
                            Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.rose600.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Transform.rotate(
                                  angle: -_rotationAnimation.value,
                                  child: const Center(
                                    child: Icon(
                                      Icons.shield_outlined,
                                      color: Colors.white,
                                      size: 44,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Animated Title
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                          children: [
                            TextSpan(
                              text: 'ROAD',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'SOS',
                              style: TextStyle(color: AppColors.rose400),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Animated Subtitle
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: const Text(
                        'Intelligent Emergency Response',
                        style: TextStyle(
                          color: AppColors.slate400,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Progress Loader
                Container(
                  width: 180,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      color: AppColors.rose400,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
