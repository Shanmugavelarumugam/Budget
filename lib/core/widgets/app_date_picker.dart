import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final Function(DateTime) onDateSelected;

  const AppDatePicker({
    super.key,
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.onDateSelected,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  // View Modes: 0 = Days, 1 = Month Picker, 2 = Year Picker
  int _viewMode = 0;

  // For animation
  final Duration _animDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _updatePageController();
  }

  void _updatePageController() {
    final monthsDiff =
        (_currentMonth.year - widget.minDate.year) * 12 +
        (_currentMonth.month - widget.minDate.month);
    _pageController = PageController(initialPage: monthsDiff);
  }

  void _onPageChanged(int index) {
    if (_viewMode == 0) {
      setState(() {
        _currentMonth = DateTime(
          widget.minDate.year,
          widget.minDate.month + index,
        );
      });
    }
  }

  void _jumpToSpecificMonth(int month) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, month);
      _viewMode = 0; // Return to days
      _updatePageController();
    });
  }

  void _jumpToSpecificYear(int year) {
    setState(() {
      _currentMonth = DateTime(year, _currentMonth.month);
      _viewMode = 0; // Return to days
      _updatePageController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final kSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final kCard = isDark ? const Color(0xFF1E293B) : Colors.white;
    final kBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return AnimatedContainer(
      duration: _animDuration,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      height: 480, // Fixed height for consistency
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Toggle Month Picker
                    setState(() => _viewMode = _viewMode == 1 ? 0 : 1);
                  },
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMMM').format(_currentMonth),
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Icon(
                        _viewMode == 1
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        color: kSecondary,
                      ),
                    ],
                  ),
                ),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Toggle Year Picker
                        setState(() => _viewMode = _viewMode == 2 ? 0 : 2);
                      },
                      child: Row(
                        children: [
                          Text(
                            DateFormat('yyyy').format(_currentMonth),
                            style: TextStyle(
                              color: kSecondary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Icon(
                            _viewMode == 2
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_rounded,
                            color: kSecondary,
                          ),
                        ],
                      ),
                    ),
                    if (_viewMode == 0) ...[
                      const SizedBox(width: 16),
                      _buildHeaderArrow(
                        Icons.chevron_left_rounded,
                        -1,
                        kPrimary,
                        kBorder,
                      ),
                      const SizedBox(width: 8),
                      _buildHeaderArrow(
                        Icons.chevron_right_rounded,
                        1,
                        kPrimary,
                        kBorder,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CONTENT AREA
          Expanded(
            child: AnimatedSwitcher(
              duration: _animDuration,
              child: _buildCurrentView(
                kPrimary,
                kSecondary,
                kCard,
                kBorder,
                isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(
    Color kPrimary,
    Color kSecondary,
    Color kCard,
    Color kBorder,
    bool isDark,
  ) {
    switch (_viewMode) {
      case 1:
        return _buildMonthPicker(kPrimary, kCard, kBorder, isDark);
      case 2:
        return _buildYearPicker(kPrimary, kSecondary, kCard, kBorder, isDark);
      default:
        return _buildCalendarView(kSecondary, kPrimary, kBorder, isDark);
    }
  }

  Widget _buildCalendarView(
    Color kSecondary,
    Color kPrimary,
    Color kBorder,
    bool isDark,
  ) {
    final totalMonths =
        (widget.maxDate.year - widget.minDate.year) * 12 +
        (widget.maxDate.month - widget.minDate.month) +
        1;
    return Column(
      key: const ValueKey("CalendarView"),
      children: [
        // Weekdays Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                .map(
                  (day) => SizedBox(
                    width: 32,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Days Grid
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalMonths,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final monthDate = DateTime(
                widget.minDate.year,
                widget.minDate.month + index,
              );
              return _buildMonthGrid(monthDate, kPrimary, kSecondary, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPicker(
    Color kPrimary,
    Color kCard,
    Color kBorder,
    bool isDark,
  ) {
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return GridView.builder(
      key: const ValueKey("MonthPicker"),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final isSelected = index + 1 == _currentMonth.month;
        return InkWell(
          onTap: () => _jumpToSpecificMonth(index + 1),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? kPrimary : kCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorder),
            ),
            alignment: Alignment.center,
            child: Text(
              months[index],
              style: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : kPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearPicker(
    Color kPrimary,
    Color kSecondary,
    Color kCard,
    Color kBorder,
    bool isDark,
  ) {
    final startYear = widget.minDate.year;
    final endYear = widget.maxDate.year;
    final years = List.generate(endYear - startYear + 1, (i) => startYear + i);

    return Column(
      key: const ValueKey("YearPicker"),
      children: [
        // Manual Year Input

        // Year Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final isSelected = year == _currentMonth.year;
              return InkWell(
                onTap: () => _jumpToSpecificYear(year),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$year",
                    style: TextStyle(
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : kPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderArrow(
    IconData icon,
    int step,
    Color kPrimary,
    Color kBorder,
  ) {
    return InkWell(
      onTap: () {
        _pageController.animateToPage(
          _pageController.page!.toInt() + step,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: kBorder),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: kPrimary),
      ),
    );
  }

  Widget _buildMonthGrid(
    DateTime monthDate,
    Color kPrimary,
    Color kSecondary,
    bool isDark,
  ) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    final offset = (firstWeekday % 7);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 0,
        childAspectRatio: 1.0,
      ),
      itemCount: daysInMonth + offset,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox();

        final day = index - offset + 1;
        final date = DateTime(monthDate.year, monthDate.month, day);
        final isSelected =
            date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
        final isToday =
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;

        return _buildDayItem(
          day,
          date,
          isSelected,
          isToday,
          kPrimary,
          kSecondary,
          isDark,
        );
      },
    );
  }

  Widget _buildDayItem(
    int day,
    DateTime date,
    bool isSelected,
    bool isToday,
    Color kPrimary,
    Color kSecondary,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: kSecondary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            "$day",
            style: TextStyle(
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
