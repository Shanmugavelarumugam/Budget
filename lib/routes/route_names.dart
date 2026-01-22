/// Route names for the application
/// Use these constants instead of hardcoded strings for type safety
class RouteNames {
  // Private constructor to prevent instantiation
  RouteNames._();

  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String dashboard = '/dashboard';

  // Transaction routes
  static const String transactions = '/transactions';
  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction';

  // Budget routes
  static const String budgetOverview = '/budget-overview';
  static const String budgetDetails = '/budget-details';
  static const String setMonthlyBudget = '/set-monthly-budget';
  static const String setCategoryBudget = '/set-category-budget';

  // Category routes
  static const String categories = '/categories';
  static const String addCategory = '/add-category';
  static const String editCategory = '/edit-category';

  // Reports routes
  static const String reports = '/reports';
  static const String monthlyReport = '/monthly-report';
  static const String categoryReport = '/category-report';
  static const String budgetVsActual = '/budget-vs-actual';

  // Settings routes
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String currencySelection = '/currency-selection';
  static const String themeSettings = '/theme-settings';
  static const String appLockSettings = '/app-lock-settings';
  static const String dataAndStorage = '/data-and-storage';

  // Goals routes
  static const String goals = '/goals';
  static const String addGoal = '/add-goal';
  static const String goalDetails = '/goal-details';

  // Analytics routes
  static const String analytics = '/analytics';
  static const String spendingTrend = '/spending-trend';
  static const String topCategories = '/top-categories';

  // Export routes
  static const String exportData = '/export-data';
  static const String exportHistory = '/export-history';

  // Legal routes
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String helpFaq = '/help-faq';
  static const String contactSupport = '/contact-support';

  // Premium routes
  static const String upgradeToPro = '/upgrade-to-pro';
  static const String premiumFeatures = '/premium-features';

  // Family routes
  static const String familyHome = '/family-home';
  static const String inviteMember = '/invite-member';
  static const String sharedReadonly = '/shared-readonly';

  // Guest routes
  static const String convertGuest = '/convert-guest';
  static const String guestInfo = '/guest-info';

  // Alerts routes
  static const String alerts = '/alerts';
  static const String alertDetails = '/alert-details';
  static const String notificationSettings = '/notification-settings';

  // Sync routes
  static const String syncStatus = '/sync-status';
  static const String syncError = '/sync-error';

  // System routes
  static const String error = '/error';
  static const String noInternet = '/no-internet';
}
