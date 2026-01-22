import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

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
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const kSuccessGreen = Color(0xFF22C55E);
    const kSyncingBlue = Color(0xFF3B82F6);
    const kErrorRed = Color(0xFFEF4444);

    final lastSyncTime = DateTime.now().subtract(const Duration(minutes: 8));
    final lastSyncStr = DateFormat('MMM d, h:mm a').format(lastSyncTime);

    // Mock states for demonstration
    final isSyncing = false;
    final hasError = false;

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Sync Status',
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
          children: [
            // 1. Current State Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  _buildStatusIcon(
                    isGuest: isGuest,
                    isSyncing: isSyncing,
                    hasError: hasError,
                    kSuccessGreen: kSuccessGreen,
                    kSyncingBlue: kSyncingBlue,
                    kErrorRed: kErrorRed,
                    kSecondarySlate: kSecondarySlate,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getStatusText(isGuest, isSyncing, hasError),
                    style: TextStyle(
                      color: kPrimarySlate,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusSubtitle(isGuest, isSyncing, hasError),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kSecondarySlate, fontSize: 14),
                  ),
                ],
              ),
            ),

            // 2. Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (!isGuest)
                    _buildSyncedItem(
                      label: "Last Synced",
                      value: lastSyncStr,
                      icon: Icons.access_time_rounded,
                      kPrimarySlate: kPrimarySlate,
                      kSecondarySlate: kSecondarySlate,
                      kAccentSlate: kAccentSlate,
                      kBorderSlate: kBorderSlate,
                    ),
                  const SizedBox(height: 12),
                  _buildSyncedItem(
                    label: "Connection",
                    value: "Secure (SSL Encrypted)",
                    icon: Icons.security_rounded,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                    kAccentSlate: kAccentSlate,
                    kBorderSlate: kBorderSlate,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. What is Synced section
            _buildSectionHeader("WHAT IS SYNCED", kSecondarySlate),
            _buildWhatIsSyncedGrid(
              kPrimarySlate,
              kSecondarySlate,
              kAccentSlate,
            ),

            const SizedBox(height: 48),

            // 4. Guest conversion or Offline info
            if (isGuest)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Enable Cloud Sync",
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Create an account to securely back up your data and access it from any device.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kSecondarySlate,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/welcome',
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Join Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: kSecondarySlate.withValues(alpha: 0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Changes made offline will auto-sync when you're back online.",
                        style: TextStyle(
                          color: kSecondarySlate.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon({
    required bool isGuest,
    required bool isSyncing,
    required bool hasError,
    required Color kSuccessGreen,
    required Color kSyncingBlue,
    required Color kErrorRed,
    required Color kSecondarySlate,
  }) {
    IconData icon;
    Color color;

    if (isGuest) {
      icon = Icons.cloud_off_rounded;
      color = kSecondarySlate;
    } else if (hasError) {
      icon = Icons.sync_problem_rounded;
      color = kErrorRed;
    } else if (isSyncing) {
      icon = Icons.sync_rounded;
      color = kSyncingBlue;
    } else {
      icon = Icons.cloud_done_rounded;
      color = kSuccessGreen;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 50, color: color),
    );
  }

  String _getStatusText(bool isGuest, bool isSyncing, bool hasError) {
    if (isGuest) return "Sync Unavailable";
    if (hasError) return "Sync Failed";
    if (isSyncing) return "Syncing...";
    return "Data Synced";
  }

  String _getStatusSubtitle(bool isGuest, bool isSyncing, bool hasError) {
    if (isGuest) return "Guest mode does not support cloud backups";
    if (hasError) {
      return "We couldn't reach the server. Please check your internet.";
    }
    if (isSyncing) return "Sending your latest changes to the cloud";
    return "Your financial data is safely backed up";
  }

  Widget _buildSyncedItem({
    required String label,
    required String value,
    required IconData icon,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    required Color kAccentSlate,
    required Color kBorderSlate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAccentSlate.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSlate.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kSecondarySlate),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: kSecondarySlate, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: kPrimarySlate,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color kSecondarySlate) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kSecondarySlate,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: kSecondarySlate.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsSyncedGrid(
    Color kPrimary,
    Color kSecondary,
    Color kAccent,
  ) {
    final items = [
      {'label': 'Transactions', 'icon': Icons.swap_horiz_rounded},
      {'label': 'Budgets', 'icon': Icons.account_balance_wallet_rounded},
      {'label': 'Categories', 'icon': Icons.category_rounded},
      {'label': 'Goals', 'icon': Icons.flag_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  items[index]['icon'] as IconData,
                  size: 18,
                  color: kPrimary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  items[index]['label'] as String,
                  style: TextStyle(
                    color: kPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
