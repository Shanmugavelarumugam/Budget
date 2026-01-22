import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../routes/route_names.dart';

class DataStorageScreen extends StatelessWidget {
  const DataStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isGuest = user?.isGuest ?? true;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const kSuccessGreen = Color(0xFF22C55E);
    const kWarningOrange = Color(0xFFF59E0B);

    final lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
    final lastSyncStr = DateFormat('MMM d, h:mm a').format(lastSyncTime);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Data & Storage',
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "Manage where your data lives and ensure it's safely backed up.",
                style: TextStyle(color: kSecondarySlate, fontSize: 14),
              ),
            ),

            // 1. Storage Info Section
            _buildSectionHeader("STORAGE INFO", kSecondarySlate),
            _buildInfoCard(
              context,
              icon: isGuest
                  ? Icons.phone_android_rounded
                  : Icons.cloud_done_rounded,
              iconColor: isGuest ? kWarningOrange : kSuccessGreen,
              title: isGuest ? "Local Storage Only" : "Cloud Synced",
              subtitle: isGuest
                  ? "Your data is stored only on this device. Create an account to enable cloud backups."
                  : "Your data is securely backed up and synced across all your devices.",
              isDark: isDark,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              kBorderSlate: kBorderSlate,
            ),

            const SizedBox(height: 16),

            // 2. Sync Status Section
            _buildSectionHeader("SYNC STATUS", kSecondarySlate),
            _buildListTile(
              icon: Icons.sync_rounded,
              title: isGuest ? "Sync Not Available" : "Last Synced",
              subtitle: isGuest
                  ? "Guest Mode does not support cloud sync"
                  : lastSyncStr,
              trailing: isGuest
                  ? null
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kSuccessGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "AUTO",
                        style: TextStyle(
                          color: kSuccessGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              onTap: () {
                if (!isGuest) {
                  Navigator.pushNamed(context, RouteNames.syncStatus);
                }
              },
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              showArrow: !isGuest,
            ),

            const SizedBox(height: 16),

            // 3. Export Section
            _buildSectionHeader("DATA MANAGEMENT", kSecondarySlate),
            _buildListTile(
              icon: Icons.file_download_outlined,
              title: "Export All Data",
              subtitle: isGuest
                  ? "Create account to export csv"
                  : "Download your financial history (CSV)",
              onTap: () {
                if (isGuest) {
                  _showGuestExportWarning(
                    context,
                    kPrimarySlate,
                    kSecondarySlate,
                    kAccentSlate,
                  );
                } else {
                  Navigator.pushNamed(context, RouteNames.exportData);
                }
              },
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
              showArrow: !isGuest,
            ),

            const SizedBox(height: 48),
            Center(
              child: Text(
                "Your privacy is our priority.\nData is encrypted during transit and at rest.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kSecondarySlate.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
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
          fontWeight: FontWeight.w800,
          color: kSecondarySlate,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    required Color kAccentSlate,
    required Color kBorderSlate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kAccentSlate.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kBorderSlate),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: kPrimarySlate,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kSecondarySlate,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool showArrow = false,
    required VoidCallback onTap,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    required Color kAccentSlate,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kAccentSlate,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kPrimarySlate, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: kPrimarySlate,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: kSecondarySlate, fontSize: 13),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing,
          if (showArrow) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: kSecondarySlate, size: 20),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  void _showGuestExportWarning(
    BuildContext context,
    Color kPrimary,
    Color kSecondary,
    Color kAccent,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 24),
            Text(
              "Account Required",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Data export is a premium feature that requires a secure account to protect your financial privacy.",
              textAlign: TextAlign.center,
              style: TextStyle(color: kSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/welcome', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Create Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
