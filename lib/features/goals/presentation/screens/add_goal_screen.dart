import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/goal_provider.dart';
import '../../domain/entities/goal_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/utils/digit_normalizer.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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

    final settings = context.read<SettingsProvider>();
    final currencySymbol = _getCurrencySymbol(settings.currency);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        title: Text(
          'New Goal',
          style: TextStyle(color: kPrimarySlate, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kAppBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: kPrimarySlate),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Amount Input (Hero Style)
                      Text(
                        "Target Amount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kSecondarySlate,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kPrimarySlate,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixText: currencySymbol,
                          prefixStyle: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: kPrimarySlate,
                          ),
                          hintStyle: TextStyle(
                            color: kSecondarySlate.withValues(alpha: 0.3),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        inputFormatters: [DigitNormalizer()],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 48),

                      // 2. Goal Name
                      _buildInputLabel("GOAL NAME", kSecondarySlate),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          color: kPrimarySlate,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _buildInputDecoration(
                          hint: "e.g. Dream Vacation",
                          icon: Icons.flag_rounded,
                          isDark: isDark,
                          borderColor: kBorderSlate,
                          fillColor: kCardBackground,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Name is required' : null,
                      ),

                      const SizedBox(height: 24),

                      // 3. Target Date - UNIQUE CUSTOM DESIGN
                      _buildInputLabel(
                        "TARGET DATE (OPTIONAL)",
                        kSecondarySlate,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final now = DateTime.now();
                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => AppDatePicker(
                              initialDate:
                                  _targetDate ??
                                  now.add(const Duration(days: 30)),
                              minDate: now,
                              maxDate: now.add(const Duration(days: 365 * 50)),
                              onDateSelected: (date) {
                                setState(() => _targetDate = date);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: kCardBackground,
                            border: Border.all(color: kBorderSlate),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: kPrimarySlate,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "When do you need this?",
                                    style: TextStyle(
                                      color: kSecondarySlate,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _targetDate == null
                                        ? "Select Target Date"
                                        : DateFormat(
                                            "MMMM d, y",
                                          ).format(_targetDate!),
                                    style: TextStyle(
                                      color: kPrimarySlate,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (_targetDate != null)
                                InkWell(
                                  onTap: () =>
                                      setState(() => _targetDate = null),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.close,
                                      size: 20,
                                      color: kSecondarySlate,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: kSecondarySlate.withValues(alpha: 0.5),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 4. Description
                      _buildInputLabel("DESCRIPTION", kSecondarySlate),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: TextStyle(
                          color: kPrimarySlate,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _buildInputDecoration(
                          hint: "Add motivation...",
                          icon: null,
                          isDark: isDark,
                          borderColor: kBorderSlate,
                          fillColor: kCardBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimarySlate,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Create Goal",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData? icon,
    required bool isDark,
    required Color borderColor,
    required Color fillColor,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: isDark ? Colors.white54 : Colors.black45)
          : null,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.white : Colors.black,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user;
      final userId = user?.uid ?? 'guest';

      final goal = GoalEntity(
        id: '', // Generated by provider
        userId: userId,
        name: _nameController.text.trim(),
        targetAmount: double.parse(_amountController.text),
        targetDate: _targetDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      await context.read<GoalProvider>().addGoal(goal);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error creating goal: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        return '₹';
    }
  }
}

// ---------------------------------------------------------------------------
// MODERN CUSTOM CALENDAR (Premium Design with Month/Year Pickers & Manual Input)
// ---------------------------------------------------------------------------
