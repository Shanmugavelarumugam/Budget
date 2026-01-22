## Purpose
Provide concise, actionable guidance for AI coding agents working in this Flutter app (Budgets).

## Big-picture architecture
- Flutter multi-platform app (android/ios/macos/linux/windows/web) located under the root `lib/`.
- Feature-first layout: each feature lives under `lib/features/<feature>/...` with subfolders `presentation`, `domain` and `data` where applicable. Example: [lib/features/dashboard/presentation/screens/dashboard_screen.dart](lib/features/dashboard/presentation/screens/dashboard_screen.dart).
- Central app glue lives in: `lib/app.dart`, `lib/bootstrap.dart`, `lib/main.dart` and `lib/routes/route_names.dart` (use `RouteNames` constants for navigation).
- State management: `provider` package. Providers are implemented under `presentation/providers` for each feature (look for `*_provider.dart`).

## Key files and directories to consult
- App entrypoints: [lib/main.dart](lib/main.dart), [lib/bootstrap.dart](lib/bootstrap.dart), [lib/app.dart](lib/app.dart).
- Routes: [lib/routes/route_names.dart](lib/routes/route_names.dart).
- Feature layout: `lib/features/<feature>/presentation/{providers,screens,widgets}` (examples: dashboard, transactions, budget, settings).
- Firebase & backend config: `firebase.json`, `firestore.rules`, and `lib/firebase_options.dart`.
- Native projects: `android/` and `ios/` for platform-specific build steps (iOS uses CocoaPods).
- Documentation: many changelogs and guides at repo root (e.g., `README.md`, `docs/`). Prefer linking to those when suggesting workflow changes.

## Platform, build & test commands (practical)
- Install deps: `flutter pub get`.
- Run locally: `flutter run -d <device>` or `flutter run -d chrome` (web).
- Build APK: `flutter build apk`.
- iOS: `cd ios && pod install` (run on macOS) then `flutter build ios`.
- Tests: `flutter test` (there is a `test/widget_test.dart`).

## Project-specific conventions & patterns
- Use `RouteNames` constants for named routes instead of raw strings (see [lib/routes/route_names.dart](lib/routes/route_names.dart)).
- Providers: typical provider usage is `context.read<MyProvider>()` to call methods and `context.watch<MyProvider>()` to reflect state in UI.
- UI organization: `presentation/screens` contains full-screen widgets, `presentation/widgets` contains small reusable widgets.
- Theme and color helpers: the codebase uses a `withValues` extension on `Color` (search for `.withValues`) — don't replace it with direct color arithmetic without checking the extension implementation.
- Guest mode: guest-account behavior and limits are enforced in UI code (example: add-transaction flow in [lib/features/dashboard/presentation/screens/dashboard_screen.dart](lib/features/dashboard/presentation/screens/dashboard_screen.dart) checks for a 3-transaction guest limit). Preserve this logic when changing auth/transaction flows.

## Integration points & external deps
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging` — changes to auth or Firestore will impact multiple features.
- Local persistence: `hive` and `shared_preferences` used for offline or cached data.
- Network: `dio` and `http` are present for API/network calls.

## Common code patterns and examples
- Navigation example: `Navigator.of(context).pushNamed(RouteNames.profile)` or `pushNamedAndRemoveUntil(RouteNames.welcome, (r)=>false)`.
- Provider read/watch patterns: `final auth = context.watch<AuthProvider>(); final isGuest = auth.user?.isGuest ?? false;`
- Modal bottom sheets: many confirmation dialogs use `showModalBottomSheet(..., backgroundColor: Colors.transparent, builder: ...)` with a decorated `Container` child.

## What to avoid / common pitfalls
- Don't hardcode route strings; use `RouteNames`.
- When modifying auth sign-out flows, ensure guest-data cleanup calls `TransactionProvider.clearGuestData()` and use proper `mounted` checks before navigation (existing code follows this pattern).
- Avoid changing the custom `Color` extension behavior without locating its implementation.

## Where to find more context
- Large number of repo notes and guides at the repo root (e.g., `README.md`, `DOCS/`, `DEPLOY_FIRESTORE_RULES.md`) — consult these before proposing architecture or infra changes.

## If you need to make code changes
- Keep edits minimal and feature-scoped. Update or add unit/widget tests under `test/` for behavior changes.
- When adding new routes, update `RouteNames`, and search for usages via `RouteNames.<yourRoute>`.

---
If you want, I can iterate: add line-level examples referencing the `withValues` extension location, `AuthProvider` implementation, or expand build steps for iOS CI. Which section should I expand?
