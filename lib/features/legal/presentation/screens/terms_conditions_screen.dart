import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "1. Acceptance of Terms",
              "By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "2. Description of Service",
              "We provide a personal finance and budgeting application. You are responsible for obtaining access to the service and that access may involve third party fees (such as Internet service provider or airtime charges).",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "3. User Account",
              "You are responsible for maintaining the confidentiality of the password and account, and are fully responsible for all activities that occur under your password or account.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "4. User Conduct",
              "You agree to use the app only for lawful purposes. You are prohibited from posting on or transmitting through the App any unlawful, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, sexually explicit, profane, hateful, racially, ethnically, or otherwise objectionable material of any kind.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "5. Termination",
              "We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "6. Limitation of Liability",
              "In no event shall we be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Last Updated: January 2026",
                style: TextStyle(
                  color: kSecondarySlate,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    Color titleColor,
    Color contentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: contentColor, height: 1.6),
          ),
        ],
      ),
    );
  }
}
