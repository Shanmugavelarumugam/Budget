# 🔴 EmailJS 400 Error - URGENT FIX

## ❌ **Error**
```
Failed to send invitation: [400] The parameters are invalid
```

This means your **EmailJS template configuration is still incorrect**.

---

## 🎯 **EXACT FIX REQUIRED**

### **The Problem**
EmailJS is **very strict** about template configuration. Even one missing field causes a 400 error.

### **The Solution**
You MUST configure **EVERY field** in the EmailJS template editor.

---

## 📧 **STEP-BY-STEP FIX** (Follow Exactly)

### **1. Go to EmailJS Dashboard**
- URL: https://dashboard.emailjs.com/admin
- Login with your account

### **2. Click "Email Templates"** (left sidebar)

### **3. Find and click: `template_juyopsl`**

### **4. Click the "Edit" button**

### **5. Configure ALL Fields** (CRITICAL):

---

## ✅ **EXACT TEMPLATE CONFIGURATION**

### **📝 Template Name**
```
Family Invitation
```

### **📧 Subject**
```
{{from_name}} invited you to view their finances
```

### **📄 Content** (Copy this EXACTLY):
```html
<p>Hi there,</p>

<p><strong>{{from_name}}</strong> has invited you to view their finances in <strong>{{app_name}}</strong>.</p>

<p><a href="{{invite_link}}" style="display:inline-block;padding:12px 24px;background:#3B82F6;color:white;text-decoration:none;border-radius:8px;">Accept Invitation</a></p>

<p style="font-size:12px;color:#666;">This is a read-only invitation.</p>
```

### **⚙️ Settings** (Right Side Panel - VERY IMPORTANT):

| Field | Exact Value | Notes |
|-------|-------------|-------|
| **To Email** | `{{to_email}}` | ⚠️ MUST be exactly this |
| **From Name** | `Budget App` | Can be any text |
| **From Email** | *(leave default)* | Don't change |
| **Reply To** | *(leave empty)* | Optional |
| **Bcc Email** | *(leave empty)* | Optional |

---

## ⚠️ **CRITICAL CHECKLIST**

Before clicking "Save", verify:

- [ ] Subject field is NOT empty
- [ ] Content field is NOT empty
- [ ] Content uses `{{from_name}}`
- [ ] Content uses `{{app_name}}`
- [ ] Content uses `{{invite_link}}`
- [ ] "To Email" is set to `{{to_email}}` (with double braces)
- [ ] "From Name" has some text (e.g., "Budget App")

---

## 🔍 **Common Mistakes That Cause 400**

### ❌ **Wrong**:
```
To Email: (empty)                    ← 400 error
To Email: test@example.com           ← 400 error
To Email: {to_email}                 ← 400 error (single braces)
Content: (empty)                     ← 400 error
Content: Hello                       ← 400 error (no variables)
```

### ✅ **Correct**:
```
To Email: {{to_email}}               ← Works!
Content: Hello {{from_name}}         ← Works!
```

---

## 🧪 **VERIFICATION STEPS**

### **After Saving Template**:

1. **Check EmailJS Dashboard**:
   - Go to: https://dashboard.emailjs.com/admin/templates/template_juyopsl
   - Verify all fields are filled
   - Verify "To Email" shows `{{to_email}}`

2. **Test in App**:
   - Hot reload app
   - Try sending invitation
   - Check console for detailed error

3. **Check EmailJS Email Log**:
   - Dashboard → Email Log
   - See if request appears
   - Check error details

---

## 🔧 **Alternative: Create New Template**

If the template is corrupted, create a fresh one:

### **Steps**:

1. **EmailJS Dashboard** → **Email Templates**
2. Click **"Create New Template"**
3. **Template Name**: `family_invitation_v2`
4. **Subject**: `{{from_name}} invited you`
5. **Content**:
```html
<p>{{from_name}} invited you to {{app_name}}.</p>
<p><a href="{{invite_link}}">Accept</a></p>
```
6. **To Email**: `{{to_email}}`
7. **From Name**: `Budget App`
8. Click **"Save"**
9. **Copy the new Template ID**
10. Update `email_service.dart`:
```dart
static const String _templateId = 'NEW_TEMPLATE_ID_HERE';
```

---

## 📊 **Debug Information**

### **Your Current Config**:
```
Service ID:  service_lqdp09g  ✅
Template ID: template_juyopsl ✅
Public Key:  sN1rULjuL_V7DzPPj ✅
```

### **Variables Sent from Flutter**:
```dart
{
  'to_email': 'recipient@example.com',
  'from_name': 'John Doe',
  'invite_link': 'https://yourapp.com/invite/abc123',
  'app_name': 'Budget App',
}
```

### **Template MUST Use**:
- `{{to_email}}` in "To Email" field
- `{{from_name}}` in Subject or Content
- `{{invite_link}}` in Content
- `{{app_name}}` in Content (optional but sent)

---

## 🆘 **Still Getting 400?**

### **Option 1: Use EmailJS Test Feature**

1. Go to template editor
2. Click "Test It" button
3. Fill in test values:
   - `to_email`: your email
   - `from_name`: Test User
   - `invite_link`: https://test.com
   - `app_name`: Test App
4. Click "Send Test"
5. If test fails → template config is wrong
6. If test succeeds → Flutter code issue

### **Option 2: Check EmailJS Logs**

1. Dashboard → Email Log
2. Look for recent failed attempts
3. Click on failed entry
4. Read exact error message
5. Fix the specific issue mentioned

### **Option 3: Verify Account Status**

1. Dashboard → Account
2. Check if account is active
3. Verify free tier limit not exceeded (200/month)
4. Check if email service is connected

---

## 🎯 **Quick Fix Checklist**

```
☐ Go to https://dashboard.emailjs.com/
☐ Click "Email Templates"
☐ Click template_juyopsl
☐ Click "Edit"
☐ Verify Subject has text with {{from_name}}
☐ Verify Content has HTML with {{from_name}}, {{app_name}}, {{invite_link}}
☐ Verify "To Email" = {{to_email}}
☐ Verify "From Name" has text
☐ Click "Save"
☐ Wait 10 seconds
☐ Hot reload app
☐ Try sending again
```

---

## 💡 **Minimal Working Template**

If nothing works, use this **absolute minimum**:

**Subject**:
```
Invitation
```

**Content**:
```
{{from_name}} invited you. Click: {{invite_link}}
```

**To Email**:
```
{{to_email}}
```

**From Name**:
```
App
```

This WILL work if configured exactly.

---

## 📞 **Next Steps**

1. **Fix template** using instructions above
2. **Save** the template
3. **Wait 10 seconds** (EmailJS caches)
4. **Hot reload** app
5. **Try again**

If still failing:
- Screenshot your template editor
- Check EmailJS email log
- Verify account status
- Try creating new template

---

**The 400 error ALWAYS means template misconfiguration. Follow the steps above exactly! 🎯**
