import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _budgetAlerts = true;
  bool _overspendingWarnings = true;
  bool _monthlySummary = true;
  bool _dailyReminders = false;

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
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: kAppBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            left: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.15)
                  : const Color(0xFFEFF6FF),
              size: 400,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF581C87).withValues(alpha: 0.15)
                  : const Color(0xFFF5F3FF),
              size: 350,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isGuest) _buildGuestNotice(isDark),

                  const SizedBox(height: 8),
                  _buildSectionHeader("FINANCIAL ALERTS", kSecondarySlate),
                  _buildToggleCard(
                    title: "Budget Status",
                    subtitle: "Receive updates when approaching limits",
                    value: _budgetAlerts,
                    onChanged: (val) => setState(() => _budgetAlerts = val),
                    icon: Icons.account_balance_wallet_rounded,
                    isDark: isDark,
                    kPrimary: kPrimarySlate,
                    kSecondary: kSecondarySlate,
                    kBorder: kBorderSlate,
                  ),
                  _buildToggleCard(
                    title: "Overspending",
                    subtitle: "Immediate warning for exceeded categories",
                    value: _overspendingWarnings,
                    onChanged: (val) =>
                        setState(() => _overspendingWarnings = val),
                    icon: Icons.warning_amber_rounded,
                    isDark: isDark,
                    kPrimary: kPrimarySlate,
                    kSecondary: kSecondarySlate,
                    kBorder: kBorderSlate,
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader("REPORTS & REMINDERS", kSecondarySlate),
                  _buildToggleCard(
                    title: "Monthly Digest",
                    subtitle: "Full analysis of last month's finances",
                    value: _monthlySummary,
                    onChanged: (val) => setState(() => _monthlySummary = val),
                    icon: Icons.insert_chart_outlined_rounded,
                    isDark: isDark,
                    kPrimary: kPrimarySlate,
                    kSecondary: kSecondarySlate,
                    kBorder: kBorderSlate,
                  ),
                  _buildToggleCard(
                    title: "Evening Reminders",
                    subtitle: "Prompt to log today's transactions",
                    value: _dailyReminders,
                    onChanged: (val) => setState(() => _dailyReminders = val),
                    icon: Icons.notifications_active_rounded,
                    isDark: isDark,
                    kPrimary: kPrimarySlate,
                    kSecondary: kSecondarySlate,
                    kBorder: kBorderSlate,
                  ),

                  const SizedBox(height: 48),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: kBorderSlate.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.privacy_tip_rounded,
                                size: 16,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Delivery Method",
                              style: TextStyle(
                                color: kPrimarySlate,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isGuest
                              ? "As a Guest, notifications are managed locally. Some system-level restrictions may apply to local background tasks."
                              : "Your notification preferences are synced across devices. We use high-priority push channels for critical alerts.",
                          style: TextStyle(
                            color: kSecondarySlate,
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestNotice(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFF6366F1),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Sync is disabled in Guest Mode. Notifications will be cleared if you log out.",
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFA5B4FC)
                    : const Color(0xFF4338CA),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color kSecondary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: kSecondary.withValues(alpha: 0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required bool isDark,
    required Color kPrimary,
    required Color kSecondary,
    required Color kBorder,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: kPrimary.withValues(alpha: 0.8),
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
                          color: kPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: kSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: const Color(0xFF6366F1),
                  activeTrackColor: const Color(
                    0xFF6366F1,
                  ).withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
