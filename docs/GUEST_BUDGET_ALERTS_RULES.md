# Guest Mode Budget & Alerts Rules

## 🔒 **LOCKED RULES** (Implemented Now to Avoid Future Confusion)

These rules are defined **now**, even if budgets and alerts are not yet fully implemented. This prevents future confusion and ensures consistent behavior.

---

## 📊 **Guest Budgets**

### Rule 1: Local Storage Only
```
✅ Guest budgets are stored in Hive (local storage)
❌ Guest budgets are NEVER synced to Firestore
❌ Guest budgets are NEVER visible to Firebase
```

### Rule 2: Same Behavior as Logged-In Users
```
✅ Guest users can create budgets
✅ Guest users can edit budgets
✅ Guest users can delete budgets
✅ Guest users can set budget limits
✅ Guest users can track budget progress
```

### Rule 3: Data Lifecycle
```
✅ Budgets persist across app restarts
✅ Budgets are cleared on logout (with warning)
✅ Budgets can be migrated when guest creates account
❌ Budgets are NOT deleted on app update
```

### Implementation Checklist:
- [ ] Create `guest_budgets` Hive box
- [ ] Add `isGuest` check in BudgetProvider
- [ ] Route to Hive for guests, Firestore for logged-in
- [ ] Add budget migration to GuestDataMigrationService
- [ ] Include budgets in logout warning dialog

---

## 🔔 **Guest Alerts**

### Rule 1: Local Notifications Only
```
✅ Guest alerts use local notifications
❌ Guest alerts NEVER use FCM (Firebase Cloud Messaging)
❌ Guest alerts NEVER create Firebase notification tokens
```

### Rule 2: Alert Types Supported
```
✅ Budget limit warnings (local)
✅ Spending threshold alerts (local)
✅ Daily/weekly summaries (local)
❌ Push notifications (requires FCM)
❌ Cross-device notifications (requires cloud)
```

### Rule 3: Notification Permissions
```
✅ Request local notification permissions for guests
✅ Show same permission dialogs as logged-in users
❌ Don't request FCM token for guests
❌ Don't register device with Firebase for guests
```

### Implementation Checklist:
- [ ] Use `flutter_local_notifications` for guest alerts
- [ ] Add `isGuest` check before FCM token registration
- [ ] Skip Firebase Messaging setup for guests
- [ ] Store alert preferences in SharedPreferences
- [ ] Migrate alert preferences during account creation

---

## 🛡️ **Why These Rules Matter**

### 1. **Privacy**
- Guest users don't want cloud tracking
- No Firebase user ID = no tracking footprint
- Local-only data = user control

### 2. **Performance**
- No network calls for guest budgets/alerts
- Instant response times
- Works offline by default

### 3. **Cost**
- No Firestore reads/writes for guests
- No FCM token management
- No Firebase quota usage

### 4. **Simplicity**
- Clear separation: Local vs Cloud
- Easy to reason about
- Prevents edge cases

---

## 📝 **Code Examples**

### Budget Provider (Future Implementation)

```dart
class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  UserEntity? _currentUser;

  Future<void> addBudget(BudgetEntity budget) async {
    // RULE: Guest budgets go to Hive, not Firestore
    if (_currentUser?.isGuest == true) {
      final box = Hive.box('guest_budgets');
      final model = BudgetModel.fromEntity(budget);
      await box.put(budget.id, model.toLocalMap());
      return;
    }

    // Normal users: Firestore
    await _repository.addBudget(budget);
  }
}
```

### Alert Service (Future Implementation)

```dart
class AlertService {
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseMessaging? _fcm;

  Future<void> setupNotifications(UserEntity user) async {
    // RULE: Guests use local notifications only
    if (user.isGuest) {
      // Setup local notifications
      await _setupLocalNotifications();
      
      // DO NOT setup FCM for guests
      return;
    }

    // Logged-in users: Setup both local and FCM
    await _setupLocalNotifications();
    await _setupFCM();
  }

  Future<void> _setupLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(settings);
  }

  Future<void> _setupFCM() async {
    // Only for logged-in users
    final token = await _fcm?.getToken();
    // Save token to Firestore...
  }

  Future<void> sendBudgetAlert(String message) async {
    // Works for both guest and logged-in users
    await _localNotifications.show(
      0,
      'Budget Alert',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          importance: Importance.high,
        ),
      ),
    );
  }
}
```

