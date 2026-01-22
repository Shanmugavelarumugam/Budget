# Dependencies to Add

## Required for Biometric Authentication

Add these to `pubspec.yaml`:

```yaml
dependencies:
  # ... existing dependencies ...
  
  # Biometric authentication
  local_auth: ^2.1.7
  local_auth_android: ^1.0.32
  local_auth_ios: ^1.1.4
  local_auth_windows: ^1.0.10
  
  # Secure storage for PIN codes
  flutter_secure_storage: ^9.0.0
```

## Installation

```bash
flutter pub get
```

## Platform Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<manifest>
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
</manifest>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSFaceIDUsageDescription</key>
<string>We need Face ID to unlock the app</string>
```

## Usage Example

```dart
// In app.dart or wherever you provide services
import 'package:shared_preferences/shared_preferences.dart';
import 'core/security/biometric_service.dart';
import 'core/security/app_lock_service.dart';

// In your provider setup:
final prefs = await SharedPreferences.getInstance();
final biometricService = BiometricService();
final appLockService = AppLockService(prefs);

// Provide them via Provider or GetIt
Provider<BiometricService>(create: (_) => biometricService),
Provider<AppLockService>(create: (_) => appLockService),
```

## Note

The biometric services are **optional** - the app will work without them.
They're only needed when implementing the app lock feature.

For now, you can:
1. Leave them as-is (they won't break the app)
2. Add dependencies when ready to implement app lock
3. Remove the files if you don't plan to use biometrics

The important architectural lesson is: **security services belong in `core/security/`, not in `features/settings/`**.
