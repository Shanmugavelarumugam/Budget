# Email Invitation Implementation Guide

## 🎯 **Current Status**

The Family/Shared feature UI is complete, but **email invitations are NOT being sent**. The current implementation only:
- ✅ Validates email format
- ✅ Shows loading state
- ✅ Displays success message
- ❌ **Does NOT send actual emails**

---

## 📧 **How to Implement Real Email Invitations**

You have **3 options** to choose from:

---

### **Option 1: Firebase Email Extension** (⭐ Recommended - Easiest)

**Pros**:
- No backend code needed
- Automatic email sending
- Secure (runs on Firebase servers)
- Free tier available

**Cons**:
- Requires Firebase Blaze plan (pay-as-you-go)
- Limited customization

#### **Setup Steps**:

1. **Install Firebase CLI** (if not already installed):
```bash
npm install -g firebase-tools
firebase login
```

2. **Initialize Firebase in your project**:
```bash
cd /Users/btc001a/Downloads/MyFolder/budgets
firebase init
```

3. **Install the Email Extension**:
```bash
firebase ext:install firebase/firestore-send-email
```

Follow the prompts:
- **SMTP Connection**: Use Gmail, SendGrid, or Mailgun
- **Email Collection**: `mail` (default)
- **Default FROM email**: `noreply@yourdomain.com`

4. **Update `_sendInvitation()` in `invite_member_screen.dart`**:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

