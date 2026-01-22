import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const LoadingScreen({super.key, this.message, this.isOverlay = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kPrimaryPurple = const Color(0xFF8B5CF6);

    Widget content() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Loader
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryPurple),
                backgroundColor: kPrimaryPurple.withValues(alpha: 0.1),
              ),
            ),

            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kSecondarySlate,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (isOverlay) {
      return Container(
        color: kAppBackground.withValues(alpha: 0.8),
        child: content(),
      );
    }

    return Scaffold(
      backgroundColor: kAppBackground,
      body: SafeArea(child: content()),
    );
  }
}
