import 'dart:ui';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[50]!.withValues(alpha: 0.6),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple[50]!.withValues(alpha: 0.4),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // The Logo
          const Center(child: AeroLogo()),

          // Footer / Loading Indicator
          Positioned(
            bottom: 80,
            child: Column(
              children: [
                // Sleek Gradient Loading Bar
                SizedBox(
                  width: 200,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: Color(0xFFF3F4F6), // Cool gray
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5CF6),
                      ), // Violet
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ), // Slate 400
                    SizedBox(width: 6),
                    Text(
                      'SECURE CONNECTION...',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Color(0xFF94A3B8), // Slate 400
                        fontFamily: 'Inter', // Try to match the aesthetic
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AeroLogo extends StatelessWidget {
  const AeroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Wing
          Positioned(
            left: 20,
            top: 10,
            child: Transform.rotate(
              angle: -15 * 3.14159 / 180,
              child: _GlassWing(
                isLeft: true,
                color: const Color(0xFF0066FF), // Sapphire
              ),
            ),
          ),
          // Right Wing (On Top)
          Positioned(
            right: 20,
            top: 10,
            child: Transform.rotate(
              angle: 15 * 3.14159 / 180,
              child: _GlassWing(
                isLeft: false,
                color: const Color(0xFF8B5CF6), // Violet
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassWing extends StatelessWidget {
  final bool isLeft;
  final Color color;

  const _GlassWing({required this.isLeft, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.topLeft : Alignment.topRight,
          end: isLeft ? Alignment.bottomRight : Alignment.bottomLeft,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: isLeft ? const Radius.circular(100) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(100) : Radius.zero,
          topRight: !isLeft ? const Radius.circular(100) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(100) : Radius.zero,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        // Changed ClipR to ClipRRect
        borderRadius: BorderRadius.only(
          topLeft: isLeft ? const Radius.circular(100) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(100) : Radius.zero,
          topRight: !isLeft ? const Radius.circular(100) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(100) : Radius.zero,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
