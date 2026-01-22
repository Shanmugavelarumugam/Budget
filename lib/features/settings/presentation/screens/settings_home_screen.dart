import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'currency_selection_screen.dart';
import 'theme_settings_screen.dart';
import '../../../../routes/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../data/services/data_deletion_service.dart';
import '../../data/services/local_budget_cleaner.dart';
import '../widgets/deleting_data_dialog.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    const kPrimaryPurple = Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: kAppBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                "Customize how the app works for you",
                style: TextStyle(color: kSecondarySlate, fontSize: 14),
              ),
            ),

            const SizedBox(height: 16),

            // APP PREFERENCES Section
            _buildSectionHeader("APP PREFERENCES", kSecondarySlate),
            _buildListTile(
              icon: Icons.currency_rupee_rounded,
              title: "Currency",
              subtitle: "Change your default currency",
              trailing: Text(
                settingsProvider.currency,
                style: TextStyle(
                  color: kPrimaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrencySelectionScreen(),
                  ),
                );
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
            ),
            _buildListTile(
              icon: Icons.brightness_6_rounded,
              title: "Theme",
              subtitle: "Light, dark or system default",
              trailing: Text(
                settingsProvider.themeMode.name.toUpperCase(),
                style: TextStyle(
                  color: kPrimaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                );
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
            ),

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            // ACCOUNT Section
            _buildSectionHeader("ACCOUNT", kSecondarySlate),
            _buildListTile(
              icon: Icons.person_outline_rounded,
              title: "Edit Profile",
              subtitle: "Update your personal information",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.profile);
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              showArrow: true,
            ),

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            // LEGAL & SUPPORT Section
            _buildSectionHeader("LEGAL & SUPPORT", kSecondarySlate),
            _buildListTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "How we protect your data",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.privacyPolicy);
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              showArrow: true,
            ),
            _buildListTile(
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              subtitle: "App usage guidelines",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.termsConditions);
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              showArrow: true,
            ),
            _buildListTile(
              icon: Icons.history_rounded,
              title: "View Recent Alerts",
              subtitle: "Review your past financial updates",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.alerts);
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              showArrow: true,
            ),

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            // DATA & STORAGE Section
            _buildSectionHeader("DATA & STORAGE", kSecondarySlate),
            _buildListTile(
              icon: Icons.storage_rounded,
              title: "Storage Info",
              subtitle: "View data usage and status",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.dataAndStorage);
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              showArrow: true,
            ),
            _buildListTile(
              icon: Icons.cloud_sync_rounded,
              title: "Sync Status",
              subtitle: "Manage cloud synchronization",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.syncStatus);
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              showArrow: true,
            ),
            _buildListTile(
              icon: Icons.download_rounded,
              title: "Export Shortcut",
              subtitle: "Quick access to data export",
              onTap: () {
                Navigator.pushNamed(context, RouteNames.exportData);
              },
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              showArrow: true,
            ),

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            // ADVANCED Section
            _buildSectionHeader("ADVANCED", kSecondarySlate),
            _buildListTile(
              icon: Icons.cleaning_services_rounded,
              title: "Clear Cache",
              subtitle: "Free up temporary space",
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              onTap: () {
                PaintingBinding.instance.imageCache.clear();
                PaintingBinding.instance.imageCache.clearLiveImages();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cache cleared successfully"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildListTile(
              icon: Icons.restart_alt_rounded,
              title: "Reset App Data",
              subtitle: "Delete ALL data (local + Firebase)",
              iconColor: Colors.redAccent,
              onTap: () => _showResetConfirmation(context),
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color kSecondarySlate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: kSecondarySlate,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    bool showArrow = false,
    required Color kPrimarySlate,
    required Color kAccentSlate,
    required Color kSecondarySlate,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kAccentSlate,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? kPrimarySlate, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kPrimarySlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: kSecondarySlate),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (showArrow)
                Icon(Icons.chevron_right_rounded, color: kSecondarySlate),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);
    const kErrorRed = Color(0xFFEF4444);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kAccentSlate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kErrorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.report_problem_rounded,
                size: 40,
                color: kErrorRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Reset App Data?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kPrimarySlate,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "⚠️ This will delete ALL data:\n\n• Local transactions & budgets\n• Firebase cloud data\n• All settings\n\nYou will be logged out.\nThis action CANNOT be undone!",
              style: TextStyle(
                fontSize: 15,
                color: kSecondarySlate,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Close confirmation dialog

                  // Show beautiful loading dialog
                  DeletingDataDialog.show(context);

                  try {
                    final settingsProvider = context.read<SettingsProvider>();
                    final transactionProvider = context
                        .read<TransactionProvider>();
                    final authProvider = context.read<AuthProvider>();
                    final user = authProvider.user;

                    // Delete Firebase data if user is authenticated
                    if (user != null && !user.isGuest) {
                      final deletionService = DataDeletionService();
                      await deletionService.deleteAllUserData(user.uid);
                    }

                    // Clear local data
                    await transactionProvider.clearGuestData();
                    await settingsProvider.resetSettings();

                    // Clear ALL budget data (including category budget limits)
                    await LocalBudgetCleaner.clearAllBudgets();

                    // Sign out
                    await authProvider.signOut();

                    // Small delay to ensure cleanup
                    await Future.delayed(const Duration(milliseconds: 500));

                    if (context.mounted) {
                      // Close loading dialog using rootNavigator
                      Navigator.of(context, rootNavigator: true).pop();

                      // Small delay before navigation
                      await Future.delayed(const Duration(milliseconds: 100));

                      if (context.mounted) {
                        // Navigate to welcome screen
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          RouteNames.welcome,
                          (route) => false,
                        );

                        // Show success message after navigation
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ All data deleted successfully',
                                ),
                                backgroundColor: Color(0xFF22C55E),
                              ),
                            );
                          }
                        });
                      }
                    }
                  } catch (e) {
                    debugPrint('❌ Reset error: $e');
                    if (context.mounted) {
                      // Close loading dialog
                      Navigator.of(context, rootNavigator: true).pop();

                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorRed,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Delete Everything",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  color: kSecondarySlate,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
