import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/alert_model.dart';
import '../../../../routes/route_names.dart';
import '../../../dashboard/presentation/widgets/blurred_blob.dart';

class AlertDetailsScreen extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailsScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    final typeColor = _getTypeColor(alert.type);
    final typeIcon = _getTypeIcon(alert.type);

    return Scaffold(
      backgroundColor: kAppBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Detail View',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -50,
            left: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                  : const Color(0xFFEFF6FF),
              size: 400,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: BlurredBlob(
              color: isDark
                  ? const Color(0xFF581C87).withValues(alpha: 0.2)
                  : const Color(0xFFF5F3FF),
              size: 350,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Content Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: kBorderSlate.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon & Type
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: typeColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Icon(typeIcon, color: typeColor, size: 32),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTypeLabel(alert.type).toUpperCase(),
                                  style: TextStyle(
                                    color: typeColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM d, yyyy • h:mm a',
                                  ).format(alert.timestamp),
                                  style: TextStyle(
                                    color: kSecondarySlate,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        Text(
                          alert.title,
                          style: TextStyle(
                            color: kPrimarySlate,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          alert.description,
                          style: TextStyle(
                            color: kSecondarySlate,
                            fontSize: 17,
                            height: 1.7,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Call to Action
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            onPressed: () => _handleAction(context, alert),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimarySlate,
                              foregroundColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getActionText(alert),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Back to List",
                              style: TextStyle(
                                color: kSecondarySlate,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Helper Tip Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: typeColor,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Pro tip: You can adjust alert thresholds in Notification Settings.",
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        return "Attention";
      case AlertType.success:
        return "Congratulations";
    }
  }

  String _getActionText(AlertModel alert) {
    if (alert.title.contains('Budget')) return "View Budget Manager";
    if (alert.title.contains('Summary')) return "Analyze Report";
    if (alert.title.contains('Savings')) return "View My Goals";
    return "Check Related Data";
  }

  void _handleAction(BuildContext context, AlertModel alert) {
    if (alert.title.contains('Budget')) {
      Navigator.pushNamed(context, RouteNames.budgetOverview);
    } else if (alert.title.contains('Summary')) {
      Navigator.pushNamed(context, RouteNames.reports);
    } else if (alert.title.contains('Savings')) {
      Navigator.pushNamed(context, RouteNames.goals);
    } else {
      Navigator.pop(context);
    }
  }
}
