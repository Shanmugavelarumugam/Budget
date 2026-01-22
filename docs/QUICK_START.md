# Quick Start Guide - Guest Mode with Conversion Banner

## 🚀 Running the App

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run
```

## 🧪 Testing Guest Mode

### Test Scenario 1: Conversion Banner Appears

1. **Launch the app**
2. **Tap "Continue as Guest"** on the Welcome screen
3. **Navigate to Dashboard** (you should see the existing guest mode banner at the bottom)
4. **Tap the floating "+" button** to add a transaction
5. **Fill in transaction details** and save
6. **Return to Dashboard** 
7. **✅ You should now see the Conversion Banner** appear between the action buttons and recent transactions!

### Test Scenario 2: Dismiss Banner

1. **Follow steps 1-7 above** to see the banner
2. **Tap "Dismiss"** on the conversion banner
3. **Add another transaction**
4. **Return to Dashboard**
5. **✅ Banner should NOT appear** (permanently dismissed)

### Test Scenario 3: Sign Up from Banner

1. **Reset the app** (or clear app data)
2. **Follow steps 1-7** to see the banner
3. **Tap "Sign Up"** on the conversion banner
4. **✅ Should navigate to Registration screen**

### Test Scenario 4: Banner Auto-Hides After 2 Transactions

1. **Enter guest mode** and add 1 transaction
2. **✅ Banner appears**
3. **Add 2nd transaction**
4. **✅ Banner still appears**
5. **Add 3rd transaction**
6. **✅ Banner auto-hides** (no longer shown)

### Test Scenario 5: Logout Warning

1. **Enter guest mode** and add some transactions
2. **Navigate to Profile screen** (4th tab in bottom nav)
3. **Scroll down and tap "Logout"**
4. **✅ Warning dialog appears**: "WARNING: All guest data will be deleted if you logout. Are you sure?"
5. **Tap "Logout"**
6. **✅ Data is cleared** and you're returned to Welcome screen

### Test Scenario 6: Session Persistence

1. **Enter guest mode** and add 1 transaction
2. **Close the app completely** (swipe up from app switcher)
3. **Reopen the app**
4. **✅ Still in guest mode** with your transaction data intact
5. **✅ Conversion banner still appears** (session persisted)

## 📱 UI Elements to Look For

### Conversion Banner Design:
- **Location**: Between action buttons and "Recent Transactions" header
- **Background**: Blue-purple gradient with subtle border
- **Icon**: Lock icon (🔒) on the left
- **Text**: 
  - Title: "You're in Guest Mode"
  - Subtitle: "Create an account to back up your data"
- **Buttons**:
  - "Dismiss" (text button, subtle)
  - "Sign Up" (elevated button, blue, prominent)

### Existing Guest Mode Banner:
- **Location**: Bottom of screen, above navigation bar
- **Text**: "You are in Guest Mode. Data will not be saved."
- **Button**: "Sign In"

## 🔍 Debugging Tips

### Check Transaction Count:
```dart
// In TransactionProvider
print('Guest transaction count: $_guestTransactionCount');
print('Should show banner: $shouldShowConversionBanner');
```

### Check SharedPreferences:
```dart
// In TransactionProvider._initPreferences()
final count = _prefs?.getInt('guest_transaction_count') ?? 0;
final dismissed = _prefs?.getBool('conversion_banner_dismissed') ?? false;
print('Loaded count: $count, dismissed: $dismissed');
```

### Reset Guest State Manually:
```dart
// In Dart DevTools console or add a debug button
await Provider.of<TransactionProvider>(context, listen: false).resetGuestState();
```

## 📊 Expected Behavior Summary

| Action | Transaction Count | Banner Visible? |
|--------|------------------|-----------------|
| Enter guest mode | 0 | ❌ No |
| Add 1st transaction | 1 | ✅ Yes |
| Add 2nd transaction | 2 | ✅ Yes |
| Add 3rd transaction | 3 | ❌ No (auto-hide) |
| Dismiss banner | Any | ❌ No (permanent) |
| Logout & re-enter | 0 (reset) | ❌ No (until 1st txn) |

## 🎯 Key Features Implemented

✅ **Soft Conversion Prompt** - Non-blocking banner after 1-2 transactions  
✅ **Dismissible** - User can permanently hide the banner  
✅ **Smart Timing** - Shows when user has invested effort (added data)  
✅ **Loss Aversion** - "Back up your data" messaging  
✅ **Clear CTA** - Prominent "Sign Up" button  
✅ **Auto-Hide** - Disappears after 3+ transactions  
✅ **State Persistence** - Banner state survives app restarts  
✅ **Data Safety** - Warning dialog on logout  

## 🐛 Known Issues (Non-Critical)

- **Deprecation warnings** for `withOpacity` - These are Flutter framework warnings and don't affect functionality
- **Print statements** in production code - Can be replaced with proper logging if needed

## 📝 Next Steps

1. **Test on physical device** for real-world UX
2. **Add analytics** to track conversion rates
3. **A/B test** different banner messages
4. **Implement migration** feature for guest-to-user data transfer

---

**Everything is ready to go! 🎉**

The guest mode with conversion banner is fully implemented and ready for testing.
