/// Vietnamese đồng formatters. Mirrors
/// `web/src/features/wallet/utils/currency.ts` so both clients render
/// amounts the same way.
library;

/// Returns "1.234.567 ₫" with a non-breaking space + ₫ suffix.
String formatVnd(num amount) {
  final intValue = amount is int ? amount : amount.toInt();
  final formatted = _viLocale(intValue.abs());
  final sign = intValue < 0 ? '-' : '';
  return '$sign$formatted ₫';
}

/// Returns just the integer digits formatted in vi-VN, no currency suffix.
/// "1.234.567" for `1234567`.
String formatVndDigits(num amount) {
  final intValue = amount is int ? amount : amount.toInt();
  return _viLocale(intValue.abs());
}

/// Normalises free-form user input: strips everything that isn't a digit
/// and caps to 12 digits (1.000.000.000.000 — more than enough).
String normalizeVndInput(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
  return cleaned.length > 12 ? cleaned.substring(0, 12) : cleaned;
}

/// Formats a normalised (digits-only) string into the typing-friendly
/// "1.234.567" form for an input field.
String formatVndInput(String digitsOnly) {
  if (digitsOnly.isEmpty) return '';
  final n = int.tryParse(digitsOnly) ?? 0;
  return _viLocale(n);
}

String _viLocale(int value) {
  // Group thousands with "." to match vi-VN convention.
  final s = value.toString();
  final reversed = s.split('').reversed.toList();
  final grouped = <String>[];
  for (var i = 0; i < reversed.length; i++) {
    if (i > 0 && i % 3 == 0) grouped.add('.');
    grouped.add(reversed[i]);
  }
  return grouped.reversed.join();
}
