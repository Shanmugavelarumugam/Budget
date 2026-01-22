import 'package:flutter/services.dart';

/// A [TextInputFormatter] that normalizes Devanagari numerals to standard English digits.
/// This is crucial for finance apps in India where system keyboards might default to
/// local scripts (e.g., १२३ instead of 123), ensuring consistent numeric input.
class DigitNormalizer extends TextInputFormatter {
  static const _map = {
    '०': '0',
    '१': '1',
    '२': '2',
    '३': '3',
    '४': '4',
    '५': '5',
    '६': '6',
    '७': '7',
    '८': '8',
    '९': '9',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final normalizedText = newValue.text.split('').map((c) {
      return _map[c] ?? c;
    }).join();

    // If the text hasn't changed (no Devanagari numerals were present),
    // return the newValue as-is to preserve the user's cursor position/selection.
    if (normalizedText == newValue.text) {
      return newValue;
    }

    // If text was normalized, we return the new text.
    // Ideally we should map the selection, but for simple substitution
    // maintaining the cursor at the end is a safe fallback to prevent index crashes.
    return newValue.copyWith(
      text: normalizedText,
      selection: TextSelection.collapsed(offset: normalizedText.length),
    );
  }
}
