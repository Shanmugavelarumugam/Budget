# EmailJS Setup Guide for Family Invitations

## ✅ **Your EmailJS Credentials**

```
Service ID:  service_lqdp09g
Template ID: template_juyopsl
Public Key:  sN1rULjuL_V7DzPPj
```

These are already configured in the app! ✅

---

## 📧 **Email Template Setup**

To make sure your emails look good, configure your EmailJS template with these variables:

### **Template Variables** (use in EmailJS dashboard):

```
{{to_email}}         - Recipient's email
{{to_name}}          - Recipient's name
{{from_name}}        - Your name
{{from_email}}       - Your email
{{invitation_link}}  - Link to accept invitation
{{app_name}}         - "Budget App"
{{message}}          - Invitation message
```

### **Recommended Email Template** (HTML):

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
    .permissions { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
    .can-do { color: #22c55e; }
    .cannot-do { color: #ef4444; }
    .button { display: inline-block; background: #3b82f6; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; margin: 20px 0; }
    .footer { text-align: center; color: #6b7280; font-size: 12px; margin-top: 30px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>👨‍👩‍👧‍👦 Family Sharing Invitation</h1>
    </div>
    
    <div class="content">
      <p>Hi {{to_name}},</p>
      
      <p><strong>{{from_name}}</strong> ({{from_email}}) has invited you to view their financial data in <strong>{{app_name}}</strong>.</p>
      
      <div class="permissions">
        <h3>What you can do:</h3>
        <ul>
          <li class="can-do">✓ View transactions</li>
          <li class="can-do">✓ View budgets</li>
          <li class="can-do">✓ View reports</li>
        </ul>
        
        <h3>What you CANNOT do:</h3>
        <ul>
          <li class="cannot-do">✗ Edit or delete data</li>
          <li class="cannot-do">✗ Change settings</li>
          <li class="cannot-do">✗ Export data</li>
        </ul>
      </div>
      
      <p style="white-space: pre-line;">{{message}}</p>
      
      <center>
        <a href="{{invitation_link}}" class="button">Accept Invitation</a>
      </center>
      
      <div class="footer">
        <p>This is a read-only invitation for transparency and accountability.</p>
        <p>If you didn't expect this invitation, you can safely ignore this email.</p>
      </div>
    </div>
  </div>
</body>
</html>
```

---

## 🚀 **How to Update Your EmailJS Template**

1. Go to [EmailJS Dashboard](https://dashboard.emailjs.com/)
2. Click on **Email Templates**
3. Select your template: `template_juyopsl`
4. Click **Edit**
5. Paste the HTML above
6. Click **Save**

---

## 🧪 **Testing**

### **Test in the App**:

1. Open app → Drawer → "Family / Shared"
2. Tap "Invite Member"
3. Enter **your own email** (for testing)
4. Tap "Send Invitation"
5. Check your inbox! 📬

### **Expected Result**:

You should receive an email with:
- ✅ Your name as sender
- ✅ Beautiful HTML formatting
- ✅ Clear permissions list
- ✅ "Accept Invitation" button

---

## 🔧 **Troubleshooting**

### **Email not received?**

1. **Check spam folder** 📂
2. **Verify EmailJS credentials** in `emailjs_service.dart`
3. **Check EmailJS dashboard** for send logs
4. **Verify template variables** match exactly

### **Error: "Failed to send email"**

1. Check internet connection
2. Verify EmailJS account is active
3. Check EmailJS free tier limits (200 emails/month)
4. Look at console logs for detailed error

### **Template variables not showing?**

Make sure variable names match exactly:
- `{{to_email}}` not `{{toEmail}}`
- `{{from_name}}` not `{{fromName}}`

---

## 📊 **EmailJS Free Tier Limits**

- ✅ **200 emails/month** (perfect for testing)
- ✅ **No credit card required**
- ✅ **No backend needed**
- ✅ **Works from Flutter directly**

For production, consider upgrading to:
- **Personal Plan**: $7/month (1,000 emails)
- **Professional Plan**: $15/month (5,000 emails)

---

## 🎯 **What Happens Now**

When you send an invitation:

1. **App validates** email format ✅
2. **EmailJS sends** real email 📧
3. **Recipient receives** invitation ✉️
4. **Success message** shows in app ✅

**Note**: The invitation link (`https://yourapp.com/accept-invitation`) is a placeholder. You'll need to implement the acceptance flow later.

---

## 🔒 **Security Notes**

✅ **Public Key is safe** to expose in Flutter app
✅ **No API secrets** in client code
✅ **EmailJS handles** rate limiting
✅ **CORS enabled** by default

---

## 📝 **Next Steps**

1. ✅ Update EmailJS template (see HTML above)
2. ✅ Test with your own email
3. ✅ Verify email looks good
4. 🔜 Implement invitation acceptance flow
5. 🔜 Store invitations in Firestore
6. 🔜 Add invitation expiry (7 days)

---

**You're all set! Real emails will now be sent when you invite family members! 🎉**
