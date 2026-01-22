import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/email_service.dart';

class InviteMemberScreen extends StatefulWidget {
  const InviteMemberScreen({super.key});

  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final inviteeEmail = _emailController.text.trim();

      // 1. Save invitation in Firestore
      final invitationRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('shared_members')
          .add({
            'email': inviteeEmail,
            'status': 'pending',
            'invitedAt': FieldValue.serverTimestamp(),
            'invitedBy': user.uid,
          });

      // 2. Send real email via EmailJS
      await EmailService().sendInvitation(
        toEmail: inviteeEmail,
        fromName: user.displayName ?? user.email ?? 'Budget App User',
        invitationId: invitationRef.id,
      );

      if (!mounted) return;

      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Invitation sent to $inviteeEmail'),
          backgroundColor: const Color(0xFF22C55E),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to send invitation: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final kAccentBlue = const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Invite Member',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kAccentBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 48,
                    color: kAccentBlue,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Share Your Finances',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimarySlate,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Invite someone to view your financial data',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: kSecondarySlate,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Email Input
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorderSlate),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kSecondarySlate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 16,
                        color: kPrimarySlate,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'member@example.com',
                        hintStyle: TextStyle(
                          color: kSecondarySlate.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kAccentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kAccentBlue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: kAccentBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'What they can do',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kAccentBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionRow(
                      '✓',
                      'View transactions',
                      kAccentBlue,
                      kPrimarySlate,
                    ),
                    _buildPermissionRow(
                      '✓',
                      'View budgets',
                      kAccentBlue,
                      kPrimarySlate,
                    ),
                    _buildPermissionRow(
                      '✓',
                      'View reports',
                      kAccentBlue,
                      kPrimarySlate,
                    ),
                    const SizedBox(height: 8),
                    _buildPermissionRow(
                      '✗',
                      'Edit or delete data',
                      Colors.red,
                      kSecondarySlate,
                    ),
                    _buildPermissionRow(
                      '✗',
                      'Change settings',
                      Colors.red,
                      kSecondarySlate,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Send Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendInvitation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimarySlate,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send Invitation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: kSecondarySlate)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRow(
    String icon,
    String text,
    Color iconColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: textColor)),
        ],
      ),
    );
  }
}
