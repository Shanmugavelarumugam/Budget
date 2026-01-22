import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../budget/domain/entities/category_entity.dart';
import '../providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/utils/digit_normalizer.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionEntity? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late TransactionType _selectedType;
  late CategoryEntity _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _amountController = TextEditingController(
      text: t != null ? t.amount.toString() : '',
    );
    _selectedType = t?.type ?? TransactionType.expense;

    // Find category object by name if editing, else default
    if (t != null) {
      try {
        _selectedCategory = CategoryEntity.defaults.firstWhere(
          (c) => c.id == t.category || c.name == t.category,
          orElse: () => CategoryEntity.defaults.first,
        );
      } catch (_) {
        _selectedCategory = CategoryEntity.defaults.first;
      }
      _selectedDate = t.date;
    } else {
      _selectedCategory = CategoryEntity.defaults.first;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    final amountText = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must be logged in')));
      return;
    }

    setState(() => _isLoading = true);

    final transaction = TransactionEntity(
      id: widget.transaction?.id ?? const Uuid().v4(),
      userId: user.uid,
      amount: amount,
      type: _selectedType,
      category: _selectedCategory.id, // Use ID, not Name, consistent with usage
      date: _selectedDate,
      description: description.isNotEmpty ? description : null,
    );

    try {
      if (widget.transaction != null) {
        await Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).updateTransaction(transaction);
      } else {
        await Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).addTransaction(transaction);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9); // Light used F1F5F9 here
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kInputFill = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Type Toggle
            Container(
              decoration: BoxDecoration(
                color: kAccentSlate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Expense',
                      isSelected: _selectedType == TransactionType.expense,
                      onTap: () => setState(
                        () => _selectedType = TransactionType.expense,
                      ),
                      kPrimarySlate: kPrimarySlate,
                      kSecondarySlate: kSecondarySlate,
                      kCardBackground: kCardBackground,
                      isDark: isDark,
                    ),
                  ),
                  Expanded(
                    child: _TypeButton(
                      label: 'Income',
                      isSelected: _selectedType == TransactionType.income,
                      onTap: () => setState(
                        () => _selectedType = TransactionType.income,
                      ),
                      kPrimarySlate: kPrimarySlate,
                      kSecondarySlate: kSecondarySlate,
                      kCardBackground: kCardBackground,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Amount Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AMOUNT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kSecondarySlate,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: kPrimarySlate,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kPrimarySlate,
                    ),
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: kSecondarySlate.withValues(alpha: 0.3),
                    ),
                  ),
                  inputFormatters: [DigitNormalizer()],
                ),
              ],
            ),
            Divider(height: 1, color: kBorderSlate),
            const SizedBox(height: 32),

            // Category & Date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATEGORY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kSecondarySlate,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _showCategoryPicker(
                          context,
                          kAppBackground,
                          kPrimarySlate,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: kBorderSlate),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _selectedCategory.color
                                    .withValues(alpha: 0.1),
                                radius: 16,
                                child: Icon(
                                  _selectedCategory.icon,
                                  size: 16,
                                  color: _selectedCategory.color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedCategory.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: kPrimarySlate,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: kSecondarySlate,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DATE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kSecondarySlate,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => AppDatePicker(
                              initialDate: _selectedDate,
                              minDate: DateTime(2000),
                              maxDate: DateTime(2100),
                              onDateSelected: (date) {
                                setState(() => _selectedDate = date);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: kBorderSlate),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: kSecondarySlate,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d, y').format(_selectedDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: kPrimarySlate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kSecondarySlate,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: kPrimarySlate),
                  decoration: InputDecoration(
                    hintText: 'What was this for?',
                    hintStyle: TextStyle(
                      color: kSecondarySlate.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: kInputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimarySlate, // Determines button color
                  foregroundColor: kPrimarySlate == Colors.white
                      ? Colors.black
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: kPrimarySlate == Colors.white
                              ? Colors.black
                              : Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    Color kAppBackground,
    Color kPrimarySlate,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kAppBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimarySlate,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: CategoryEntity.defaults.length,
                  itemBuilder: (context, index) {
                    final category = CategoryEntity.defaults[index];
                    final isSelected = category.id == _selectedCategory.id;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCategory = category);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? category.color
                                  : category.color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category.icon,
                              color: isSelected ? Colors.white : category.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: kPrimarySlate,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color kPrimarySlate;
  final Color kSecondarySlate;
  final Color kCardBackground;
  final bool isDark;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.kPrimarySlate,
    required this.kSecondarySlate,
    required this.kCardBackground,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // High contrast for the selected state
    // Dark mode: White background with Black text
    // Light mode: Dark Slate background with White text
    final selectedBg = kPrimarySlate;
    final selectedText = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: selectedBg)
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isSelected ? selectedText : kSecondarySlate,
          ),
        ),
      ),
    );
  }
}
