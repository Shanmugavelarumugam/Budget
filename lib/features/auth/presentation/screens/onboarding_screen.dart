import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Global Background Blobs (Static for smoothness, or animated if desired)
          Positioned(
            top: -100,
            right: -100,
            child: _BlurredBlob(
              color: const Color(0xFFEFF6FF),
              size: 400,
            ), // Blue-50
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: _BlurredBlob(
              color: const Color(0xFFF5F3FF),
              size: 350,
            ), // Violet-50
          ),

          SafeArea(
            child: Column(
              children: [
                // Header (Skip Button)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < 2)
                        TextButton(
                          onPressed: () {
                            _controller.jumpToPage(2);
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: const [
                      _SecurePage(),
                      _InsightsPage(),
                      _TransferPage(),
                    ],
                  ),
                ),

                // Bottom Controls (Indicators + Button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.black : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Main Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < 2) {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const WelcomeScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            _currentPage == 2 ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// --- Page 1: Secure Your Future ---
class _SecurePage extends StatelessWidget {
  const _SecurePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Back Glows
              Positioned(
                top: 40,
                left: 40,
                child: _Glow(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.2),
                ),
              ),
              Positioned(
                bottom: 40,
                right: 40,
                child: _Glow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                ),
              ),

              // Shields
              Transform.rotate(
                angle: -4 * math.pi / 180,
                child: _GlassShield(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0066FF).withValues(alpha: 0.3),
                      const Color(0xFF0066FF).withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
              Transform.rotate(
                angle: 4 * math.pi / 180,
                child: _GlassShield(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: Color(0xFF0066FF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: const [
                Text(
                  'Secure Your Future',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Experience institutional-grade security for your personal assets with our advanced encryption.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Page 2: Smart Insights ---
class _InsightsPage extends StatelessWidget {
  const _InsightsPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Charts Container
              SizedBox(
                width: 280,
                height: 260,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassBar(
                      heightFactor: 0.4,
                      color: const Color(0xFF0066FF),
                    ),
                    _GlassBar(
                      heightFactor: 0.6,
                      color: const Color(0xFF8B5CF6),
                    ),
                    _GlassBar(
                      heightFactor: 0.5,
                      color: const Color(0xFF0066FF),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const _GlassBar(
                          heightFactor: 0.85,
                          color: Color(0xFF8B5CF6),
                          isMain: true,
                        ),
                        Positioned(
                          top: -16,
                          right: -16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              size: 18,
                              color: Color(0xFF0066FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _GlassBar(
                      heightFactor: 1.0,
                      color: const Color(0xFF0066FF),
                    ),
                  ],
                ),
              ),
              // Live Analysis Badge
              Positioned(
                top: 40,
                left: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0066FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'LIVE ANALYSIS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: const [
                Text(
                  'Smart Insights',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Track your wealth in real-time with automated portfolio analysis and smart market alerts.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Page 3: Seamless Transfer ---
class _TransferPage extends StatelessWidget {
  const _TransferPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rings
                  Positioned(
                    top: 20,
                    left: 40,
                    child: _GlassRing(
                      color: const Color(0xFF0066FF),
                      size: 180,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 40,
                    child: _GlassRing(
                      color: const Color(0xFF8B5CF6),
                      size: 180,
                    ),
                  ),

                  // Decorative dots
                  Positioned(
                    top: 40,
                    right: 60,
                    child: _Dot(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 60,
                    child: _Dot(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ),
                  ),

                  // Center Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sync_alt,
                      size: 32,
                      color: Color(0xFF0066FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: const [
                Text(
                  'Seamless Transfer',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Move capital across borders and accounts with zero friction and total transparency.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Helpers ---

class _GlassShield extends StatelessWidget {
  final Gradient gradient;
  final Widget? child;

  const _GlassShield({required this.gradient, this.child});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ShieldClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 220, // Increased size
          height: 260, // Increased size
          decoration: BoxDecoration(
            gradient: gradient,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // polygon(50% 0%, 100% 15%, 100% 50%, 50% 100%, 0% 50%, 0% 15%)
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.15);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.5);
    path.lineTo(0, size.height * 0.15);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _GlassBar extends StatelessWidget {
  final double heightFactor;
  final Color color;
  final bool isMain;

  const _GlassBar({
    required this.heightFactor,
    required this.color,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        width: 45, // Slightly wider
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
            bottom: Radius.circular(4),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color.withValues(alpha: 0.1), // Increased opacity
              color.withValues(alpha: isMain ? 0.3 : 0.2), // Increased opacity
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ), // Stronger border
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Removed BackdropFilter for clearer bars on white
      ),
    );
  }
}

class _GlassRing extends StatelessWidget {
  final Color color;
  final double size;

  const _GlassRing({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ], // Increased opacity
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(8, 8),
          ),
        ],
      ),
      // Removed BackdropFilter to prevent washing out on white background
    );
  }
}

class _BlurredBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurredBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  const _Glow({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
