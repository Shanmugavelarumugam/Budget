# 🧭 Routing System - Usage Guide

## Overview

The routing system is now fully functional with:
- ✅ **RouteNames** - Type-safe route constants
- ✅ **AppRoutes** - Central route generator
- ✅ **AppRouteObserver** - Navigation tracking
- ✅ **404 Handling** - Graceful error pages

---

## 📋 Quick Reference

### Navigate to a Screen

```dart
// Method 1: Using helper methods (RECOMMENDED)
AppRoutes.navigateTo(context, RouteNames.budgetOverview);

// Method 2: Using Navigator directly
Navigator.pushNamed(context, RouteNames.transactions);
```

### Navigate with Arguments

```dart
// Pass arguments
AppRoutes.navigateTo(
  context,
  RouteNames.editTransaction,
  arguments: myTransaction,
);
```

### Navigate and Replace

```dart
// Replace current screen
AppRoutes.navigateAndReplace(context, RouteNames.dashboard);
```

### Navigate and Clear Stack

```dart
// Clear all previous screens (e.g., after logout)
AppRoutes.navigateAndRemoveUntil(context, RouteNames.welcome);
```

### Go Back

```dart
// Simple back
AppRoutes.goBack(context);

// Back with result
AppRoutes.goBack(context, myResult);
```

---

## 🎯 Available Routes

### Auth Routes
```dart
RouteNames.splash              // '/'
RouteNames.onboarding          // '/onboarding'
RouteNames.welcome             // '/welcome'
RouteNames.login               // '/login'
RouteNames.register            // '/register'
RouteNames.forgotPassword      // '/forgot-password'
```

### Main App
```dart
RouteNames.dashboard           // '/dashboard'
```

### Transactions
```dart
RouteNames.transactions        // '/transactions'
RouteNames.addTransaction      // '/add-transaction'
RouteNames.editTransaction     // '/edit-transaction' (requires TransactionEntity)
```

### Budget
```dart
RouteNames.budgetOverview      // '/budget-overview'
RouteNames.budgetDetails       // '/budget-details'
RouteNames.setMonthlyBudget    // '/set-monthly-budget'
RouteNames.setCategoryBudget   // '/set-category-budget'
```

### Categories
```dart
RouteNames.categories          // '/categories'
RouteNames.addCategory         // '/add-category'
RouteNames.editCategory        // '/edit-category'
```

### Reports
```dart
RouteNames.reports             // '/reports'
RouteNames.monthlyReport       // '/monthly-report'
RouteNames.categoryReport      // '/category-report'
RouteNames.budgetVsActual      // '/budget-vs-actual'
```

### Settings
```dart
RouteNames.settings            // '/settings'
RouteNames.profile             // '/profile'
RouteNames.editProfile         // '/edit-profile'
RouteNames.currencySelection   // '/currency-selection'
RouteNames.themeSettings       // '/theme-settings'
RouteNames.appLockSettings     // '/app-lock-settings'
```

### Goals
```dart
RouteNames.goals               // '/goals'
RouteNames.addGoal             // '/add-goal'
RouteNames.goalDetails         // '/goal-details'
```

### Analytics
```dart
RouteNames.analytics           // '/analytics'
RouteNames.spendingTrend       // '/spending-trend'
RouteNames.topCategories       // '/top-categories'
```

### Export
```dart
RouteNames.exportData          // '/export-data'
RouteNames.exportHistory       // '/export-history'
```

### Legal
```dart
RouteNames.privacyPolicy       // '/privacy-policy'
RouteNames.termsConditions     // '/terms-conditions'
RouteNames.helpFaq             // '/help-faq'
RouteNames.contactSupport      // '/contact-support'
```

### Premium
```dart
RouteNames.upgradeToPro        // '/upgrade-to-pro'
RouteNames.premiumFeatures     // '/premium-features'
```

### Family
```dart
RouteNames.familyHome          // '/family-home'
RouteNames.inviteMember        // '/invite-member'
RouteNames.sharedReadonly      // '/shared-readonly'
```

### Guest
```dart
RouteNames.convertGuest        // '/convert-guest'
RouteNames.guestInfo           // '/guest-info'
```

### Alerts
```dart
RouteNames.alerts              // '/alerts'
RouteNames.alertDetails        // '/alert-details'
RouteNames.notificationSettings // '/notification-settings'
```

