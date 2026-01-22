import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';
import 'features/budget/presentation/providers/budget_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/goals/data/repositories/goal_repository_impl.dart';
import 'features/goals/presentation/providers/goal_provider.dart';

// Import routing
import 'routes/app_routes.dart';
import 'routes/route_observer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Create route observer instance
    final routeObserver = AppRouteObserver();

    return MultiProvider(
      providers: [
        Provider<AuthRepositoryImpl>(create: (_) => AuthRepositoryImpl()),
        ChangeNotifierProxyProvider<AuthRepositoryImpl, AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<AuthRepositoryImpl>(context, listen: false),
          ),
          update: (context, repo, previous) => AuthProvider(repo),
        ),
        Provider<TransactionRepositoryImpl>(
          create: (_) => TransactionRepositoryImpl(),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          SettingsProvider,
          TransactionProvider
        >(
          create: (context) => TransactionProvider(
            Provider.of<TransactionRepositoryImpl>(context, listen: false),
          ),
          update: (context, auth, settings, previous) =>
              (previous ??
                    TransactionProvider(
                      Provider.of<TransactionRepositoryImpl>(
                        context,
                        listen: false,
                      ),
                    ))
                ..updateUser(auth.user)
                ..updateStartOfMonth(settings.startOfMonth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BudgetProvider>(
          create: (context) => BudgetProvider(),
          update: (context, auth, previous) =>
              (previous ?? BudgetProvider())..updateUser(auth.user),
        ),
        Provider<GoalRepositoryImpl>(create: (_) => GoalRepositoryImpl()),
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (context) => GoalProvider(
            Provider.of<GoalRepositoryImpl>(context, listen: false),
          ),
          update: (context, auth, previous) =>
              (previous ??
                    GoalProvider(
                      Provider.of<GoalRepositoryImpl>(context, listen: false),
                    ))
                ..updateUser(auth.user),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Budgets App',
            debugShowCheckedModeBanner: false,
            // Explicitly set locale to Indian English to force standard digits (0-9)
            // and Indian number formatting (e.g. 1,00,000) globally.
            locale: const Locale('en', 'IN'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'IN'), // English (India)
              Locale('en', 'US'), // English (US) fallback
            ],
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            themeMode: settings.themeMode,
            home: const AuthenticationWrapper(),

            // Use route generator instead of static routes
            onGenerateRoute: AppRoutes.generateRoute,

            // Add route observer for navigation tracking
            navigatorObservers: [routeObserver],
          );
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

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
