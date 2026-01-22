# 🔧 EmailJS Template Fix - URGENT

## ❌ **Current Problem**

**Error**: `[400] The parameters are invalid`

**Cause**: Your EmailJS template Content field is **empty or doesn't use the variables** that your Flutter code is sending.

---

## ✅ **SOLUTION: Update Your EmailJS Template**

### **Step-by-Step Instructions**:

1. **Go to EmailJS Dashboard**:
   - Visit: https://dashboard.emailjs.com/
   - Login with your account

2. **Navigate to Email Templates**:
   - Click **"Email Templates"** in the left sidebar
   - Find and click: `template_juyopsl`

3. **Click "Edit" button**

4. **Configure Template Fields** (EXACTLY as shown below):

---

## 📧 **Template Configuration**

### **🔹 Subject Field**:
```
{{from_name}} invited you to view their finances
```

### **🔹 Content Field** (COPY THIS EXACTLY):
```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
  <h2 style="color: #1e293b;">You're invited 👋</h2>

  <p style="font-size: 16px; line-height: 1.6; color: #334155;">
    <strong>{{from_name}}</strong> has invited you to view their finances
    in the <strong>{{app_name}}</strong>.
  </p>

  <div style="background: #f1f5f9; padding: 20px; border-radius: 12px; margin: 24px 0;">
    <h3 style="margin-top: 0; color: #1e293b;">What you can do:</h3>
    <ul style="color: #22c55e; margin: 0; padding-left: 20px;">
      <li>✓ View transactions</li>
      <li>✓ View budgets</li>
      <li>✓ View reports</li>
    </ul>
    
    <h3 style="margin-top: 16px; color: #1e293b;">What you CANNOT do:</h3>
    <ul style="color: #ef4444; margin: 0; padding-left: 20px;">
      <li>✗ Edit or delete data</li>
      <li>✗ Change settings</li>
    </ul>
  </div>

  <center>
    <a
      href="{{invite_link}}"
      style="display: inline-block;
             padding: 14px 28px;
             background: #3B82F6;
             color: white;
             text-decoration: none;
             border-radius: 8px;
             font-weight: bold;
             margin-top: 16px;"
    >
      Accept Invitation
    </a>
  </center>

  <p style="font-size: 12px; color: #64748b; margin-top: 32px; text-align: center;">
    This is a read-only invitation for transparency and accountability.
  </p>
  
  <p style="font-size: 11px; color: #94a3b8; margin-top: 8px; text-align: center;">
    If you didn't expect this invitation, you can safely ignore this email.
  </p>
</div>
```

### **🔹 Right-Side Settings** (VERY IMPORTANT):

| Field | Value | Notes |
|-------|-------|-------|
| **To Email** | `{{to_email}}` | ⚠️ MUST use double curly braces |
| **From Name** | `Budget App` | Or your app name |
| **From Email** | Use Default | Leave as default |
| **Reply To** | `{{to_email}}` | Optional |
| **Cc** | (empty) | Leave blank |
| **Bcc** | (empty) | Leave blank |

---

## 🎯 **Variables Being Sent from Flutter**

Your `email_service.dart` sends these variables:

```dart
{
  'to_email': toEmail,        // Recipient's email
  'from_name': fromName,      // Sender's name
  'invite_link': invitationId, // Invitation link
  'app_name': 'Budget App',   // App name
}
```

**All 4 variables MUST be used in your template!**

---

## ✅ **Verification Checklist**

After updating your template, verify:

- [ ] Subject uses `{{from_name}}`
- [ ] Content uses `{{from_name}}`
- [ ] Content uses `{{app_name}}`
- [ ] Content uses `{{invite_link}}` in the button
- [ ] "To Email" field is set to `{{to_email}}`
- [ ] "From Name" is set to "Budget App" (or your choice)
- [ ] Click **"Save"** button

---

## 🧪 **Test After Updating**

1. **Save the template** in EmailJS dashboard
2. **Go back to your app**
3. **Hot reload** (press `r` in terminal)
4. **Send test invitation**:
   - Drawer → Family / Shared
   - Invite Member
   - Enter your email
   - Send
5. **Check inbox** (or spam folder)

---

## 🎨 **Template Preview**

Your email will look like this:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You're invited 👋

John Doe has invited you to view their finances in the Budget App.

┌─────────────────────────────────────────────────────────────┐
│ What you can do:                                            │
│ ✓ View transactions                                         │
│ ✓ View budgets                                              │
│ ✓ View reports                                              │
│                                                             │
│ What you CANNOT do:                                         │
│ ✗ Edit or delete data                                       │
│ ✗ Change settings                                           │
└─────────────────────────────────────────────────────────────┘

            ┌─────────────────────────┐
            │  Accept Invitation      │
            └─────────────────────────┘

This is a read-only invitation for transparency and accountability.

If you didn't expect this invitation, you can safely ignore this email.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔍 **Common Mistakes to Avoid**

❌ **Don't do this**:
- Empty Content field
- Using `{from_name}` (single braces)
- Not setting "To Email" to `{{to_email}}`
- Forgetting to click "Save"

✅ **Do this**:
- Use `{{from_name}}` (double braces)
- Fill Content field with HTML
- Set "To Email" to `{{to_email}}`
- Click "Save" after editing

---

## 📸 **Screenshot Guide**

When editing your template, you should see:

```
┌─────────────────────────────────────────────────────────────┐
│ Template Name: template_juyopsl                             │
├─────────────────────────────────────────────────────────────┤
│ Subject: {{from_name}} invited you to view their finances   │
├─────────────────────────────────────────────────────────────┤
│ Content: [HTML code here]                                   │
├─────────────────────────────────────────────────────────────┤
│ Settings (Right Side):                                      │
│   To Email:    {{to_email}}                                 │
│   From Name:   Budget App                                   │
│   From Email:  [Use Default]                                │
│   Reply To:    {{to_email}}                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 🆘 **Still Getting Errors?**

### **Error: "Template parameter not found"**
- Make sure variable names match exactly
- Use double curly braces: `{{variable}}`
- Check for typos

### **Error: "Invalid email address"**
- Verify "To Email" is set to `{{to_email}}`
- Don't hardcode an email address

### **Error: "Template not found"**
- Verify Template ID: `template_juyopsl`
- Check if template is active (not deleted)

---

## 🎉 **After Fixing**

Once you update the template:

1. ✅ Emails will send successfully
2. ✅ Recipients will see beautiful HTML email
3. ✅ All variables will be replaced with real data
4. ✅ No more 400 errors

---

## 📝 **Quick Copy-Paste Checklist**

```
☐ Go to https://dashboard.emailjs.com/
☐ Click "Email Templates"
☐ Click template_juyopsl
☐ Click "Edit"
☐ Paste Subject: {{from_name}} invited you to view their finances
☐ Paste Content: [HTML from above]
☐ Set "To Email": {{to_email}}
☐ Set "From Name": Budget App
☐ Click "Save"
☐ Test in app
```

---

**Fix this now and your emails will work perfectly! 🚀**