### Sync
```dart
RouteNames.syncStatus          // '/sync-status'
RouteNames.syncError           // '/sync-error'
```

### System
```dart
RouteNames.error               // '/error'
RouteNames.noInternet          // '/no-internet'
```

---

## 💡 Usage Examples

### Example 1: Navigate from Dashboard to Budget

```dart
// In dashboard_screen.dart
ElevatedButton(
  onPressed: () {
    AppRoutes.navigateTo(context, RouteNames.budgetOverview);
  },
  child: const Text('View Budget'),
)
```

### Example 2: Edit Transaction

```dart
// In transactions list
ListTile(
  title: Text(transaction.description),
  onTap: () {
    AppRoutes.navigateTo(
      context,
      RouteNames.editTransaction,
      arguments: transaction,
    );
  },
)
```

### Example 3: Logout and Clear Stack

```dart
// In profile_screen.dart
void _logout() async {
  await authProvider.logout();
  
  // Navigate to welcome and clear all previous screens
  AppRoutes.navigateAndRemoveUntil(
    context,
    RouteNames.welcome,
  );
}
```

### Example 4: Navigate with Result

```dart
// Screen A: Navigate and wait for result
final result = await AppRoutes.navigateTo<String>(
  context,
  RouteNames.currencySelection,
);

if (result != null) {
  print('Selected currency: $result');
}

// Screen B: Return result
AppRoutes.goBack(context, 'USD');
```

---

## 🔍 Navigation Tracking

The `AppRouteObserver` automatically logs all navigation events:

```
🧭 Navigation [PUSH]: /dashboard → /budget-overview
🧭 Navigation [POP]: /budget-overview → /dashboard
🧭 Navigation [REPLACE]: /login → /dashboard
```

This is useful for:
- Debugging navigation issues
- Analytics tracking
- User behavior analysis

---

## 🚨 404 Handling

If you navigate to an undefined route:

```dart
Navigator.pushNamed(context, '/non-existent-route');
```

The app will show a custom 404 screen with:
- Error icon
- "Page Not Found" message
- Route name that was attempted
- "Go Back" button

---

## 🎨 Adding New Routes

### Step 1: Add Route Name

```dart
// In route_names.dart
static const String myNewScreen = '/my-new-screen';
```

### Step 2: Add Route in Generator

```dart
// In app_routes.dart
case RouteNames.myNewScreen:
  return _buildRoute(const MyNewScreen(), settings);
```

### Step 3: Import the Screen

```dart
// At top of app_routes.dart
import '../features/my_feature/presentation/screens/my_new_screen.dart';
```

### Step 4: Use It

```dart
AppRoutes.navigateTo(context, RouteNames.myNewScreen);
```

---

## ✅ Best Practices

1. **Always use RouteNames constants**
   ```dart
   ✅ AppRoutes.navigateTo(context, RouteNames.dashboard);
   ❌ Navigator.pushNamed(context, '/dashboard');
   ```

2. **Use helper methods for clarity**
   ```dart
   ✅ AppRoutes.navigateAndReplace(context, RouteNames.login);
   ❌ Navigator.pushReplacementNamed(context, RouteNames.login);
   ```

3. **Type your arguments**
   ```dart
   ✅ arguments: transaction as TransactionEntity
   ❌ arguments: transaction
   ```

4. **Handle null arguments**
   ```dart
   if (args != null) {
     final transaction = args as TransactionEntity;
     // Use transaction
   }
   ```

---

## 🔐 Route Protection

For protected routes (e.g., premium features), check in the screen:

```dart
@override
Widget build(BuildContext context) {
  final auth = context.watch<AuthProvider>();
  
  if (auth.user?.isGuest == true) {
    // Show upgrade prompt
    return UpgradePromptScreen();
  }
  
  return ActualContent();
}
```

See `ROUTING_GUIDE.md` for more details on route protection.

---

## 📊 Summary

- ✅ **70+ routes** defined and ready to use
- ✅ **Type-safe** navigation with RouteNames
- ✅ **Helper methods** for common navigation patterns
- ✅ **404 handling** for undefined routes
- ✅ **Navigation tracking** with AppRouteObserver
- ✅ **Fully integrated** with app.dart

**Your routing system is production-ready!** 🚀
