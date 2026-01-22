# Core Security Services

## Overview
This folder contains app-wide security services that are used across multiple features.

## Services

### BiometricService (`biometric_service.dart`)
Handles fingerprint/face ID authentication using `local_auth` package.

**Usage:**
```dart
final biometric = BiometricService();
final isAvailable = await biometric.isBiometricAvailable();
if (isAvailable) {
  final authenticated = await biometric.authenticate(
    reason: 'Unlock app',
  );
}
```

### AppLockService (`app_lock_service.dart`)
Manages app lock state, PIN codes, and biometric settings.

**Usage:**
```dart
final appLock = AppLockService(prefs);
await appLock.setAppLockEnabled(true);
await appLock.setPinCode('1234');
```

## Why in core/security?

These services are:
- ✅ **App-wide** - Used by multiple features (settings, auth, etc.)
- ✅ **Infrastructure** - Not feature-specific business logic
- ✅ **Reusable** - Can be injected anywhere via Provider

## Integration with Settings

The UI for configuring these services lives in:
```
features/settings/presentation/screens/app_lock_settings_screen.dart
```

But the actual security logic lives here in `core/security/`.

## Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  local_auth: ^latest
  flutter_secure_storage: ^latest  # For secure PIN storage
```

## Future Enhancements

- [ ] Use `flutter_secure_storage` for PIN encryption
- [ ] Add session timeout tracking
- [ ] Add failed attempt counter
- [ ] Add emergency unlock mechanism
