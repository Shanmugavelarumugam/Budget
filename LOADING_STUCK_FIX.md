# 🔧 Loading Dialog Stuck - QUICK FIX

## 🐛 **Problem**

Loading dialog doesn't close after reset, app is stuck.

---

## ✅ **Quick Fix**

The reset function needs a `finally` block to ALWAYS close the dialog.

**File**: `lib/features/settings/presentation/screens/settings_home_screen.dart`

**Line**: Around 401-476

---

## 📝 **Replace the `onPressed` function with this**:

```dart
onPressed: () async {
  Navigator.pop(context); // Close confirmation

  // Show loading
  DeletingDataDialog.show(context);

  bool success = false;
  
  try {
    final settingsProvider = context.read<SettingsProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    // Delete Firebase data
    if (user != null && !user.isGuest) {
      await DataDeletionService().deleteAllUserData(user.uid);
    }

    // Clear local data
    await transactionProvider.clearGuestData();
    await settingsProvider.resetSettings();
    await LocalBudgetCleaner.clearAllBudgets();

    // Sign out
    await authProvider.signOut();
    
    success = true;
  } catch (e) {
    print('❌ Reset error: $e');
  } finally {
    // ALWAYS close dialog and navigate
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      // Close dialog
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        print('Error closing: $e');
      }

      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        // Navigate
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.welcome,
          (route) => false,
        );

        // Show message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success 
                  ? '✅ All data deleted'
                  : '⚠️ Reset complete (some errors)'),
                backgroundColor: success 
                  ? const Color(0xFF22C55E)
                  : Colors.orange,
              ),
            );
          }
        });
      }
    }
  }
},
```

---

## 🎯 **Key Changes**

1. **Added `finally` block** - Runs no matter what
2. **Added `success` flag** - Tracks if reset worked
3. **Added try-catch around dialog close** - Prevents errors
4. **Always navigates** - Even if there are errors

---

## 🚀 **Test**

1. Hot reload
2. Reset app data
3. Dialog should close after 5-15 seconds
4. Should navigate to welcome screen

---

**This ensures the dialog ALWAYS closes! 🎉**
