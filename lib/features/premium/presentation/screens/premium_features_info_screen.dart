import 'package:flutter/material.dart';
import '../../../../routes/route_names.dart';

/// Premium Features Info Screen - Matches app's actual design
class PremiumFeaturesInfoScreen extends StatelessWidget {
  const PremiumFeaturesInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kInputFill = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kPrimarySlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Light background blobs (like login screen)
          if (!isDark) ...[
            Positioned(
              top: -100,
              left: -100,
              child: _BlurredBlob(color: const Color(0xFFEFF6FF), size: 400),
            ),
            Positioned(
              bottom: -50,
              right: -100,
              child: _BlurredBlob(color: const Color(0xFFF5F3FF), size: 350),
            ),
          ],

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  const Text(
                    'Premium Features',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock powerful tools to take control of your finances.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Premium Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kInputFill,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 64,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // What You Have
                  const Text(
                    'WHAT YOU HAVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    icon: Icons.receipt_long,
                    title: 'Track transactions',
                    description: 'Monitor daily income & expenses',
                    color: Colors.green,
                    kInputFill: kInputFill,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                  ),
                  _buildFeatureCard(
                    icon: Icons.bar_chart,
                    title: 'Monthly reports',
                    description: 'See spending overview',
                    color: Colors.green,
                    kInputFill: kInputFill,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                  ),
                  _buildFeatureCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Basic budgets',
                    description: 'Set monthly limits',
                    color: Colors.green,
                    kInputFill: kInputFill,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                  ),

                  const SizedBox(height: 32),

                  // Unlock with Premium
                  const Text(
                    'UNLOCK WITH PREMIUM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    icon: Icons.file_download,
                    title: 'Unlimited export',
                    description: 'Keep data safe in Excel',
                    color: const Color(0xFF0F172A),
                    kInputFill: kInputFill,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                    isPremium: true,
                  ),
                  _buildFeatureCard(
                    icon: Icons.insights,
                    title: 'Advanced analytics',
                    description: 'Understand spending habits',
                    color: const Color(0xFF0F172A),
                    kInputFill: kInputFill,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                    isPremium: true,
                  ),
                  _buildFeatureCard(
                    icon: Icons.family_restroom,
                    title: 'Family sharing',
                    description: 'Share without losing control',
                    color: const Color(0xFF0F172A),
                    kInputFill: kInputFill,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                    isPremium: true,
                  ),
                  _buildFeatureCard(
                    icon: Icons.savings,
                    title: 'Savings goals',
                    description: 'Stay motivated to save',
                    color: const Color(0xFF0F172A),
                    kInputFill: kInputFill,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                    isPremium: true,
                  ),

                  const SizedBox(height: 32),

                  // Trust Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kInputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why Premium?',
                          style: TextStyle(
                            color: kPrimarySlate,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTrustItem(
                          Icons.cancel,
                          'Cancel anytime',
                          kSecondarySlate,
                        ),
                        _buildTrustItem(
                          Icons.block,
                          'No ads, ever',
                          kSecondarySlate,
                        ),
                        _buildTrustItem(
                          Icons.security,
                          'Secure payments',
                          kSecondarySlate,
                        ),
                        _buildTrustItem(
                          Icons.privacy_tip,
                          'Data privacy respected',
                          kSecondarySlate,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA Buttons
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.upgradeToPro);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'UPGRADE TO PRO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Maybe Later',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color kInputFill,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    bool isPremium = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kInputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kPrimarySlate,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: kSecondarySlate),
                ),
              ],
            ),
          ),
          Icon(
            isPremium ? Icons.lock : Icons.check_circle,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 18),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
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
