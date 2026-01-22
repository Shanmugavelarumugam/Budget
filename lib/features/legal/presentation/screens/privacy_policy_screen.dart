import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
              "1. Introduction",
              "Welcome to Budgets. We are committed to protecting your personal information and your right to privacy.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "2. Information We Collect",
              "We collect personal information that you provide to us (such as name and email) and financial data you input (such as transaction history and budget limits). If you use Guest Mode, all data is stored locally on your device.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "3. How We Use Your Information",
              "We use your information to provide functionality, improve user experience, and ensure security. We do not sell your personal data.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "4. Data Security",
              "We implement security measures designed to protect your data. However, no electronic transmission over the internet or information storage technology can be guaranteed to be 100% secure.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "5. Guest Mode",
              "In Guest Mode, your data never leaves your device unless you choose to create an account and sync it.",
              kPrimarySlate,
              kSecondarySlate,
            ),
            _buildSection(
              "6. Contact Us",
              "If you have questions or comments about this policy, please contact our support team.",
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
