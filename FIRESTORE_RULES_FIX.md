# 🔥 Firestore Security Rules Update

## ❌ Current Issue

You're getting this error:
```
[cloud_firestore/permission-denied] The caller does not have permission 
to execute the specified operation.
```

This happens because your Firestore security rules don't allow access to the new `categories` subcollection under `budgets`.

---

## ✅ Solution: Update Firestore Security Rules

### **Current Structure (What We Added)**

```
users/{userId}/budgets/{month}/categories/{categoryId}
```

### **Required Security Rules**

Go to **Firebase Console** → **Firestore Database** → **Rules** and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      // Allow users to read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Budgets subcollection
      match /budgets/{month} {
        // Allow users to read/write their own budgets
        allow read, write: if request.auth != null && request.auth.uid == userId;
        
        // ✅ ADD THIS: Category budgets subcollection
        match /categories/{categoryId} {
          // Allow users to read/write their own category budgets
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
      }
      
      // Transactions subcollection (if you have it)
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 📝 Step-by-Step Instructions

### **Step 1: Open Firebase Console**

1. Go to https://console.firebase.google.com/
2. Select your project
3. Click **Firestore Database** in the left menu
4. Click the **Rules** tab

### **Step 2: Update Rules**

Replace your current rules with the complete rules above, or add the `categories` section:

```javascript
// Inside users/{userId}/budgets/{month}
match /categories/{categoryId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

### **Step 3: Publish**

1. Click **Publish** button
2. Wait for confirmation: "Rules published successfully"

### **Step 4: Test**

1. Restart your Flutter app
2. Try setting category budgets again
3. Should work now! ✅

---

## 🔍 Complete Example Rules

Here's a complete, production-ready Firestore rules file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the resource
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Allow users to read/write their own user document
      allow read, write: if isOwner(userId);
      
      // Budgets subcollection
      match /budgets/{month} {
        // Allow users to read/write their own budgets
        allow read, write: if isOwner(userId);
        
        // Category budgets subcollection
        match /categories/{categoryId} {
          // Allow users to read/write their own category budgets
          allow read, write: if isOwner(userId);
        }
      }
      
      // Transactions subcollection
      match /transactions/{transactionId} {
        // Allow users to read/write their own transactions
        allow read, write: if isOwner(userId);
      }
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 🛡️ Security Best Practices

### **1. Always Validate User Ownership**
```javascript
allow read, write: if request.auth.uid == userId;
```

### **2. Add Data Validation (Optional)**
```javascript
match /categories/{categoryId} {
  allow create: if isOwner(userId) 
    && request.resource.data.amount >= 0
    && request.resource.data.categoryId is string
    && request.resource.data.month is string;
    
  allow update: if isOwner(userId)
    && request.resource.data.amount >= 0;
    
  allow delete: if isOwner(userId);
  
  allow read: if isOwner(userId);
}
```

### **3. Prevent Unauthorized Access**
```javascript
// Deny everything by default
match /{document=**} {
  allow read, write: if false;
}
```

---

## 🐛 Troubleshooting

### **Problem: Still getting permission denied**

**Solutions**:
1. **Check if rules are published**
   - Look for green "Published" status in Firebase Console

2. **Check authentication**
   - Make sure user is logged in
   - Check `request.auth.uid` matches `userId`

3. **Clear app data**
   - Uninstall and reinstall app
   - Or clear app data in device settings

4. **Check Firestore path**
   - Verify: `users/{userId}/budgets/{month}/categories/{categoryId}`
   - Not: `budgets/{month}/categories/{categoryId}` ❌

### **Problem: Rules not updating**

**Solutions**:
1. Wait 1-2 minutes after publishing
2. Hard refresh Firebase Console (Ctrl+Shift+R)
3. Check the **Rules** tab shows your new rules

### **Problem: Works in emulator but not production**

**Solutions**:
1. Make sure you published to **production**, not emulator
2. Check you're using the correct Firebase project
3. Verify project ID in `firebase_options.dart`

---

## ✅ Verification

After updating rules, test with:

```dart
// This should work now
await budgetProvider.setCategoryBudgets({
  'food': 12000.0,
  'transport': 5000.0,
});
```

You should see:
```
✅ Category budgets saved successfully
```

Instead of:
```
❌ [cloud_firestore/permission-denied]
```

---

## 📱 For Guest Users

**Good news**: Guest users are NOT affected by this issue!

Guest users use **Hive** (local storage), not Firestore, so they don't need Firestore rules.

If you're testing as a guest:
- ✅ Category budgets should work fine
- ✅ No Firestore permissions needed
- ✅ Data saved locally

---

## 🚀 Quick Fix Summary

1. **Go to**: Firebase Console → Firestore → Rules
2. **Add**:
   ```javascript
   match /categories/{categoryId} {
     allow read, write: if request.auth.uid == userId;
   }
   ```
3. **Publish** rules
4. **Restart** app
5. **Test** category budgets

---

## 📞 Still Having Issues?

If you still get permission errors after updating rules:

1. **Share your current Firestore rules** (from Firebase Console)
2. **Check Firebase Console** → Firestore → Data
   - Can you see `users/{userId}/budgets/{month}` manually?
3. **Check authentication**
   - Is user logged in?
   - Print `request.auth.uid` in rules simulator

---

**Update your Firestore rules and the error will be fixed!** 🔥✅
