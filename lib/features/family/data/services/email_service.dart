import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Email service using Resend.com
/// Free tier: 100 emails/day, 3,000/month
/// Works on all platforms (Android, iOS, Web)
class EmailService {
  // Resend API key - Free tier: 100 emails/day, 3,000/month
  static const String _resendApiKey = 're_AHK6fP6u_PGwvbTbimbSWDdASqkRxTqos';
  static const String _resendUrl = 'https://api.resend.com/emails';
  static const String _fromEmail =
      'onboarding@resend.dev'; // Use this for testing
  static const String _fromName = 'Budget App';

  // ⚠️ DEVELOPMENT MODE: Resend only allows sending to verified email
  // Until you verify a domain, all emails will be sent to this address
  static const bool _isDevelopmentMode = true;
  static const String _verifiedEmail = 'ashanmugavel821@gmail.com';

  /// Send invitation email to a family member
  Future<void> sendInvitation({
    required String toEmail,
    required String fromName,
    required String invitationId,
  }) async {
    try {
      final inviteLink = 'https://yourapp.com/invite/$invitationId';

      // In development mode, send to verified email only
      final actualToEmail = _isDevelopmentMode ? _verifiedEmail : toEmail;

      if (_isDevelopmentMode && toEmail != _verifiedEmail) {
        debugPrint(
          '⚠️ DEVELOPMENT MODE: Sending to $actualToEmail instead of $toEmail',
        );
        debugPrint(
          '💡 To send to any email, verify a domain at resend.com/domains',
        );
      }

      debugPrint('📧 Sending email via Resend to: $actualToEmail');

      final response = await http.post(
        Uri.parse(_resendUrl),
        headers: {
          'Authorization': 'Bearer $_resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': '$_fromName <$_fromEmail>',
          'to': [actualToEmail],
          'subject': '$fromName invited you to view their finances',
          'html':
              '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .content { background: #f9fafb; padding: 30px; }
    .permissions { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
    .can-do { color: #22c55e; }
    .cannot-do { color: #ef4444; }
    .button { display: inline-block; background: #3b82f6; color: white; padding: 14px 28px; text-decoration: none; border-radius: 8px; margin: 20px 0; font-weight: bold; }
    .footer { text-align: center; color: #6b7280; font-size: 12px; margin-top: 30px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>👨‍👩‍👧‍👦 Family Sharing Invitation</h1>
  </div>
  
  <div class="content">
    <p>Hi there,</p>
    
    <p><strong>$fromName</strong> has invited you to view their financial data in <strong>Budget App</strong>.</p>
    
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
      </ul>
    </div>
    
    <center>
      <a href="$inviteLink" class="button">Accept Invitation</a>
    </center>
    
    <div class="footer">
      <p>This is a read-only invitation for transparency and accountability.</p>
      <p>If you didn't expect this invitation, you can safely ignore this email.</p>
    </div>
  </div>
</body>
</html>
          ''',
        }),
      );

      debugPrint('📊 Resend response status: ${response.statusCode}');
      debugPrint('📊 Resend response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Email sent successfully via Resend!');
      } else {
        throw Exception(
          'Resend failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending email: $e');
      rethrow;
    }
  }
}
