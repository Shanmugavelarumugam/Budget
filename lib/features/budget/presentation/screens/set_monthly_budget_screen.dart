import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/utils/digit_normalizer.dart';
import '../providers/budget_provider.dart';

/// Screen for setting or editing the monthly budget amount
class SetMonthlyBudgetScreen extends StatefulWidget {
  const SetMonthlyBudgetScreen({super.key});

  @override
  State<SetMonthlyBudgetScreen> createState() => _SetMonthlyBudgetScreenState();
}

class _SetMonthlyBudgetScreenState extends State<SetMonthlyBudgetScreen> {
  final _amountController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider = context.read<BudgetProvider>();
      if (budgetProvider.currentBudget != null) {
        _amountController.text = budgetProvider.currentBudget!.amount
            .toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<BudgetProvider>().setBudget(amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Budget updated successfully'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF0F172A),
          ),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving budget: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currencyCode;
    }
  }

  Widget _buildMonthHeader(String monthName, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Column(
      children: [
        Text(
          monthName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kPrimarySlate,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your spending limit',
          style: TextStyle(fontSize: 14, color: kSecondarySlate),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final currencyCode = settings.currency;
    final currencySymbol = _getCurrencySymbol(currencyCode);

    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    // Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: kAppBackground,
        elevation: 0,
        title: Text(
          'Set Monthly Budget',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthHeader(monthName, context),
            const SizedBox(height: 40),
            Text(
              'What is your spending limit?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kSecondarySlate,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: kPrimarySlate,
              ),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: currencySymbol,
                prefixStyle: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: kPrimarySlate,
                ),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: kSecondarySlate.withValues(alpha: 0.3),
                ),
              ),
              inputFormatters: [DigitNormalizer()],
            ),
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimarySlate,
                  foregroundColor: kPrimarySlate == Colors.white
                      ? Colors.black
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Limit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (budgetProvider.currentBudget != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: kSecondarySlate),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
