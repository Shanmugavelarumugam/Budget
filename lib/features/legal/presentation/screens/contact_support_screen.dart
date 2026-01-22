import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final kCardBackground = isDark
        ? const Color(0xFF1E293B)
        : Colors.white; // Or match app BG if desired
    const kPrimaryPurple = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Contact Support',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: kAppBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kPrimarySlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: kAccentSlate,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 64,
                color: kPrimaryPurple,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "How can we help?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: kPrimarySlate,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Our team is available 24/7 to assist you with any issues or questions you may have.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: kSecondarySlate,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "support@budgetsapp.com",
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              kCardBackground: kCardBackground,
              kBorderSlate: kBorderSlate,
              onTap: () {
                Clipboard.setData(
                  const ClipboardData(text: "support@budgetsapp.com"),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Email copied to clipboard"),
                    backgroundColor: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                    action: SnackBarAction(label: 'OK', onPressed: () {}),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              title: "Live Chat",
              subtitle: "Not available in offline mode",
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              kCardBackground: kCardBackground,
              kBorderSlate: kBorderSlate,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Connecting to agent... (Mock)"),
                    backgroundColor: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    required Color kAccentSlate,
    required Color kCardBackground,
    required Color kBorderSlate,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderSlate),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentSlate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kPrimarySlate),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kPrimarySlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: kSecondarySlate),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: kSecondarySlate, size: 20),
          ],
        ),
      ),
    );
  }
}
