import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

enum ExportDateRange { thisMonth, allTime }

enum ExportType { all, expense, income }

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  ExportDateRange _selectedDateRange = ExportDateRange.thisMonth;
  ExportType _selectedType = ExportType.all;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isGuest = user?.isGuest ?? true;

    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const kPrimaryPurple = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Export Data',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: kAppBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: kPrimarySlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Export Data",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: kPrimarySlate,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Download your financial data as a CSV file to analyze in Excel, Google Sheets, or keep as a backup.",
              style: TextStyle(
                color: kSecondarySlate,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (isGuest)
              _buildGuestLockMessage(
                context,
                kAccentSlate,
                kSecondarySlate,
                kPrimarySlate,
                kBorderSlate,
              )
            else
              _buildExportOptions(
                context,
                kPrimarySlate,
                kSecondarySlate,
                kAccentSlate,
                kBorderSlate,
                kPrimaryPurple,
                kCardBackground,
                isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestLockMessage(
    BuildContext context,
    Color kAccentSlate,
    Color kSecondarySlate,
    Color kPrimarySlate,
    Color kBorderSlate,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kAccentSlate,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSlate),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimarySlate == Colors.white
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 32,
              color: kSecondarySlate,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Export Locked",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimarySlate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create an account to export your data and ensure you never lose your transactions.",
            textAlign: TextAlign.center,
            style: TextStyle(color: kSecondarySlate, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/welcome', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimarySlate,
                foregroundColor: kPrimarySlate == Colors.white
                    ? Colors
                          .black // Dark mode -> Button is White, Text is Black
                    : Colors
                          .white, // Light mode -> Button is Dark, Text is White
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Create Account",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions(
    BuildContext context,
    Color kPrimarySlate,
    Color kSecondarySlate,
    Color kAccentSlate,
    Color kBorderSlate,
    Color kPrimaryPurple,
    Color kCardBackground,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Selection
        Text(
          "DATE RANGE",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: kSecondarySlate,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: kAccentSlate,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderSlate),
          ),
          child: Row(
            children: [
              _buildDateOption(
                "This Month",
                ExportDateRange.thisMonth,
                kPrimarySlate,
                kSecondarySlate,
                kCardBackground,
              ),
              _buildDateOption(
                "All Time",
                ExportDateRange.allTime,
                kPrimarySlate,
                kSecondarySlate,
                kCardBackground,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Type Selection
        Text(
          "TRANSACTION TYPE",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: kSecondarySlate,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTypeChip(
              "All",
              ExportType.all,
              kPrimaryPurple,
              kSecondarySlate,
              kCardBackground,
              kBorderSlate,
            ),
            _buildTypeChip(
              "Expenses",
              ExportType.expense,
              kPrimaryPurple,
              kSecondarySlate,
              kCardBackground,
              kBorderSlate,
            ),
            _buildTypeChip(
              "Income",
              ExportType.income,
              kPrimaryPurple,
              kSecondarySlate,
              kCardBackground,
              kBorderSlate,
            ),
          ],
        ),

        const SizedBox(height: 48),

        // Export Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isExporting ? null : () => _handleExport(),
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded),
            label: Text(_isExporting ? "Exporting..." : "Export to CSV"),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOption(
    String title,
    ExportDateRange value,
    Color activeColor,
    Color inactiveColor,
    Color activeBg,
  ) {
    final isSelected = _selectedDateRange == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDateRange = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    String title,
    ExportType value,
    Color activeColor,
    Color inactiveColor,
    Color bg,
    Color borderColor,
  ) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) setState(() => _selectedType = value);
      },
      backgroundColor: bg,
      selectedColor: activeColor.withValues(alpha: 0.1),
      checkmarkColor: activeColor,
      labelStyle: TextStyle(
        color: isSelected ? activeColor : inactiveColor,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? activeColor : borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);

    try {
      if (!mounted) return;

      final provider = context.read<TransactionProvider>();
      List<TransactionEntity> transactions = provider.transactions;

      // Filter by Date
      if (_selectedDateRange == ExportDateRange.thisMonth) {
        final now = DateTime.now();
        transactions = transactions.where((t) {
          return t.date.year == now.year && t.date.month == now.month;
        }).toList();
      }

      // Filter by Type
      if (_selectedType == ExportType.expense) {
        transactions = transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
      } else if (_selectedType == ExportType.income) {
        transactions = transactions
            .where((t) => t.type == TransactionType.income)
            .toList();
      }

      // Generate CSV String
      const header = 'Date,Type,Category,Amount,Notes\n';
      final rows = transactions
          .map((t) {
            final date = DateFormat('yyyy-MM-dd').format(t.date);
            final type = t.type == TransactionType.expense
                ? 'Expense'
                : 'Income';
            final category = t.category.replaceAll(',', ' '); // Simple escape
            final amount = t.amount.toString();
            final notes = (t.description ?? '').replaceAll(
              ',',
              ' ',
            ); // Simple escape

            return '$date,$type,$category,$amount,$notes';
          })
          .join('\n');

      final csvData = header + rows;

      // Save to Temp File
      final directory = await getTemporaryDirectory();
      final path =
          "${directory.path}/budgets_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      // Share
      if (mounted) {
        // ignore: deprecated_member_use
        await Share.shareXFiles([
          XFile(path),
        ], text: 'Here is my transaction data export from Budgets.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
