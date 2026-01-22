# SharedPreferences Race Condition Fix

## 🐛 **Problem**

The app was crashing on startup with the error:

```
PlatformException(channel-error, Unable to establish connection on channel: 
"dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.getAll"., null, null)
```

## 🔍 **Root Cause**

The issue was in `TransactionProvider`:

```dart
// BEFORE (BROKEN)
class TransactionProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  TransactionProvider(this._repository) {
    _initPreferences();  // ❌ Async method called in constructor
  }
  
  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();  // ❌ Not awaited!
    // ...
  }
}
```

**The Problem:**
1. Constructor calls `_initPreferences()` but doesn't await it
2. `SharedPreferences.getInstance()` is async and takes time
3. Other methods try to use `_prefs` before it's initialized
4. Platform channel crashes because connection isn't established yet

This is a **race condition** - the app tries to use SharedPreferences before it's ready.

---

## ✅ **Solution**

Implemented **lazy initialization** with a safety guard:

```dart
// AFTER (FIXED)
class TransactionProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _prefsInitialized = false;  // ✅ Track initialization state
  
  TransactionProvider(this._repository);  // ✅ No async call in constructor
  
  /// Ensures SharedPreferences is initialized before use
  Future<void> _ensurePrefsInitialized() async {
    if (_prefsInitialized) return;  // ✅ Already initialized
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _guestTransactionCount = _prefs?.getInt('guest_transaction_count') ?? 0;
      _conversionBannerDismissed =
          _prefs?.getBool('conversion_banner_dismissed') ?? false;
      _prefsInitialized = true;
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
      _prefsInitialized = true;  // ✅ Mark as initialized even on error
    }
  }
}
```

**Then call it before using SharedPreferences:**

```dart
Future<void> dismissConversionBanner() async {
  await _ensurePrefsInitialized();  // ✅ Ensure prefs are ready
  _conversionBannerDismissed = true;
  await _prefs?.setBool('conversion_banner_dismissed', true);
  notifyListeners();
}

Future<void> addTransaction(TransactionEntity transaction) async {
  // ... save transaction to Hive ...
  
  // Increment transaction count for conversion banner
  await _ensurePrefsInitialized();  // ✅ Ensure prefs are ready
  _guestTransactionCount++;
  await _prefs?.setInt('guest_transaction_count', _guestTransactionCount);
}
```

---

## 🎯 **Key Changes**

### 1. **Removed Async Constructor Call**
```dart
// BEFORE
TransactionProvider(this._repository) {
  _initPreferences();  // ❌ Bad
}

// AFTER
TransactionProvider(this._repository);  // ✅ Good
```

### 2. **Added Initialization Guard**
```dart
bool _prefsInitialized = false;

Future<void> _ensurePrefsInitialized() async {
  if (_prefsInitialized) return;  // Only initialize once
  // ... initialization code ...
}
```

### 3. **Lazy Initialization**
- SharedPreferences is only initialized when first needed
- Each method that uses it calls `_ensurePrefsInitialized()` first
- Idempotent - safe to call multiple times

### 4. **Error Handling**
```dart
try {
  _prefs = await SharedPreferences.getInstance();
  // ... load values ...
} catch (e) {
  print('Error initializing SharedPreferences: $e');
  _prefsInitialized = true;  // Continue without preferences
}
```

---

## 📝 **Methods Updated**

All methods that use SharedPreferences now call `_ensurePrefsInitialized()`:

1. ✅ `dismissConversionBanner()`
2. ✅ `resetGuestState()`
3. ✅ `addTransaction()` (guest mode section)

---

## 🧪 **Testing**

### Before Fix:
```
❌ App crashes on startup
❌ PlatformException on channel
❌ SharedPreferences not initialized
```

### After Fix:
```
✅ App starts successfully
✅ SharedPreferences initialized lazily
✅ No platform channel errors
✅ Conversion banner state persists correctly
```

---

## 🎓 **Lessons Learned**

### **Rule: Never Call Async Methods in Constructors**

```dart
// ❌ BAD - Don't do this
class MyProvider {
  MyProvider() {
    _initAsync();  // This won't be awaited!
  }
  
  Future<void> _initAsync() async {
    // ...
  }
}

// ✅ GOOD - Do this instead
class MyProvider {
  bool _initialized = false;
  
  MyProvider();  // No async calls
  
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    // ... async initialization ...
    _initialized = true;
  }
  
  Future<void> someMethod() async {
    await _ensureInitialized();  // Ensure ready before use
    // ... use initialized resources ...
  }
}
```

### **Why This Pattern Works:**

1. **No Race Conditions** - Resources are initialized before use
2. **Idempotent** - Safe to call multiple times
3. **Lazy** - Only initializes when needed
4. **Error Resilient** - App continues even if initialization fails
5. **Testable** - Easy to mock and test

---

## 🔄 **Alternative Solutions**

### **Option 1: Static Initialization (Not Used)**
```dart
// Initialize in main() before runApp()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}
```
**Pros:** Guaranteed initialization  
**Cons:** Slows down app startup, tight coupling

### **Option 2: FutureProvider (Not Used)**
```dart
// Use riverpod/provider's FutureProvider
final prefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
```
**Pros:** Built-in async handling  
**Cons:** Requires additional dependencies, more complex

### **Option 3: Lazy Initialization (CHOSEN)**
```dart
// Our solution - initialize on first use
Future<void> _ensurePrefsInitialized() async {
  if (_prefsInitialized) return;
  // ... initialize ...
}
```
**Pros:** Simple, no dependencies, lazy loading  
**Cons:** Requires discipline to call before use

---

## ✅ **Status**

**FIXED** ✅

The app now:
- ✅ Starts without errors
- ✅ Initializes SharedPreferences lazily
- ✅ Handles initialization failures gracefully
- ✅ Persists conversion banner state correctly
- ✅ No platform channel errors

---

## 📚 **Related Documentation**

- [Flutter SharedPreferences Best Practices](https://docs.flutter.dev/cookbook/persistence/key-value)
- [Async Constructors Anti-Pattern](https://dart.dev/guides/language/effective-dart/usage#dont-use-async-when-it-has-no-useful-effect)
- [Provider Initialization Patterns](https://pub.dev/packages/provider#initialization)

---

**Fix implemented:** 2026-01-15  
**Files modified:** `lib/features/budget/presentation/providers/transaction_provider.dart`  
**Status:** Production-ready ✅
