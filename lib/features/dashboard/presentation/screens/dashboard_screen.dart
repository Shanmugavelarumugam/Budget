import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/presentation/screens/transactions_list_screen.dart';
import '../../../transactions/presentation/screens/add_transaction_screen.dart';
import '../../../budget/presentation/screens/budget_overview_screen.dart';
import '../../../settings/presentation/screens/profile_screen.dart';
import '../../../../routes/route_names.dart';
import '../widgets/home_tab.dart';
import '../widgets/blurred_blob.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  List<Widget> get _screens => [
    HomeTab(
      onSetBudgetTap: () => setState(() => _currentIndex = 2),
      onSeeAllTransactions: () => setState(() => _currentIndex = 1),
      onDrawerMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
    ), // Home
    const TransactionsListScreen(), // Transactions
    const BudgetOverviewScreen(), // Budget
    const ProfileScreen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kNavBarBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kAppBackground,
      endDrawer: _buildDrawer(context),
      body: Stack(
        children: [
          // Background Blobs (Adjusted for Dark Mode)
          Positioned(
            top: -100,
            left: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                  : const Color(0xFFEFF6FF),
              size: 400,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF581C87).withValues(alpha: 0.3)
                  : const Color(0xFFF5F3FF),
              size: 350,
            ),
          ),

          _screens[_currentIndex],
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildFloatingNavBar(
              kNavBarBackground,
              kPrimarySlate,
              kSecondarySlate,
            ),
          ),
        ],
      ),
    );
  }

  void _onAddTransactionTap() {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final isGuest = authProvider.user?.isGuest ?? false;
    // Check if limit reached (>= 3)
    if (isGuest && transactionProvider.transactions.length >= 3) {
      _showGuestLimitModal();
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
    }
  }

  void _showGuestLimitModal() {
    // Re-declare colors locally or use Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);
    const kBorderSlate = Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorderSlate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kAccentSlate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_person_rounded,
                size: 40,
                color: kPrimarySlate,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Access Limit Reached",
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
              "You’ve added 3 transactions as a guest. Create a free account to continue tracking expenses and sync your data.",
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
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.welcome,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimarySlate,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Create Free Account",
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
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(RouteNames.welcome, (route) => false);
              },
              style: TextButton.styleFrom(foregroundColor: kPrimarySlate),
              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
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

  Future<void> _showLogoutConfirmation() async {
    final authProvider = context.read<AuthProvider>();
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kErrorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 40,
                color: kErrorRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Logout",
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
              isGuest
                  ? 'WARNING: All guest data will be deleted if you logout. This action cannot be undone.'
                  : 'Are you sure you want to logout? You will need to sign in again to access your data.',
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
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorRed,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Log Out",
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
              onPressed: () => Navigator.pop(context, false),
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

    if (shouldLogout == true && mounted) {
      if (isGuest) {
        try {
          await context.read<TransactionProvider>().clearGuestData();
        } catch (e) {
          // Ignore errors during guest data cleanup on logout
        }
      }
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isGuest = user?.isGuest ?? false;

    // Clean Dark Theme Palette
    final kSidebarBackground = isDark ? const Color(0xFF111827) : Colors.white;
    final kPrimaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondaryText = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    const kAccentColor = Color(0xFF6366F1);

    return Drawer(
      backgroundColor: kSidebarBackground,
      width: MediaQuery.of(context).size.width * 0.85,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Header Section
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, RouteNames.profile);
                      },
                      child: Hero(
                        tag: 'drawer_avatar',
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kAccentColor,
                                kAccentColor.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kAccentColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              (user?.displayName?.substring(0, 1) ?? "G")
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: kPrimaryText,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  user?.displayName ??
                      (isGuest ? "Guest User" : "Valued Member"),
                  style: TextStyle(
                    color: kPrimaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: kAccentColor.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isGuest ? "LIMITED GUEST MODE" : "PREMIUM ACCOUNT",
                      style: const TextStyle(
                        color: kAccentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Menu Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                _buildPremiumItem(
                  context,
                  icon: Icons.grid_view_rounded,
                  label: "Dashboard",
                  onTap: () => Navigator.pop(context),
                  isActive: true,
                  isDark: isDark,
                  kAccent: kAccentColor,
                ),
                _buildPremiumItem(
                  context,
                  icon: Icons.notifications_active_rounded,
                  label: "Alerts & History",
                  onTap: () => Navigator.pushNamed(context, RouteNames.alerts),
                  isDark: isDark,
                  kAccent: kAccentColor,
                ),
                _buildPremiumItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: "Settings",
                  onTap: () =>
                      Navigator.pushNamed(context, RouteNames.settings),
                  isDark: isDark,
                  kAccent: kAccentColor,
                ),
                _buildPremiumItem(
                  context,
                  icon: Icons.category_rounded,
                  label: "Categories",
                  onTap: () =>
                      Navigator.pushNamed(context, RouteNames.categories),
                  isDark: isDark,
                  kAccent: kAccentColor,
                ),
                _buildPremiumItem(
                  context,
                  icon: Icons.savings_rounded,
                  label: "Savings Goals",
                  onTap: () => Navigator.pushNamed(context, RouteNames.goals),
                  isDark: isDark,
                  kAccent: kAccentColor,
                ),
                _buildPremiumItem(
                  context,
                  icon: Icons.auto_graph_rounded,
                  label: "Income & Reports",
                  onTap: () => Navigator.pushNamed(context, RouteNames.reports),
                  isDark: isDark,
                  kAccent: kAccentColor,
                ),
                _buildPremiumItem(
                  context,
                  icon: Icons.family_restroom_rounded,
                  label: "Family / Shared",
                  onTap: () =>
                      Navigator.pushNamed(context, RouteNames.familyHome),
                  isDark: isDark,
                  kAccent: kAccentColor,
                ),
              ],
            ),
          ),

          // 3. Upgrade Banner
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, RouteNames.premiumFeatures);
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kAccentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: kAccentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Go Pro",
                            style: TextStyle(
                              color: kPrimaryText,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Unlock all tools",
                            style: TextStyle(
                              color: kSecondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: kSecondaryText.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Logout Footer
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "v1.0.1",
                      style: TextStyle(
                        color: kSecondaryText.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    required bool isDark,
    required Color kAccent,
  }) {
    final kPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : kAccent.withValues(alpha: 0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive && isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: isActive ? kAccent : kSecondary),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                  color: isActive ? kPrimary : kSecondary,
                  letterSpacing: -0.3,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kAccent.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(
    Color bg,
    Color activeColor,
    Color inactiveColor,
  ) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            0,
            Icons.dashboard_rounded,
            'Home',
            activeColor,
            inactiveColor,
          ),
          _buildNavItem(
            1,
            Icons.receipt_long_rounded,
            'Transactions',
            activeColor,
            inactiveColor,
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: GestureDetector(
              onTap: _onAddTransactionTap, // Updated handler
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A), // Slate 900
                      Color(0xFF334155), // Slate 700
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          _buildNavItem(
            2,
            Icons.account_balance_wallet_rounded,
            'Budget',
            activeColor,
            inactiveColor,
          ),
          _buildNavItem(
            3,
            Icons.person_rounded,
            'Profile',
            activeColor,
            inactiveColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color active,
    Color inactive,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? active : inactive, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? active : inactive,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
