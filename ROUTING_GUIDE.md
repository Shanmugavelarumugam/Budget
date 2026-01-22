# Routing Guide

## Overview
This app uses **named routes** with `MaterialApp`. Route guards are implemented using **redirect logic** in the authentication wrapper, not separate guard classes.

## Current Implementation

### Route Definitions (`app.dart`)
```dart
routes: {
  '/welcome': (context) => const WelcomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/dashboard': (context) => const DashboardScreen(),
}
```

### Authentication Wrapper
The `AuthenticationWrapper` handles routing based on auth status:

```dart
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.unknown:
            return const SplashScreen();
          case AuthStatus.unauthenticated:
            return const OnboardingScreen();
          case AuthStatus.authenticated:
          case AuthStatus.guest:
            return const DashboardScreen();
        }
      },
    );
  }
}
```

## Implementing Route Protection

### Option 1: Check in Screen (Current Approach)
```dart
class PremiumFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.user?.isGuest == true) {
      // Show upgrade prompt
      return UpgradePromptScreen();
    }
    
    return ActualPremiumContent();
  }
}
```

### Option 2: Recommended - Use GoRouter (Future Enhancement)
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/premium',
      builder: (context, state) => PremiumScreen(),
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        if (auth.user?.isGuest == true) {
          return '/upgrade';
        }
        return null; // Allow access
      },
    ),
  ],
);
```

## Route Protection Patterns

### Guest User Restrictions
```dart
// In any screen that requires authentication
final auth = context.read<AuthProvider>();
if (auth.user?.isGuest == true) {
  Navigator.pushReplacementNamed(context, '/welcome');
  return;
}
```

### Premium Feature Access
```dart
// Check premium status before showing feature
final user = context.read<AuthProvider>().user;
if (user?.isPremium != true) {
  showDialog(
    context: context,
    builder: (_) => UpgradeDialog(),
  );
  return;
}
```

## Why No Guard Classes?

1. **Flutter's Navigation Model**: Unlike web frameworks (Angular, React Router), Flutter doesn't have middleware-style guards
2. **Provider Pattern**: We use `Consumer` and `context.watch` for reactive auth state
3. **Simpler Debugging**: Logic is visible in routes or screens, not hidden in separate classes
4. **Less Boilerplate**: No need for empty guard classes

## Migration Path (If Needed)

If you want more structured routing in the future:

1. **Install GoRouter**:
   ```yaml
   dependencies:
     go_router: ^latest
   ```

2. **Define Routes with Redirects**:
   ```dart
   final router = GoRouter(
     redirect: (context, state) {
       final auth = context.read<AuthProvider>();
       
       // Global auth check
       if (!auth.isAuthenticated && state.path != '/login') {
         return '/login';
       }
       
       // Guest restrictions
       if (auth.user?.isGuest == true) {
         final restrictedPaths = ['/premium', '/export', '/sync'];
         if (restrictedPaths.contains(state.path)) {
           return '/upgrade';
         }
       }
       
       return null; // Allow navigation
     },
     routes: [...],
   );
   ```

3. **Replace MaterialApp**:
   ```dart
   return MaterialApp.router(
     routerConfig: router,
     // ... other config
   );
   ```

## Best Practices

1. ✅ **Use AuthenticationWrapper** for initial routing
2. ✅ **Check auth state in screens** for feature-specific restrictions
3. ✅ **Show upgrade prompts** instead of blocking navigation
4. ✅ **Use named routes** for consistency
5. ❌ **Don't create empty guard classes** - they add no value in Flutter
