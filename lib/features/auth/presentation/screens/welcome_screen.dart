
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgets/features/auth/presentation/providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            left: -100,
            child: _BlurredBlob(
              color: const Color(0xFFEFF6FF),
              size: 400,
            ), // Blue-50
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: _BlurredBlob(
              color: const Color(0xFFF5F3FF),
              size: 350,
            ), // Violet-50
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Hero Logo
                  const SizedBox(height: 240, child: AeroLogo()),

                  const SizedBox(height: 40),

                  // Branding Text
                  const Text(
                    'AERO CAPITAL',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: Color(0xFF0F172A), // Slate 900
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 1, width: 20, color: Colors.grey[300]),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'FLUID WEALTH MANAGEMENT',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: Color(0xFF94A3B8), // Slate 400
                          ),
                        ),
                      ),
                      Container(height: 1, width: 20, color: Colors.grey[300]),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A), // Slate 900
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.3),
                        elevation: 8,
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A), // Slate 900
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ), // Slate 200
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  TextButton(
                    onPressed: () async {
                      await auth.enterGuestMode();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/dashboard',
                          (route) => false,
                        );
                      }
                    },
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                        color: Color(0xFF64748B), // Slate 500
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Specific Widgets for Welcome Screen to keep it self-contained ---

class _BlurredBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurredBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0.0)],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}

class AeroLogo extends StatelessWidget {
  const AeroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
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
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.topLeft : Alignment.topRight,
          end: isLeft ? Alignment.bottomRight : Alignment.bottomLeft,
          colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: isLeft ? const Radius.circular(100) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(100) : Radius.zero,
          topRight: !isLeft ? const Radius.circular(100) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(100) : Radius.zero,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      // No internal blur for this version to ensure pop on white
    );
  }
}
