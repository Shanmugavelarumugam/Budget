# App Lock Feature - Implementation Plan

## 🎯 Overview

Implement biometric authentication (Face ID/Fingerprint) with PIN fallback for app security.

**Status**: Ready to implement  
**Foundation**: ✅ Architecture prepared  
**Complexity**: Medium (3-4 hours)

---

## 📋 Requirements

### Core Features
1. ✅ **Biometric Authentication** - Face ID / Fingerprint
2. ✅ **PIN Fallback** - 4-6 digit PIN when biometric unavailable
3. ✅ **Auto-lock on Background** - Lock when app goes to background
4. ✅ **Resume Protection** - Require unlock when app resumes
5. ✅ **Settings UI** - Toggle on/off, set timeout, change PIN

### User Flows
```
First Time Setup:
1. User enables "App Lock" in settings
2. Choose: Biometric OR PIN
3. If biometric → test it → set PIN as fallback
4. If PIN only → create 4-6 digit PIN
5. Save preferences

App Launch (when locked):
1. Show lock screen
2. Try biometric (if enabled)
3. If biometric fails/unavailable → show PIN entry
4. If PIN correct → unlock app
5. If wrong PIN → show error, retry (max 5 attempts)

Background/Resume:
1. App goes to background → start timer
2. If timer > timeout → lock app
3. On resume → check if locked → show lock screen
```

---

## 🏗️ Architecture

### Layer Separation
```
core/security/              ← Business Logic (Services)
├── biometric_service.dart  - Handle Face ID/Fingerprint
├── pin_service.dart        - Handle PIN storage/verification
└── app_lock_controller.dart - Orchestrate locking logic

features/settings/          ← UI Layer
└── app_lock_settings_screen.dart - Settings UI

features/auth/              ← Lock Screen UI
└── app_lock_screen.dart    - Lock screen with biometric/PIN

app.dart                    ← Integration
└── AppLockWrapper          - Wrap app with lock check
```

---

## 📦 Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  # Biometric authentication
  local_auth: ^2.1.7
  local_auth_android: ^1.0.32
  local_auth_ios: ^1.1.4
  
  # Secure PIN storage
  flutter_secure_storage: ^9.0.0
  
  # App lifecycle detection
  # (already included in Flutter)
```

---

## 🔧 Implementation Steps

### Step 1: Add Dependencies
```bash
flutter pub add local_auth flutter_secure_storage
```

### Step 2: Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<manifest>
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
</manifest>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock the app with Face ID</string>
```

### Step 3: Create Services

**File**: `lib/core/security/biometric_service.dart`
- Check biometric availability
- Authenticate with biometric
- Get biometric type (Face ID vs Fingerprint)

**File**: `lib/core/security/pin_service.dart`
- Store PIN securely (flutter_secure_storage)
- Verify PIN
- Change PIN
- Clear PIN

**File**: `lib/core/security/app_lock_controller.dart`
- Orchestrate lock state
- Handle app lifecycle (background/foreground)
- Manage timeout logic
- Coordinate biometric + PIN

### Step 4: Create UI

**File**: `lib/features/auth/presentation/screens/app_lock_screen.dart`
- Lock screen UI
- Biometric button
- PIN entry pad
- Error messages

**File**: `lib/features/settings/presentation/screens/app_lock_settings_screen.dart`
- Enable/disable app lock
- Choose biometric vs PIN
- Set timeout duration
- Change PIN

### Step 5: Integrate with App

**File**: `lib/app.dart`
- Add `AppLockWrapper` widget
- Listen to app lifecycle
- Show lock screen when needed

---

## 🎨 UI Design

### Lock Screen
```
┌─────────────────────────┐
│                         │
│      🔒 App Locked      │
│                         │
│   [Fingerprint Icon]    │
│   Tap to unlock         │
│                         │
│   ─────────────────     │
│                         │
│   [1] [2] [3]           │
│   [4] [5] [6]           │
│   [7] [8] [9]           │
│       [0] [⌫]           │
│                         │
│   Enter PIN             │
│   ● ● ● ●               │
│                         │
└─────────────────────────┘
```

### Settings Screen
```
┌─────────────────────────┐
│ ← App Lock              │
├─────────────────────────┤
│                         │
│ 🔐 App Lock             │
│    [Toggle ON/OFF]      │
│                         │
│ 👆 Use Biometric        │
│    [Toggle ON/OFF]      │
│                         │
│ ⏱️ Auto-lock Timeout    │
│    Immediately ▼        │
│                         │
│ 🔢 Change PIN           │
│    →                    │
│                         │
└─────────────────────────┘
```

---

## 🔐 Security Considerations

1. **PIN Storage**
   - ✅ Use `flutter_secure_storage` (encrypted)
   - ❌ Never use SharedPreferences for PIN
   - ✅ Hash PIN before storing (optional, but recommended)

2. **Biometric Fallback**
   - Always provide PIN as fallback
   - Don't lock user out if biometric fails

3. **Failed Attempts**
   - Limit to 5 failed PIN attempts
   - After 5 fails → force logout OR wait 30 seconds

4. **Background Security**
   - Hide sensitive data when app goes to background
   - Clear clipboard on lock

---

## 🧪 Testing Checklist

- [ ] Biometric works on real device
- [ ] PIN fallback works
- [ ] Auto-lock triggers after timeout
- [ ] Resume from background requires unlock
- [ ] Settings persist across app restarts
- [ ] Wrong PIN shows error
- [ ] 5 failed attempts handled correctly
- [ ] Biometric unavailable → PIN works
- [ ] Guest mode → app lock disabled

---

## 📊 Estimated Effort

| Task                      | Time    |
|---------------------------|---------|
| Add dependencies          | 10 min  |
| Create services           | 1 hour  |
| Create lock screen UI     | 1 hour  |
| Create settings UI        | 45 min  |
| Integrate with app        | 1 hour  |
| Testing                   | 30 min  |
| **Total**                 | **4 hours** |

---

## 🚀 When You're Ready

Just say **"Let's implement app lock"** and I'll:

1. Add the dependencies
2. Create all service files
3. Build the lock screen UI
4. Build the settings UI
5. Integrate everything
6. Test and verify

**Your architecture is ready** - this will be a clean, incremental addition with zero refactoring needed! 🎉

---

## 📝 Notes

- App lock is **optional** - app works fine without it
- Can be implemented later without breaking changes
- Foundation is already in place (`core/security/`)
- No architectural changes needed
