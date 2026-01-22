import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/utils/digit_normalizer.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/budget_provider.dart';

/// Screen for setting budget limits for individual categories
class SetCategoryBudgetScreen extends StatefulWidget {
  const SetCategoryBudgetScreen({super.key});

  @override
  State<SetCategoryBudgetScreen> createState() =>
      _SetCategoryBudgetScreenState();
}

class _SetCategoryBudgetScreenState extends State<SetCategoryBudgetScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider = context.read<BudgetProvider>();

      // Initialize controllers for all categories
      for (var category in CategoryEntity.defaults) {
        final controller = TextEditingController();
        final existingBudget = budgetProvider.getCategoryBudget(category.id);
        if (existingBudget != null) {
          controller.text = existingBudget.amount.toStringAsFixed(0);
        }
        _controllers[category.id] = controller;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
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

  double _getTotalCategoryBudgets() {
    double total = 0.0;
    for (var controller in _controllers.values) {
      final text = controller.text.replaceAll(',', '');
      final amount = double.tryParse(text) ?? 0.0;
      total += amount;
    }
    return total;
  }

  Future<void> _saveCategoryBudgets() async {
    final budgetProvider = context.read<BudgetProvider>();
    final monthlyBudget = budgetProvider.currentBudget?.amount ?? 0.0;

    // Build category budgets map
    final Map<String, double> categoryBudgets = {};
    for (var entry in _controllers.entries) {
      final text = entry.value.text.replaceAll(',', '');
      final amount = double.tryParse(text) ?? 0.0;

      // Only save non-zero budgets
      if (amount > 0) {
        // Validate: category budget should not exceed monthly budget
        if (amount > monthlyBudget) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${CategoryEntity.getById(entry.key).name} budget exceeds monthly budget',
              ),
            ),
          );
          return;
        }
        categoryBudgets[entry.key] = amount;
      }
    }

    // Check if total exceeds monthly budget (warning, not blocking)
    final total = _getTotalCategoryBudgets();
    if (total > monthlyBudget) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
      final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
      final kSecondarySlate = isDark
          ? const Color(0xFF94A3B8)
          : const Color(0xFF64748B);
      const kBorderSlate = Color(0xFFE2E8F0);
      const kWarningOrange = Color(0xFFF59E0B);

      final shouldContinue = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? kBorderSlate.withValues(alpha: 0.3)
                      : kBorderSlate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWarningOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 40,
                  color: kWarningOrange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Budget Warning",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kPrimarySlate,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Total category budgets (${_getCurrencySymbol(context.read<SettingsProvider>().currency)}${total.toStringAsFixed(0)}) '
                'exceed your monthly budget (${_getCurrencySymbol(context.read<SettingsProvider>().currency)}${monthlyBudget.toStringAsFixed(0)}).\n\n'
                'Do you want to continue?',
                style: TextStyle(
                  fontSize: 15,
                  color: kSecondarySlate,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimarySlate,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Continue Anyway",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Go Back",
                  style: TextStyle(
                    fontSize: 16,
                    color: kSecondarySlate,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );

      if (shouldContinue != true) return;
    }

    setState(() => _isSaving = true);

    try {
      await budgetProvider.setCategoryBudgets(categoryBudgets);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Category budgets saved successfully'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF0F172A),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving budgets: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final currencySymbol = _getCurrencySymbol(settings.currency);

    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final monthlyBudget = budgetProvider.currentBudget?.amount ?? 0.0;

    // Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    final total = _getTotalCategoryBudgets();
    final isOverBudget = total > monthlyBudget;

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: kAppBackground,
        elevation: 0,
        title: Text(
          'Category Budgets',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
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
                  'Set spending limits for each category',
                  style: TextStyle(fontSize: 14, color: kSecondarySlate),
                ),
                const SizedBox(height: 16),

                // Monthly budget info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderSlate),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Budget',
                        style: TextStyle(
                          color: kSecondarySlate,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$currencySymbol${monthlyBudget.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: kPrimarySlate,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Total category budgets
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                        : kCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOverBudget
                          ? const Color(0xFFEF4444)
                          : kBorderSlate,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isOverBudget)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFEF4444),
                                size: 20,
                              ),
                            ),
                          Text(
                            'Total Categories',
                            style: TextStyle(
                              color: isOverBudget
                                  ? const Color(0xFFEF4444)
                                  : kSecondarySlate,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$currencySymbol${total.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isOverBudget
                              ? const Color(0xFFEF4444)
                              : kPrimarySlate,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: CategoryEntity.defaults.length,
              itemBuilder: (context, index) {
                final category = CategoryEntity.defaults[index];
                final controller = _controllers[category.id];

                if (controller == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kCardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorderSlate),
                    ),
                    child: Row(
                      children: [
                        // Category icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Category name
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kPrimarySlate,
                            ),
                          ),
                        ),

                        // Amount input
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kPrimarySlate,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              prefixText: currencySymbol,
                              prefixStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kSecondarySlate,
                              ),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: kSecondarySlate.withValues(alpha: 0.3),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            inputFormatters: [DigitNormalizer()],
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          // Save button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCategoryBudgets,
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
                        'Save Category Budgets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          // Safe area spacing
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
