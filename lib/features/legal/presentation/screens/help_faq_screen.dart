import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Help & FAQ',
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFaqItem(
            context,
            question: "How do I add a transaction?",
            answer:
                "Tap the floating '+' button on the dashboard or transactions screen. Enter the amount, select a category, and save.",
            kPrimarySlate: kPrimarySlate,
            kSecondarySlate: kSecondarySlate,
            kCardBackground: kCardBackground,
            kBorderSlate: kBorderSlate,
          ),
          _buildFaqItem(
            context,
            question: "Can I use the app offline?",
            answer:
                "Yes! If you are in Guest Mode, all data is stored locally. If you are signed in, data syncs when you are back online.",
            kPrimarySlate: kPrimarySlate,
            kSecondarySlate: kSecondarySlate,
            kCardBackground: kCardBackground,
            kBorderSlate: kBorderSlate,
          ),
          _buildFaqItem(
            context,
            question: "How do I change my currency?",
            answer:
                "Go to Profile > App Preferences > Currency and select your preferred currency from the list.",
            kPrimarySlate: kPrimarySlate,
            kSecondarySlate: kSecondarySlate,
            kCardBackground: kCardBackground,
            kBorderSlate: kBorderSlate,
          ),
          _buildFaqItem(
            context,
            question: "Is my data secure?",
            answer:
                "We use industry-standard encryption for all synced data. Your local guest data never leaves your device.",
            kPrimarySlate: kPrimarySlate,
            kSecondarySlate: kSecondarySlate,
            kCardBackground: kCardBackground,
            kBorderSlate: kBorderSlate,
          ),
          _buildFaqItem(
            context,
            question: "How do I reset my data?",
            answer:
                "If you are a guest, logging out clears all data. If you are a signed-in user, you can manually delete transactions or contact support to wipe your account.",
            kPrimarySlate: kPrimarySlate,
            kSecondarySlate: kSecondarySlate,
            kCardBackground: kCardBackground,
            kBorderSlate: kBorderSlate,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    required Color kCardBackground,
    required Color kBorderSlate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSlate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: kPrimarySlate,
          collapsedIconColor: kPrimarySlate,
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kPrimarySlate,
              fontSize: 15,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(answer, style: TextStyle(color: kSecondarySlate, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
