import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/alert_model.dart';
import '../../../../routes/route_names.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  final List<AlertModel> _alerts = [
    AlertModel(
      id: '1',
      title: 'Monthly Summary Ready',
      description: 'Your financial summary for September is ready for review.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: AlertType.info,
    ),
    AlertModel(
      id: '2',
      title: '80% of Food Budget Used',
      description: 'You have spent ₹4,000 of your ₹5,000 Food budget.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: AlertType.warning,
      isRead: true,
    ),
    AlertModel(
      id: '3',
      title: 'Budget Exceeded!',
      description: 'Shopping expenses have crossed the monthly limit.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: AlertType.critical,
    ),
    AlertModel(
      id: '4',
      title: 'Savings Milestone!',
      description: 'Congratulations! You saved 20% more than last month.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: AlertType.success,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Alerts & History',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: kSecondarySlate),
            onPressed: () {
              setState(() {
                for (var alert in _alerts) {
                  alert.isRead = true;
                }
              });
            },
            tooltip: 'Mark all as read',
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                  : const Color(0xFFEFF6FF),
              size: 400,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF581C87).withValues(alpha: 0.2)
                  : const Color(0xFFF5F3FF),
              size: 300,
            ),
          ),

          _alerts.isEmpty
              ? _buildEmptyState(kSecondarySlate)
              : ListView.builder(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 80,
                    bottom: 100,
                    left: 20,
                    right: 20,
                  ),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return _buildAlertCard(
                      alert,
                      isDark,
                      kPrimarySlate,
                      kSecondarySlate,
                      kAccentSlate,
                      kBorderSlate,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    AlertModel alert,
    bool isDark,
    Color kPrimary,
    Color kSecondary,
    Color kAccent,
    Color kBorder,
  ) {
    final typeColor = _getTypeColor(alert.type);
    final typeIcon = _getTypeIcon(alert.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder.withValues(alpha: 0.5), width: 1.5),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => alert.isRead = true);
            Navigator.pushNamed(
              context,
              RouteNames.alertDetails,
              arguments: alert,
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Holder
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getTypeLabel(alert.type).toUpperCase(),
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            _formatTimestamp(alert.timestamp),
                            style: TextStyle(
                              color: kSecondary.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.title,
                        style: TextStyle(
                          color: kPrimary,
                          fontWeight: alert.isRead
                              ? FontWeight.w700
                              : FontWeight.w900,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      if (!alert.isRead) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "NEW",
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color kSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: kSecondary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            "No alerts yet",
            style: TextStyle(
              color: kSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Important financial updates will appear here.",
            style: TextStyle(
              color: kSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(AlertType type) {
    switch (type) {
      case AlertType.info:
        return const Color(0xFF6366F1);
      case AlertType.warning:
        return const Color(0xFFF59E0B);
      case AlertType.critical:
        return const Color(0xFFEF4444);
      case AlertType.success:
        return const Color(0xFF10B981);
    }
  }

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.info:
        return Icons.info_outline_rounded;
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.critical:
        return Icons.error_outline_rounded;
      case AlertType.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _getTypeLabel(AlertType type) {
    switch (type) {
      case AlertType.info:
        return "Information";
      case AlertType.warning:
        return "Warning";
      case AlertType.critical:
        return "Critical Alert";
      case AlertType.success:
        return "Success";
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
