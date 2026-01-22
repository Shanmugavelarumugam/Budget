import 'package:flutter/material.dart';
import 'route_names.dart';

// Auth screens
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';

// Dashboard
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

// Transactions
import '../features/transactions/domain/entities/transaction_entity.dart';
import '../features/transactions/presentation/screens/transactions_list_screen.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';

// Budget
import '../features/budget/presentation/screens/budget_overview_screen.dart';
import '../features/budget/presentation/screens/budget_details_screen.dart';
import '../features/budget/presentation/screens/set_monthly_budget_screen.dart';
import '../features/budget/presentation/screens/set_category_budget_screen.dart';

// Categories
import '../features/categories/presentation/screens/category_list_screen.dart';
import '../features/categories/presentation/screens/add_category_screen.dart';
import '../features/categories/presentation/screens/edit_category_screen.dart';

// Reports
import '../features/reports/presentation/screens/reports_home_screen.dart';
import '../features/reports/presentation/screens/monthly_report_screen.dart';
import '../features/reports/presentation/screens/category_wise_report_screen.dart';
import '../features/reports/presentation/screens/budget_vs_actual_screen.dart';

// Settings
import '../features/settings/presentation/screens/settings_home_screen.dart';
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/edit_profile_screen.dart';
import '../features/settings/presentation/screens/currency_selection_screen.dart';
import '../features/settings/presentation/screens/theme_settings_screen.dart';
import '../features/settings/presentation/screens/app_lock_settings_screen.dart';
import '../features/settings/presentation/screens/data_storage_screen.dart';

// Goals
import '../features/goals/domain/entities/goal_entity.dart';
import '../features/goals/presentation/screens/goals_list_screen.dart';
import '../features/goals/presentation/screens/add_goal_screen.dart';
import '../features/goals/presentation/screens/goal_details_screen.dart';

// Analytics
import '../features/analytics/presentation/screens/analytics_overview_screen.dart';
import '../features/analytics/presentation/screens/spending_trend_screen.dart';
import '../features/analytics/presentation/screens/top_categories_screen.dart';

// Export
import '../features/export/presentation/screens/export_data_screen.dart';
import '../features/export/presentation/screens/export_history_screen.dart';

// Legal
import '../features/legal/presentation/screens/privacy_policy_screen.dart';
import '../features/legal/presentation/screens/terms_conditions_screen.dart';
import '../features/legal/presentation/screens/help_faq_screen.dart';
import '../features/legal/presentation/screens/contact_support_screen.dart';

// Premium
import '../features/premium/presentation/screens/upgrade_to_pro_screen.dart';
import '../features/premium/presentation/screens/premium_features_info_screen.dart';

// Family
import '../features/family/presentation/screens/family_home_screen.dart';
import '../features/family/presentation/screens/invite_member_screen.dart';
import '../features/family/presentation/screens/shared_readonly_screen.dart';

// Guest
import '../features/guest/presentation/screens/convert_guest_screen.dart';
import '../features/guest/presentation/screens/guest_info_screen.dart';

// Alerts
import '../features/alerts/domain/entities/alert_model.dart';
import '../features/alerts/presentation/screens/alerts_list_screen.dart';
import '../features/alerts/presentation/screens/alert_details_screen.dart';
import '../features/alerts/presentation/screens/notification_settings_screen.dart';

// Sync
import '../features/sync/presentation/screens/sync_status_screen.dart';
import '../features/sync/presentation/screens/sync_error_screen.dart';

// System
import '../features/system/presentation/screens/error_screen.dart';
import '../features/system/presentation/screens/no_internet_screen.dart';

