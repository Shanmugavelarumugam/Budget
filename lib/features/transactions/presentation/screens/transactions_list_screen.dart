import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../budget/domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'add_transaction_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  TransactionType? _filterType;
  String? _filterCategory; // Category ID or null

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
    if (nextMonth.isAfter(DateTime(now.year, now.month))) return;
    setState(() {
      _selectedDate = nextMonth;
    });
  }

  List<TransactionEntity> _getFilteredTransactions(
    List<TransactionEntity> allTransactions,
  ) {
    // 1. Filter by Month (This assumes standard calendar month,
    // but typically Transaction List might just show month view.
    // If strict adherence to "Start of Month" pref is needed here,
    // we'd need more complex logic. For 'History', calendar month is usually expected.)
    var filtered = allTransactions.where((t) {
      return t.date.year == _selectedDate.year &&
          t.date.month == _selectedDate.month;
    }).toList();

    // 2. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final noteMatch = t.description?.toLowerCase().contains(query) ?? false;
        final category = CategoryEntity.getById(t.category);
        final categoryMatch = category.name.toLowerCase().contains(query);
        return noteMatch || categoryMatch;
      }).toList();
    }

    // 3. Filter by Type
    if (_filterType != null) {
      filtered = filtered.where((t) {
        return t.type == _filterType;
      }).toList();
    }

    // 4. Filter by Category
    if (_filterCategory != null) {
      filtered = filtered.where((t) => t.category == _filterCategory).toList();
    }

    // 5. Sort Latest First
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  Map<String, List<TransactionEntity>> _groupTransactionsByDate(
    List<TransactionEntity> transactions,
  ) {
    final grouped = <String, List<TransactionEntity>>{};
    for (var t in transactions) {
      final key = _getDateKey(t.date);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(t);
    }
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) return 'Today';
    if (transactionDate == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // Dynamic Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kAppBackground = isDark ? const Color(0xFF0F172A) : Colors.white;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);
    final kBorderSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    const kPrimaryPurple = Color(0xFF8B5CF6);

    final currencySymbol = _getCurrencySymbol(settings.currency);

    final filteredTransactions = _getFilteredTransactions(
      provider.transactions,
    );
    final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: kCardBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Transactions',
          style: TextStyle(
            color: kPrimarySlate,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: kPrimarySlate),
            onPressed: () =>
                _showSearchModal(kAccentSlate, kPrimarySlate, kSecondarySlate),
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list_rounded, color: kPrimarySlate),
                if (_filterType != null || _filterCategory != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kPrimaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showFilterModal(
              kPrimarySlate,
              kSecondarySlate,
              kBorderSlate,
              kCardBackground,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kCardBackground,
              border: Border(bottom: BorderSide(color: kBorderSlate)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: kSecondarySlate),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: TextStyle(
                    color: kPrimarySlate,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: kSecondarySlate),
                  onPressed:
                      _selectedDate.month == DateTime.now().month &&
                          _selectedDate.year == DateTime.now().year
                      ? null
                      : _nextMonth,
                ),
              ],
            ),
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredTransactions.isEmpty
          ? _buildEmptyState(kPrimarySlate, kSecondarySlate, kAccentSlate)
          : _buildGroupedList(
              groupedTransactions,
              kSecondarySlate,
              kCardBackground,
              kPrimarySlate,
              kAccentSlate,
              kBorderSlate,
              currencySymbol,
            ),
      floatingActionButton: provider.transactions.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _onAddTransactionTap(context),
              backgroundColor:
                  kPrimarySlate, // Often brand color is better, but stick to design
              child: Icon(
                Icons.add_rounded,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
    );
  }

  void _onAddTransactionTap(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final isGuest = authProvider.user?.isGuest ?? false;

    if (isGuest && transactionProvider.transactions.length >= 3) {
      _showGuestLimitReachedModal(context);
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
    }
  }

  void _showGuestLimitReachedModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondarySlate = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kAccentSlate = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF8FAFC);
    const kBorderSlate = Color(0xFFE2E8F0);

    showModalBottomSheet(
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
                color: kBorderSlate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kAccentSlate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_person_rounded,
                size: 40,
                color: kPrimarySlate,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Access Limit Reached",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kPrimarySlate,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "You’ve added 3 transactions as a guest. Create a free account to continue tracking expenses and sync your data.",
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimarySlate,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Create Free Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
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
  }

  Widget _buildEmptyState(
    Color kPrimarySlate,
    Color kSecondarySlate,
    Color kAccentSlate,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kAccentSlate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: kSecondarySlate,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No transactions yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kPrimarySlate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to add your first income or expense.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: kSecondarySlate,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _onAddTransactionTap(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Transaction"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimarySlate,
                foregroundColor: kPrimarySlate == Colors.white
                    ? Colors.black
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(
    Map<String, List<TransactionEntity>> grouped,
    Color kSecondarySlate,
    Color kCardBackground,
    Color kPrimarySlate,
    Color kAccentSlate,
    Color kBorderSlate,
    String currencySymbol,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100), // Space for FAB
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final transactions = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                dateKey.toUpperCase(),
                style: TextStyle(
                  color: kSecondarySlate,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ...transactions.map(
              (t) => _TransactionItem(
                transaction: t,
                onTap: () => _showTransactionDetails(
                  t,
                  currencySymbol,
                  kCardBackground,
                  kPrimarySlate,
                  kSecondarySlate,
                  kAccentSlate,
                  kBorderSlate,
                ),
                kCardBackground: kCardBackground,
                kPrimarySlate: kPrimarySlate,
                kSecondarySlate: kSecondarySlate,
                kBorderSlate: kBorderSlate,
                currencySymbol: currencySymbol,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTransactionDetails(
    TransactionEntity transaction,
    String currencySymbol,
    Color kCardBackground,
    Color kPrimarySlate,
    Color kSecondarySlate,
    Color kAccentSlate,
    Color kBorderSlate,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: currencySymbol,
      decimalDigits: 0, // No decimals for Indian users
    );
    final category = CategoryEntity.getById(transaction.category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kBorderSlate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            // Amount
            Text(
              (transaction.isExpense ? '-' : '+') +
                  currencyFormat.format(transaction.amount),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: transaction.isExpense
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF22C55E),
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM d, yyyy • h:mm a').format(transaction.date),
              style: TextStyle(
                color: kSecondarySlate,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // Info Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kAccentSlate,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorderSlate),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    "Type",
                    transaction.type.name[0].toUpperCase() +
                        transaction.type.name.substring(1),
                    icon: transaction.isExpense
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    iconColor: transaction.isExpense
                        ? Colors.red
                        : Colors.green,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                    kBorderSlate: kBorderSlate,
                    kBoxColor: kCardBackground,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: kBorderSlate),
                  ),
                  _buildDetailRow(
                    "Category",
                    category.name,
                    icon: category.icon,
                    iconColor: kPrimarySlate,
                    kPrimarySlate: kPrimarySlate,
                    kSecondarySlate: kSecondarySlate,
                    kBorderSlate: kBorderSlate,
                    kBoxColor: kCardBackground,
                  ),
                  if (transaction.description != null &&
                      transaction.description!.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: kBorderSlate),
                    ),
                    _buildDetailRow(
                      "Note",
                      transaction.description!,
                      icon: Icons.notes_rounded,
                      iconColor: kSecondarySlate,
                      kPrimarySlate: kPrimarySlate,
                      kSecondarySlate: kSecondarySlate,
                      kBorderSlate: kBorderSlate,
                      kBoxColor: kCardBackground,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(transaction, kSecondarySlate);
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddTransactionScreen(transaction: transaction),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text("Edit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimarySlate,
                      foregroundColor: kPrimarySlate == Colors.white
                          ? Colors.black
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    required Color kPrimarySlate,
    required Color kSecondarySlate,
    required Color kBorderSlate,
    required Color kBoxColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBoxColor,
              shape: BoxShape.circle,
              border: Border.all(color: kBorderSlate),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          label,
          style: TextStyle(
            color: kSecondarySlate,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: kPrimarySlate,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    TransactionEntity transaction,
    Color kSecondarySlate,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kPrimarySlate = isDark ? Colors.white : const Color(0xFF0F172A);
    const kBorderSlate = Color(0xFFE2E8F0);
    const kErrorRed = Color(0xFFEF4444);

    showModalBottomSheet(
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
                color: kErrorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 40,
                color: kErrorRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Delete Transaction",
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
              "Are you sure you want to remove this transaction? This action cannot be undone and will affect your budget balance.",
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
                onPressed: () {
                  Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  ).deleteTransaction(transaction.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Transaction deleted")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorRed,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Delete Transaction",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
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
  }

  void _showFilterModal(
    Color kPrimarySlate,
    Color kSecondarySlate,
    Color kBorderSlate,
    Color kCardBackground,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: kCardBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? kBorderSlate.withValues(alpha: 0.3)
                            : kBorderSlate,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Filter Transactions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: kPrimarySlate,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "TYPE",
                    style: TextStyle(
                      color: kSecondarySlate,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip(
                        "All",
                        _filterType == null,
                        () => setModalState(() => _filterType = null),
                        kPrimarySlate,
                        kSecondarySlate,
                        kBorderSlate,
                        kCardBackground,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        "Income",
                        _filterType == TransactionType.income,
                        () => setModalState(
                          () => _filterType = TransactionType.income,
                        ),
                        kPrimarySlate,
                        kSecondarySlate,
                        kBorderSlate,
                        kCardBackground,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        "Expense",
                        _filterType == TransactionType.expense,
                        () => setModalState(
                          () => _filterType = TransactionType.expense,
                        ),
                        kPrimarySlate,
                        kSecondarySlate,
                        kBorderSlate,
                        kCardBackground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "CATEGORY",
                    style: TextStyle(
                      color: kSecondarySlate,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryEntity.defaults.map((c) {
                      return _buildFilterChip(
                        c.name,
                        _filterCategory == c.id,
                        () => setModalState(
                          () => _filterCategory = _filterCategory == c.id
                              ? null
                              : c.id,
                        ),
                        kPrimarySlate,
                        kSecondarySlate,
                        kBorderSlate,
                        kCardBackground,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Update parent
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimarySlate,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _filterType = null;
                          _filterCategory = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Reset Filters",
                        style: TextStyle(
                          color: kSecondarySlate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color kPrimarySlate,
    Color kSecondarySlate,
    Color kBorderSlate,
    Color kCardBackground,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimarySlate : kCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? kPrimarySlate : kBorderSlate),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (kPrimarySlate == Colors.white ? Colors.black : Colors.white)
                : kSecondarySlate,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showSearchModal(
    Color kAccentSlate,
    Color kPrimarySlate,
    Color kSecondarySlate,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kCardBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    const kBorderSlate = Color(0xFFE2E8F0);
    const kPrimaryPurple = Color(0xFF8B5CF6);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
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
              TextField(
                autofocus: true,
                style: TextStyle(color: kPrimarySlate),
                decoration: InputDecoration(
                  hintText: "Search transactions...",
                  hintStyle: TextStyle(color: kSecondarySlate),
                  prefixIcon: Icon(Icons.search, color: kSecondarySlate),
                  filled: true,
                  fillColor: kAccentSlate,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: kPrimaryPurple,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimarySlate,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
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
}

class _TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onTap;
  final Color kCardBackground;
  final Color kPrimarySlate;
  final Color kSecondarySlate;
  final Color kBorderSlate;
  final String currencySymbol;

  const _TransactionItem({
    required this.transaction,
    required this.onTap,
    required this.kCardBackground,
    required this.kPrimarySlate,
    required this.kSecondarySlate,
    required this.kBorderSlate,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN', // Using configured locale
      symbol: currencySymbol,
      decimalDigits: 0,
    );
    final category = CategoryEntity.getById(transaction.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorderSlate),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kSecondarySlate.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: kPrimarySlate, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? category.name,
                    style: TextStyle(
                      color: kPrimarySlate,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM').format(transaction.date),
                    style: TextStyle(color: kSecondarySlate, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              (transaction.isExpense ? '-' : '+') +
                  currencyFormat.format(transaction.amount),
              style: TextStyle(
                color: transaction.isExpense
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF22C55E),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
