# 🔴 EmailJS 403 Error - Enable Mobile API Access

## ❌ **Error**
```
403: API calls are disabled for non-browser applications
```

## 🎯 **What This Means**

EmailJS has a security setting that **blocks API calls from mobile apps by default**. You need to enable it in your account settings.

---

## ✅ **SOLUTION: Enable API Access**

### **Step 1: Go to EmailJS Account Settings**

1. Visit: https://dashboard.emailjs.com/admin/account
2. Login if needed

### **Step 2: Find "Security" Section**

Scroll down to find the **"Security"** or **"API Access"** section.

### **Step 3: Enable "Allow API calls from non-browser applications"**

Look for a checkbox or toggle that says:
- **"Allow API calls from non-browser applications"**
- OR **"Allow requests from mobile apps"**
- OR **"Disable origin check"**

✅ **Enable/Check this option**

### **Step 4: Save Changes**

Click **"Save"** or **"Update"** button.

---

## 🔧 **Alternative: Add Origin Header**

If you can't find the setting above, we can add an origin header to trick EmailJS into thinking it's a browser request:

Update `email_service.dart`:

```dart
final response = await http.post(
  Uri.parse(_emailJsUrl),
  headers: {
    'Content-Type': 'application/json',
    'origin': 'http://localhost',  // ← Add this line
  },
  body: jsonEncode({...}),
);
```

---

## 📸 **What to Look For**

In your EmailJS dashboard, you should see something like:

```
┌─────────────────────────────────────────────────────┐
│ Security Settings                                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ☐ Allow API calls from non-browser applications    │
│                                                     │
│ This allows requests from mobile apps, desktop     │
│ apps, and server-side applications.                │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Check that box!**

---

## 🚀 **After Enabling**

1. ✅ Enable the setting in EmailJS dashboard
2. ✅ Save changes
3. ✅ Hot reload app (`r` in terminal)
4. ✅ Try sending invitation
5. ✅ Should work! 🎉

---

## 💡 **Why This Happens**

EmailJS blocks non-browser requests by default to prevent:
- Spam
- API abuse
- Unauthorized usage

But for legitimate mobile apps (like yours), you need to explicitly enable it.

---

## 🔍 **If You Can't Find the Setting**

Try these locations in EmailJS dashboard:
1. **Account** → **Security**
2. **Account** → **Settings**
3. **Account** → **API Access**
4. **Integration** → **Security**

Or search for:
- "non-browser"
- "mobile"
- "origin"
- "CORS"

---

**Enable this setting and your emails will send! 🎯**
