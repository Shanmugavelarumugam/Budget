import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

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
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const kPrimaryPurple = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'App Theme',
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
            _buildThemeOption(
              context,
              title: "System Default",
              description: "Match your device's appearance settings",
              mode: ThemeMode.system,
              currentMode: settings.themeMode,
              icon: Icons.brightness_auto_rounded,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              kBorderSlate: kBorderSlate,
              kPrimaryPurple: kPrimaryPurple,
              kCardBackground: kCardBackground,
              isDark: isDark,
            ),
            _buildThemeOption(
              context,
              title: "Light Mode",
              description: "Always use light mode",
              mode: ThemeMode.light,
              currentMode: settings.themeMode,
              icon: Icons.light_mode_rounded,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              kBorderSlate: kBorderSlate,
              kPrimaryPurple: kPrimaryPurple,
              kCardBackground: kCardBackground,
              isDark: isDark,
            ),
            _buildThemeOption(
              context,
              title: "Dark Mode",
              description: "Always use dark mode",
              mode: ThemeMode.dark,
              currentMode: settings.themeMode,
              icon: Icons.dark_mode_rounded,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              kBorderSlate: kBorderSlate,
              kPrimaryPurple: kPrimaryPurple,
              kCardBackground: kCardBackground,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String description,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    required Color kAccentSlate,
    required Color kBorderSlate,
    required Color kPrimaryPurple,
    required Color kCardBackground,
    required bool isDark,
  }) {
    final isSelected = mode == currentMode;
    // Visual distinction relies on Border and Icon color.

    return GestureDetector(
      onTap: () {
        context.read<SettingsProvider>().setThemeMode(mode);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBackground, // Uniform background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? kPrimaryPurple.withValues(alpha: 0.5)
                : kBorderSlate,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kPrimaryPurple : kBorderSlate,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? kPrimaryPurple : kSecondarySlate,
              ),
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
                      color: isSelected ? kPrimarySlate : kSecondarySlate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: kSecondarySlate.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: kPrimaryPurple),
          ],
        ),
      ),
    );
  }
}