Future<void> _sendInvitation() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSending = true);

  try {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;
    
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final firestore = FirebaseFirestore.instance;
    final inviteeEmail = _emailController.text.trim();

    // 1. Create invitation document in Firestore
    final invitationRef = await firestore
        .collection('users')
        .doc(currentUser.id)
        .collection('shared_members')
        .add({
      'email': inviteeEmail,
      'status': 'pending',
      'invitedAt': FieldValue.serverTimestamp(),
      'invitedBy': currentUser.id,
    });

    // 2. Trigger email via Firebase Extension
    await firestore.collection('mail').add({
      'to': [inviteeEmail],
      'message': {
        'subject': '${currentUser.displayName ?? "Someone"} invited you to view their finances',
        'html': '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>You've been invited to view shared finances</h2>
            <p>Hi there,</p>
            <p><strong>${currentUser.displayName ?? currentUser.email}</strong> has invited you to view their financial data in the Budget App.</p>
            
            <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3>What you can do:</h3>
              <ul>
                <li>✓ View transactions</li>
                <li>✓ View budgets</li>
                <li>✓ View reports</li>
              </ul>
              <h3>What you CANNOT do:</h3>
              <ul>
                <li>✗ Edit or delete data</li>
                <li>✗ Change settings</li>
              </ul>
            </div>

            <a href="https://yourapp.com/accept-invitation?id=${invitationRef.id}" 
               style="display: inline-block; background: #3B82F6; color: white; padding: 12px 24px; 
                      text-decoration: none; border-radius: 8px; margin: 20px 0;">
              Accept Invitation
            </a>

            <p style="color: #6b7280; font-size: 12px; margin-top: 30px;">
              This is a read-only invitation. You will not be able to modify any data.
            </p>
          </div>
        ''',
      },
    });

    if (mounted) {
      setState(() => _isSending = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation sent to $inviteeEmail'),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
      
      Navigator.pop(context, true);
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isSending = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send invitation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

5. **Add dependencies to `pubspec.yaml`**:
```yaml
dependencies:
  cloud_firestore: ^5.7.2
```

6. **Deploy Firestore rules** (already done in `firestore.rules`):
```bash
firebase deploy --only firestore:rules
```

---

### **Option 2: SendGrid API** (More Control)

**Pros**:
- More customization
- Better analytics
- No Firebase Blaze plan needed
- Free tier: 100 emails/day

**Cons**:
- Requires API key management
- More code to write

#### **Setup Steps**:

1. **Sign up for SendGrid**: https://sendgrid.com/
2. **Get API Key**: Settings → API Keys → Create API Key
3. **Add to `pubspec.yaml`**:
```yaml
dependencies:
  http: ^1.2.0
```

4. **Create SendGrid service**:

Create file: `lib/features/family/data/services/email_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _apiKey = 'YOUR_SENDGRID_API_KEY'; // Store securely!
  static const String _sendGridUrl = 'https://api.sendgrid.com/v3/mail/send';

  Future<bool> sendInvitationEmail({
    required String toEmail,
    required String fromName,
    required String invitationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendGridUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': toEmail}
              ],
              'subject': '$fromName invited you to view their finances',
            }
          ],
          'from': {
            'email': 'noreply@yourdomain.com',
            'name': 'Budget App'
          },
          'content': [
            {
              'type': 'text/html',
              'value': '''
                <h2>You've been invited!</h2>
                <p>$fromName has invited you to view their financial data.</p>
                <a href="https://yourapp.com/accept/$invitationId">Accept Invitation</a>
              '''
            }
          ]
        }),
      );

      return response.statusCode == 202;
    } catch (e) {
      print('Email send failed: $e');
      return false;
    }
  }
}
```

5. **Update `_sendInvitation()`**:
```dart
Future<void> _sendInvitation() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSending = true);

  try {
    final emailService = EmailService();
    final authProvider = context.read<AuthProvider>();
    
    final success = await emailService.sendInvitationEmail(
      toEmail: _emailController.text.trim(),
      fromName: authProvider.user?.displayName ?? 'A user',
      invitationId: 'unique-invitation-id', // Generate this
    );

    if (success) {
      // Show success
    } else {
      throw Exception('Email failed to send');
    }
  } catch (e) {
    // Show error
  } finally {
    setState(() => _isSending = false);
  }
}
```

---

### **Option 3: Cloud Functions** (Most Secure)

**Pros**:
- API keys hidden on server
- Most secure
- Can add complex logic

**Cons**:
- Requires backend knowledge
- Firebase Blaze plan needed

#### **Setup**:

1. **Initialize Cloud Functions**:
```bash
firebase init functions
```

2. **Create function** in `functions/index.js`:
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

exports.sendInvitationEmail = functions.firestore
  .document('users/{userId}/shared_members/{memberId}')
  .onCreate(async (snap, context) => {
    const invitation = snap.data();
    const userId = context.params.userId;
    
    // Get owner info
    const ownerDoc = await admin.firestore().collection('users').doc(userId).get();
    const owner = ownerDoc.data();
    
    // Configure email transport
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'your-email@gmail.com',
        pass: 'your-app-password'
      }
    });
    
    // Send email
    await transporter.sendMail({
      from: 'Budget App <noreply@budgetapp.com>',
      to: invitation.email,
      subject: `${owner.displayName} invited you to view their finances`,
      html: `
        <h2>You've been invited!</h2>
        <p>${owner.displayName} has invited you to view their financial data.</p>
        <a href="https://yourapp.com/accept/${snap.id}">Accept Invitation</a>
      `
    });
    
    return null;
  });
```

3. **Deploy**:
```bash
firebase deploy --only functions
```

---

## 🚀 **Quick Start (For Testing)**

If you just want to **test the flow** without real emails:

1. Keep the current simulation
2. Manually add test invitations to Firestore Console
3. Test the SharedReadonlyScreen with mock data

---

## 📋 **Recommended Approach**

For your app, I recommend:

1. **Start with Option 1** (Firebase Email Extension) - Easiest to set up
2. **Later migrate to Option 3** (Cloud Functions) - When you need more control
3. **Use Option 2** (SendGrid) - If you want to avoid Firebase Blaze plan

---

## ⚠️ **Important Security Notes**

1. **Never hardcode API keys** in your Flutter app
2. **Use environment variables** or Firebase Remote Config
3. **Validate emails server-side** (not just client-side)
4. **Rate limit invitations** (max 5 per day per user)
5. **Add invitation expiry** (7 days)

---

## 🧪 **Testing Without Real Emails**

For now, you can:
1. Use the current simulation
2. Test the UI flow
3. Manually create test invitations in Firestore
4. Implement email later when ready to deploy

---

## 📞 **Next Steps**

Choose one option and let me know which you'd like to implement. I can help you set it up!
