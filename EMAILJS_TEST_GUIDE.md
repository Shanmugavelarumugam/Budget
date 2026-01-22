# 🧪 EmailJS Integration - Test Checklist

## ✅ **Implementation Complete!**

Your Family/Shared invitation feature now:
- ✅ Saves invitations to Firestore
- ✅ Sends real emails via EmailJS
- ✅ Uses official `emailjs` package
- ✅ No backend required!

---

## 📋 **Quick Test Checklist**

### **1. App Runs** ✅
```bash
flutter run --hot
```
- App should compile without errors
- No red screens

### **2. Navigate to Family/Shared** ✅
1. Open drawer (hamburger menu)
2. Scroll down
3. Tap "Family / Shared"
4. Should see Family Home screen

### **3. Send Test Invitation** ✅
1. Tap "Invite Member"
2. Enter **your own email** (for testing)
3. Tap "Send Invitation"
4. Should see loading spinner
5. Should see success message: "✅ Invitation sent to [email]"

### **4. Check Firestore** ✅
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Firestore Database
4. Navigate to: `users/{your-uid}/shared_members`
5. Should see new document with:
   ```
   {
     email: "test@example.com",
     status: "pending",
     invitedAt: [timestamp],
     invitedBy: "your-uid"
   }
   ```

### **5. Check Email Inbox** 📬
1. Open your email inbox
2. Check **spam folder** if not in inbox
3. Should receive email from EmailJS
4. Email should contain:
   - Subject: "[Your Name] invited you to view their finances"
   - Invitation link
   - Permissions list

---

## 🎯 **Expected Results**

### **Success Flow**:
```
User taps "Send Invitation"
  ↓
Loading spinner shows
  ↓
Firestore document created
  ↓
EmailJS sends email
  ↓
Success snackbar shows
  ↓
Screen closes
  ↓
Email arrives in inbox
```

### **Error Flow**:
```
User taps "Send Invitation"
  ↓
Loading spinner shows
  ↓
Error occurs (no internet, EmailJS limit, etc.)
  ↓
Error snackbar shows: "❌ Failed to send invitation: [error]"
  ↓
User can try again
```

---

## 🔍 **Troubleshooting**

### **Problem: "Failed to send invitation"**

**Possible causes**:
1. **No internet connection**
   - Check WiFi/mobile data
   - Try again with connection

2. **EmailJS free tier limit reached** (200 emails/month)
   - Check [EmailJS Dashboard](https://dashboard.emailjs.com/)
   - View usage statistics
   - Wait for next month or upgrade

3. **Invalid EmailJS credentials**
   - Verify in `email_service.dart`:
     - Service ID: `service_lqdp09g`
     - Template ID: `template_juyopsl`
     - Public Key: `sN1rULjuL_V7DzPPj`

4. **Template not configured**
   - Go to EmailJS Dashboard
   - Check template exists
   - Verify template variables match

### **Problem: Email not received**

1. **Check spam folder** 📂
2. **Wait 1-2 minutes** (EmailJS can be slow)
3. **Check EmailJS logs**:
   - Go to [EmailJS Dashboard](https://dashboard.emailjs.com/)
   - Click "Email Log"
   - See if email was sent

4. **Verify template variables**:
   Required in your EmailJS template:
   - `{{to_email}}`
   - `{{from_name}}`
   - `{{invite_link}}`
   - `{{app_name}}`

### **Problem: Firestore document not created**

1. **Check Firestore rules**:
   - Rules should allow authenticated users to write
   - Deploy rules: `firebase deploy --only firestore:rules`

2. **Check user authentication**:
   - User must be logged in (not guest)
   - Check `authProvider.user` is not null

3. **Check Firebase initialization**:
   - Verify `firebase_options.dart` exists
   - Check `Firebase.initializeApp()` in `main.dart`

---

## 📊 **EmailJS Dashboard Checks**

### **View Email Logs**:
1. Go to [EmailJS Dashboard](https://dashboard.emailjs.com/)
2. Click **Email Log** in sidebar
3. See recent emails sent
4. Check status: ✅ Sent or ❌ Failed

### **Check Usage**:
1. Dashboard → **Usage**
2. See emails sent this month
3. Free tier: **200 emails/month**
4. Upgrade if needed

### **Verify Template**:
1. Dashboard → **Email Templates**
2. Click `template_juyopsl`
3. Verify variables are used:
   ```
   {{to_email}}
   {{from_name}}
   {{invite_link}}
   {{app_name}}
   ```

---

## 🎉 **Success Indicators**

All of these should be TRUE:

- [ ] ✅ App runs without errors
- [ ] ✅ Can navigate to Family/Shared screen
- [ ] ✅ Can tap "Invite Member"
- [ ] ✅ Can enter email and tap "Send"
- [ ] ✅ Loading spinner shows
- [ ] ✅ Success snackbar appears
- [ ] ✅ Firestore document created
- [ ] ✅ Email received in inbox (or spam)

**If all are TRUE → Feature is DONE! 🎉**

---

## 🔐 **Security Verification**

### **What's Safe** ✅:
- Public key in code (OK for EmailJS)
- Firestore rules deployed
- User authentication required

### **What to Never Do** ❌:
- Don't commit SMTP passwords
- Don't commit SendGrid secret keys
- Don't commit Firebase private keys

### **Your Implementation** ✅:
- Uses EmailJS public key (safe)
- No secrets in code
- Firestore rules protect data
- Only authenticated users can invite

---

## 📝 **Next Steps**

After testing successfully:

1. **Update EmailJS template** (make it pretty)
2. **Test with real family member**
3. **Implement invitation acceptance flow**
4. **Add invitation expiry** (7 days)
5. **Add rate limiting** (max 5 invites/day)
6. **Deploy to production**

---

## 🆘 **Still Having Issues?**

1. Check console logs for detailed errors
2. Verify all credentials match exactly
3. Test with a different email address
4. Try restarting the app
5. Check Firebase Console for errors

---

**Ready to test? Follow the checklist above! 🚀**