### Migration Service Update (Add Budget Migration)

```dart
Future<bool> migrateBudgetsToFirestore(String userId) async {
  try {
    final budgetBox = Hive.box('guest_budgets');
    if (budgetBox.isEmpty) return true;

    final batch = FirebaseFirestore.instance.batch();
    
    for (var budgetData in budgetBox.values) {
      final map = Map<String, dynamic>.from(budgetData as Map);
      final budget = BudgetModel.fromLocalMap(map);
      
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budget.id);
      
      batch.set(docRef, budget.toMap());
    }

    // CRITICAL: Only clear after successful write
    await batch.commit();
    await budgetBox.clear();
    
    return true;
  } catch (e) {
    // Guest budgets preserved on failure
    return false;
  }
}
```

---

## ⚠️ **Common Pitfalls to Avoid**

### ❌ DON'T: Mix Local and Cloud for Guests
```dart
// WRONG - Don't do this!
if (user.isGuest) {
  await _localBox.put(budget.id, budget);
  await _firestore.collection('budgets').add(budget); // ❌ NO!
}
```

### ✅ DO: Keep Guest Data Fully Local
```dart
// CORRECT
if (user.isGuest) {
  await _localBox.put(budget.id, budget);
  return; // Stop here - no cloud operations
}

// Only logged-in users reach this point
await _firestore.collection('budgets').add(budget);
```

### ❌ DON'T: Request FCM Token for Guests
```dart
// WRONG - Don't do this!
final token = await FirebaseMessaging.instance.getToken(); // ❌ NO!
if (!user.isGuest) {
  await saveTokenToFirestore(token);
}
```

### ✅ DO: Skip FCM Entirely for Guests
```dart
// CORRECT
if (user.isGuest) {
  // Use local notifications only
  await _setupLocalNotifications();
  return;
}

// Only logged-in users get FCM
final token = await FirebaseMessaging.instance.getToken();
await saveTokenToFirestore(token);
```

---

## 🎯 **Summary**

| Feature | Guest Mode | Logged-In Mode |
|---------|-----------|----------------|
| **Budget Storage** | Hive (Local) | Firestore (Cloud) |
| **Budget CRUD** | ✅ Full Support | ✅ Full Support |
| **Budget Sync** | ❌ No | ✅ Yes |
| **Local Notifications** | ✅ Yes | ✅ Yes |
| **Push Notifications (FCM)** | ❌ No | ✅ Yes |
| **Cross-Device Alerts** | ❌ No | ✅ Yes |
| **Data Migration** | ✅ On Account Creation | N/A |
| **Data Persistence** | ✅ Until Logout | ✅ Forever |

---

## 📋 **Future Implementation Checklist**

When implementing budgets and alerts, ensure:

### Budgets:
- [ ] Create `guest_budgets` Hive box in bootstrap.dart
- [ ] Add `toLocalMap()` / `fromLocalMap()` to BudgetModel
- [ ] Add `isGuest` routing in BudgetProvider
- [ ] Update logout warning to mention budgets
- [ ] Add budget migration to GuestDataMigrationService
- [ ] Test budget persistence across app restarts
- [ ] Test budget migration on account creation

### Alerts:
- [ ] Add `flutter_local_notifications` package
- [ ] Create AlertService with guest/logged-in routing
- [ ] Skip FCM setup for guests
- [ ] Store alert preferences in SharedPreferences
- [ ] Test local notifications for guests
- [ ] Test FCM notifications for logged-in users
- [ ] Ensure no FCM token created for guests

---

**These rules are now locked. Future implementations must follow them.** 🔒
