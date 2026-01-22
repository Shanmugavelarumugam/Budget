import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import 'edit_profile_screen.dart';
import 'package:budgets/features/export/presentation/screens/export_data_screen.dart';
import 'package:budgets/features/legal/presentation/screens/privacy_policy_screen.dart';
import 'package:budgets/features/legal/presentation/screens/terms_conditions_screen.dart';
import 'package:budgets/features/legal/presentation/screens/help_faq_screen.dart';
import 'package:budgets/features/legal/presentation/screens/contact_support_screen.dart';
import '../../../../routes/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final user = authProvider.user;
    final isGuest = user?.isGuest ?? true;

    // Theme Colors
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

    const kPrimaryPurple = Color(0xFF6366F1);
    const kSuccessGreen = Color(0xFF22C55E);
    const kWarningOrange = Color(0xFFF59E0B);
    const kErrorRed = Color(0xFFEF4444);

    final lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
    final lastSyncStr = DateFormat('MMM d, h:mm a').format(lastSyncTime);
    final storageType = isGuest ? 'Local only (Guest)' : 'Cloud synced';
    final storageColor = isGuest ? kWarningOrange : kSuccessGreen;

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Profile',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, RouteNames.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Info Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: kAccentSlate,
                    backgroundImage: !isGuest && user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: (isGuest || user?.photoUrl == null)
                        ? Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: kSecondarySlate,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGuest
                              ? 'Guest User'
                              : (user?.displayName ?? 'User'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: kPrimarySlate,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (!isGuest && user?.email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user!.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: kSecondarySlate,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (isGuest)
                          ActionChip(
                            label: const Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: kPrimaryPurple,
                            onPressed: () => _navigateToCreateAccount(context),
                            padding: EdgeInsets.zero,
                          )
                        else
                          ActionChip(
                            label: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: kPrimaryPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: kPrimaryPurple.withValues(
                              alpha: 0.1,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: kBorderSlate,
              indent: 24,
              endIndent: 24,
            ),

            // 2. Account Section
            _buildSectionHeader("ACCOUNT", kSecondarySlate),
            if (isGuest) ...[
              _buildListTile(
                icon: Icons.login_rounded,
                title: "Log In",
                subtitle: "Access your existing account",
                onTap: () => _navigateToLogin(context),
                showArrow: true,
                kPrimarySlate: kPrimarySlate,
                kSecondarySlate: kSecondarySlate,
                kAccentSlate: kAccentSlate,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kWarningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kWarningOrange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: kWarningOrange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Your data is stored only on this device. Create an account to enable cloud sync.",
                          style: TextStyle(
                            color: isDark
                                ? kWarningOrange
                                : const Color(0xFF9A3412),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              _buildListTile(
                icon: Icons.alternate_email_rounded,
                title: "Email Status",
                subtitle: "Verified Account",
                trailing: const Icon(
                  Icons.check_circle_rounded,
                  color: kSuccessGreen,
                  size: 20,
                ),
                onTap: () {},
                kPrimarySlate: kPrimarySlate,
                kSecondarySlate: kSecondarySlate,
                kAccentSlate: kAccentSlate,
              ),
            ],

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            _buildSectionHeader("PREFERENCES & NOTIFICATIONS", kSecondarySlate),
            _buildListTile(
              icon: Icons.notifications_active_outlined,
              title: "Notification Settings",
              subtitle: "Manage push and local alerts",
              onTap: () =>
                  Navigator.pushNamed(context, RouteNames.notificationSettings),
              showArrow: true,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
            ),
            _buildListTile(
              icon: Icons.history_rounded,
              title: "Recent Alerts",
              subtitle: "Review your financial dashboard history",
              onTap: () => Navigator.pushNamed(context, RouteNames.alerts),
              showArrow: true,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
            ),

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            // 3. Security Section
            _buildSectionHeader("SECURITY", kSecondarySlate),
            _buildSwitchTile(
              icon: Icons.fingerprint_rounded,
              title: "App Lock",
              subtitle: "Protect your data with Biometrics/PIN",
              value: settingsProvider.isAppLockEnabled,
              onChanged: (val) => settingsProvider.setAppLock(val),
              kPrimarySlate: kPrimarySlate,
              kAccentSlate: kAccentSlate,
              kSecondarySlate: kSecondarySlate,
              kPrimaryPurple: kPrimaryPurple,
            ),
            if (!isGuest)
              _buildListTile(
                icon: Icons.lock_outline_rounded,
                title: "Change Password",
                subtitle: "Update your login credentials",
                onTap: () => _showChangePasswordDialog(context, authProvider),
                showArrow: true,
                kPrimarySlate: kPrimarySlate,
                kSecondarySlate: kSecondarySlate,
                kAccentSlate: kAccentSlate,
              ),

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            // 4. Data & Account Status (Read-only)
            _buildSectionHeader("DATA & STATUS", kSecondarySlate),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderSlate),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Storage Type",
                          style: TextStyle(
                            color: kSecondarySlate,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          storageType,
                          style: TextStyle(
                            color: storageColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (!isGuest) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Last Sync",
                            style: TextStyle(
                              color: kSecondarySlate,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            lastSyncStr,
                            style: TextStyle(
                              color: kPrimarySlate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildListTile(
              icon: Icons.file_download_outlined,
              title: "Export Data",
              subtitle: isGuest
                  ? "Create account to export"
                  : "Backup your transactions (CSV)",
              onTap: () {
                if (isGuest) {
                  _navigateToCreateAccount(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExportDataScreen(),
                    ),
                  );
                }
              },
              showArrow: !isGuest,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
            ),

            Divider(height: 32, thickness: 8, color: kAccentSlate),

            // 5. Help & Legal
            _buildSectionHeader("HELP & LEGAL", kSecondarySlate),
            _buildListTile(
              icon: Icons.help_outline_rounded,
              title: "Help & FAQ",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpFaqScreen()),
              ),
              showArrow: true,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
            ),
            _buildListTile(
              icon: Icons.support_agent_outlined,
              title: "Contact Support",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactSupportScreen(),
                ),
              ),
              showArrow: true,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
            ),
            _buildListTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              ),
              showArrow: true,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
            ),
            _buildListTile(
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsConditionsScreen(),
                ),
              ),
              showArrow: true,
              kPrimarySlate: kPrimarySlate,
              kSecondarySlate: kSecondarySlate,
              kAccentSlate: kAccentSlate,
            ),

            const SizedBox(height: 48),

            // 6. Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, authProvider),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kErrorRed, width: 2),
                    foregroundColor: kErrorRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color kPrimarySlate,
    required Color kAccentSlate,
    required Color kSecondarySlate,
    required Color kPrimaryPurple,
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
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: kPrimaryPurple,
      ),
    );
  }

  void _navigateToCreateAccount(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  void _showChangePasswordDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final passwordController = TextEditingController();
    bool isLoading = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);
    const kPrimaryPurple = Color(0xFF6366F1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: kCardBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
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
                    color: kPrimaryPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    size: 40,
                    color: kPrimaryPurple,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Change Password",
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
                  'Enter your new password below. Make sure it is secure.',
                  style: TextStyle(
                    fontSize: 15,
                    color: kSecondarySlate,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: kPrimarySlate),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: kSecondarySlate,
                    ),
                    filled: true,
                    fillColor: kAccentSlate,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final password = passwordController.text.trim();
                            if (password.length < 6) return;
                            setState(() => isLoading = true);
                            try {
                              await authProvider.changePassword(password);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              setState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimarySlate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Update Password",
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final isGuest = authProvider.user?.isGuest ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    const kErrorRed = Color(0xFFEF4444);

    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
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
            const Icon(Icons.logout_rounded, size: 48, color: kErrorRed),
            const SizedBox(height: 24),
            Text(
              "Logout",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimarySlate,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isGuest
                  ? 'WARNING: All guest data will be deleted!'
                  : 'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(color: kSecondarySlate),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: kSecondarySlate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (shouldLogout == true && context.mounted) {
      if (isGuest) {
        await Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).clearGuestData();
      }
      await authProvider.signOut();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    }
  }
}