/// Central route generator for the application
/// Handles all navigation and route generation
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if any
    final args = settings.arguments;

    switch (settings.name) {
      // ==================== AUTH ROUTES ====================
      case RouteNames.splash:
        return _buildRoute(const SplashScreen(), settings);

      case RouteNames.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);

      case RouteNames.welcome:
        return _buildRoute(const WelcomeScreen(), settings);

      case RouteNames.login:
        return _buildRoute(const LoginScreen(), settings);

      case RouteNames.register:
        return _buildRoute(const RegisterScreen(), settings);

      case RouteNames.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      // ==================== MAIN APP ROUTES ====================
      case RouteNames.dashboard:
        return _buildRoute(const DashboardScreen(), settings);

      // ==================== TRANSACTION ROUTES ====================
      case RouteNames.transactions:
        return _buildRoute(const TransactionsListScreen(), settings);

      case RouteNames.addTransaction:
        return _buildRoute(const AddTransactionScreen(), settings);

      case RouteNames.editTransaction:
        // Expect TransactionEntity as argument
        if (args != null) {
          return _buildRoute(
            AddTransactionScreen(transaction: args as TransactionEntity),
            settings,
          );
        }
        // If no argument, redirect to add transaction
        return _buildRoute(const AddTransactionScreen(), settings);

      // ==================== BUDGET ROUTES ====================
      case RouteNames.budgetOverview:
        return _buildRoute(const BudgetOverviewScreen(), settings);

      case RouteNames.budgetDetails:
        return _buildRoute(const BudgetDetailsScreen(), settings);

      case RouteNames.setMonthlyBudget:
        return _buildRoute(const SetMonthlyBudgetScreen(), settings);

      case RouteNames.setCategoryBudget:
        return _buildRoute(const SetCategoryBudgetScreen(), settings);

      // ==================== CATEGORY ROUTES ====================
      case RouteNames.categories:
        return _buildRoute(const CategoryListScreen(), settings);

      case RouteNames.addCategory:
        return _buildRoute(const AddCategoryScreen(), settings);

      case RouteNames.editCategory:
        return _buildRoute(const EditCategoryScreen(), settings);

      // ==================== REPORTS ROUTES ====================
      case RouteNames.reports:
        return _buildRoute(const ReportsHomeScreen(), settings);

      case RouteNames.monthlyReport:
        return _buildRoute(const MonthlyReportScreen(), settings);

      case RouteNames.categoryReport:
        return _buildRoute(const CategoryWiseReportScreen(), settings);

      case RouteNames.budgetVsActual:
        return _buildRoute(const BudgetVsActualScreen(), settings);

      // ==================== SETTINGS ROUTES ====================
      case RouteNames.settings:
        return _buildRoute(const SettingsHomeScreen(), settings);

      case RouteNames.profile:
        return _buildRoute(const ProfileScreen(), settings);

      case RouteNames.editProfile:
        return _buildRoute(const EditProfileScreen(), settings);

      case RouteNames.currencySelection:
        return _buildRoute(const CurrencySelectionScreen(), settings);

      case RouteNames.themeSettings:
        return _buildRoute(const ThemeSettingsScreen(), settings);

      case RouteNames.appLockSettings:
        return _buildRoute(const AppLockSettingsScreen(), settings);

      case RouteNames.dataAndStorage:
        return _buildRoute(const DataStorageScreen(), settings);

      // ==================== GOALS ROUTES ====================
      case RouteNames.goals:
        return _buildRoute(const GoalsListScreen(), settings);

      case RouteNames.addGoal:
        return _buildRoute(const AddGoalScreen(), settings);

      case RouteNames.goalDetails:
        if (args is GoalEntity) {
          return _buildRoute(GoalDetailsScreen(initialGoal: args), settings);
        }
        return _buildRoute(
          const _NotFoundScreen(routeName: 'Invalid Goal Argument'),
          settings,
        );

      // ==================== ANALYTICS ROUTES ====================
      case RouteNames.analytics:
        return _buildRoute(const AnalyticsOverviewScreen(), settings);

      case RouteNames.spendingTrend:
        return _buildRoute(const SpendingTrendScreen(), settings);

      case RouteNames.topCategories:
        return _buildRoute(const TopCategoriesScreen(), settings);

      // ==================== EXPORT ROUTES ====================
      case RouteNames.exportData:
        return _buildRoute(const ExportDataScreen(), settings);

      case RouteNames.exportHistory:
        return _buildRoute(const ExportHistoryScreen(), settings);

      // ==================== LEGAL ROUTES ====================
      case RouteNames.privacyPolicy:
        return _buildRoute(const PrivacyPolicyScreen(), settings);

      case RouteNames.termsConditions:
        return _buildRoute(const TermsConditionsScreen(), settings);

      case RouteNames.helpFaq:
        return _buildRoute(const HelpFaqScreen(), settings);

      case RouteNames.contactSupport:
        return _buildRoute(const ContactSupportScreen(), settings);

      // ==================== PREMIUM ROUTES ====================
      case RouteNames.upgradeToPro:
        return _buildRoute(const UpgradeToProScreen(), settings);

      case RouteNames.premiumFeatures:
        return _buildRoute(const PremiumFeaturesInfoScreen(), settings);

      // ==================== FAMILY ROUTES ====================
      case RouteNames.familyHome:
        return _buildRoute(const FamilyHomeScreen(), settings);

      case RouteNames.inviteMember:
        return _buildRoute(const InviteMemberScreen(), settings);

      case RouteNames.sharedReadonly:
        return _buildRoute(const SharedReadonlyScreen(), settings);

      // ==================== GUEST ROUTES ====================
      case RouteNames.convertGuest:
        return _buildRoute(const ConvertGuestScreen(), settings);

      case RouteNames.guestInfo:
        return _buildRoute(const GuestInfoScreen(), settings);

      // ==================== ALERTS ROUTES ====================
      case RouteNames.alerts:
        return _buildRoute(const AlertsListScreen(), settings);

      case RouteNames.alertDetails:
        if (args != null && args is AlertModel) {
          return _buildRoute(AlertDetailsScreen(alert: args), settings);
        }
        return _buildRoute(const AlertsListScreen(), settings);

      case RouteNames.notificationSettings:
        return _buildRoute(const NotificationSettingsScreen(), settings);

      // ==================== SYNC ROUTES ====================
      case RouteNames.syncStatus:
        return _buildRoute(const SyncStatusScreen(), settings);

      case RouteNames.syncError:
        return _buildRoute(const SyncErrorScreen(), settings);

      // ==================== SYSTEM ROUTES ====================
      case RouteNames.error:
        return _buildRoute(const ErrorScreen(), settings);

      case RouteNames.noInternet:
        return _buildRoute(const NoInternetScreen(), settings);

      // ==================== DEFAULT (404) ====================
      default:
        return _buildRoute(
          _NotFoundScreen(routeName: settings.name ?? 'Unknown'),
          settings,
        );
    }
  }

  /// Build a MaterialPageRoute with the given widget and settings
  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  /// Navigate to a route by name
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to previous screen
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
}

/// 404 Not Found Screen
class _NotFoundScreen extends StatelessWidget {
  final String routeName;

  const _NotFoundScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                '404',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routeName',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
