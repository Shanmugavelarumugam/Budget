import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

// Premium Slate Design System keys
const kAppBackground = Colors.white;
const kPrimarySlate = Color(0xFF0F172A);
const kSecondarySlate = Color(0xFF64748B);
const kAccentSlate = Color(0xFFF8FAFC);
const kPrimaryPurple = Color(0xFF8B5CF6);

class AppLockSettingsScreen extends StatelessWidget {
  const AppLockSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: const Text(
          'Security',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kPrimarySlate,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kAccentSlate,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          color: kPrimaryPurple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Biometric Lock",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kPrimarySlate,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Require FaceID/TouchID to open app",
                              style: TextStyle(
                                fontSize: 12,
                                color: kSecondarySlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: settings.isAppLockEnabled,
                        onChanged: (value) {
                          context.read<SettingsProvider>().setAppLock(value);
                        },
                        activeTrackColor: kPrimaryPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (settings.isAppLockEnabled) ...[
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: kSecondarySlate,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "App lock will be required immediately when you open the app.",
                      style: TextStyle(color: kSecondarySlate, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
