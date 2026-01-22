import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class FamilyHomeScreen extends StatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {
  bool _sharingEnabled = false;
  final List<Map<String, dynamic>> _invitedMembers = [
    {'email': 'spouse@example.com', 'status': 'Accepted'},
    {'email': 'child@example.com', 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isGuest = authProvider.status == AuthStatus.guest;
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
    final kAccentGreen = const Color(0xFF22C55E);
    final kAccentBlue = const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Family / Shared',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: isGuest
          ? _buildGuestView(kPrimarySlate, kSecondarySlate)
          : _buildOwnerView(
              kAppBackground,
              kPrimarySlate,
              kSecondarySlate,
              kCardBackground,
              kBorderSlate,
              kAccentGreen,
              kAccentBlue,
              isDark,
            ),
    );
  }

  Widget _buildGuestView(Color kPrimary, Color kSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom_rounded, size: 64, color: kSecondary),
            const SizedBox(height: 24),
            Text(
              'Account Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create an account to share or view shared financial data.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: kSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerView(
    Color kAppBg,
    Color kPrimary,
    Color kSecondary,
    Color kCardBg,
    Color kBorder,
    Color kGreen,
    Color kBlue,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sharing Toggle Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_sharingEnabled ? kGreen : kSecondary).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _sharingEnabled
                        ? Icons.share_rounded
                        : Icons.share_outlined,
                    color: _sharingEnabled ? kGreen : kSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sharing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _sharingEnabled ? 'Active' : 'Disabled',
                        style: TextStyle(fontSize: 14, color: kSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _sharingEnabled,
                  onChanged: (value) {
                    setState(() => _sharingEnabled = value);
                  },
                  activeTrackColor: kGreen,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invited Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
              Text(
                '${_invitedMembers.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Members List
          if (_invitedMembers.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: kSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No members yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invite someone to view your finances',
                      style: TextStyle(fontSize: 14, color: kSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._invitedMembers.map((member) {
              final isPending = member['status'] == 'Pending';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: kBlue.withValues(alpha: 0.1),
                        child: Icon(Icons.person_outline_rounded, color: kBlue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['email'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isPending ? kSecondary : kGreen)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isPending ? kSecondary : kGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: kSecondary),
                        onPressed: () => _removeMember(member['email']),
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),

          // Invite Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/invite-member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text(
                'Invite Member',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: kBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Invited members can view your data but cannot edit anything.',
                    style: TextStyle(fontSize: 13, color: kBlue, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _removeMember(String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove $email from shared access?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _invitedMembers.removeWhere((m) => m['email'] == email);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
