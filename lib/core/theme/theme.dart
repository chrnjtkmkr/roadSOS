import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable styling constants for premium dark UI aesthetics.
class AppColors {
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate400 = Color(0xFF94A3B8);
  
  static const Color rose500 = Color(0xFFF43F5E); // Primary Rose accent
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose600 = Color(0xFFE11D48);
  
  static const Color indigo500 = Color(0xFF6366F1); // Primary Indigo accent
  static const Color indigo400 = Color(0xFF818CF8);
  
  static const Color emerald400 = Color(0xFF34D399); // Active state green
  static const Color emerald500 = Color(0xFF10B981);
  
  static const Color cyan400 = Color(0xFF22D3EE); // AI cyan color
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color amber300 = Color(0xFFFCD34D);
}

class AppGradients {
  static const LinearGradient roseToIndigo = LinearGradient(
    colors: [AppColors.indigo500, AppColors.rose500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient bgGradients = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF020617)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Reusable Glassmorphic Card widget matching Figma's glass effect.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
