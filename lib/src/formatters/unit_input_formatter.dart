import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Input mask driven by the **minor unit** of a quantity.
///
/// The user types digits only and the field is filled right to left, like a cash
/// register: with [decimalDigits] set to 3, typing "1000000" renders
/// "1.000,000". An invalid format becomes impossible to type — the thousands
/// separator and the decimal comma are inserted by the formatter itself.
///
/// [symbol] is rendered as a **prefix** (the `pt_BR` currency pattern places it
/// before the number and already includes the separator, so pass `R$` without a
/// trailing space). That separator is a NO-BREAK SPACE (`U+00A0`), not a plain
/// one — string literals compared against the output must use `\u{A0}`. A
/// trailing unit such as `kg` must NOT go through [symbol]; it belongs to the
/// field decoration instead.
class UnitInputFormatter extends TextInputFormatter {
  UnitInputFormatter({
    this.maxDigits = 9,
    this.decimalDigits = 2,
    this.locale = 'pt_BR',
    this.symbol = '',
  })  : assert(decimalDigits >= 0, 'decimalDigits must not be negative'),
        assert(maxDigits > 0, 'maxDigits must be positive');

  /// Digit ceiling, guards against numeric overflow.
  final int maxDigits;

  /// Decimal digits displayed; the exponent between the minor unit and the
  /// displayed one. With `0` the field becomes an integer amount ("1.000").
  final int decimalDigits;

  /// Locale used when formatting (thousands and decimal separators).
  final String locale;

  /// Prefix rendered to the left of the number. Empty by default — the field
  /// label usually already names the quantity.
  final String symbol;

  late final NumberFormat _formatter = _numberFormat(locale, symbol, decimalDigits);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clamped = _clampDigits(newValue.text, maxDigits);

    if (clamped == null) {
      return const TextEditingValue(text: '');
    }

    // Reads the digits as the minor unit: "100000" -> 1000,00 (2 digits).
    final value = int.parse(clamped) / _divisor(decimalDigits);
    final formatted = _formatter.format(value).trim();

    // Keeps the caret at the end of the formatted text.
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Converts formatted text back to the minor unit.
  ///
  /// Because the mask is built on the minor unit, the digits themselves ALREADY
  /// are the result — extracting them is enough, no division needed. Robust
  /// against thousands separators and the decimal comma, and independent of
  /// [decimalDigits].
  ///
  /// When [maxDigits] is given, extra digits are dropped from the right exactly
  /// as `formatEditUpdate` does while typing, so a pasted or programmatic text
  /// can never yield a value the field itself could not produce. Omitting it
  /// keeps the previous behavior: every digit is read.
  static int parse(String text, {int? maxDigits}) {
    return int.parse(_clampDigits(text, maxDigits) ?? '0');
  }

  /// Formats a minor-unit amount as display text, to prefill the field.
  ///
  /// Used when editing an existing value — the formatter only acts on user
  /// typing, never on text set programmatically. [decimalDigits] must match the
  /// one used by the field's [UnitInputFormatter].
  ///
  /// [maxDigits] clamps the same way [parse] and `formatEditUpdate` do, so the
  /// three stay symmetric: whatever `format` renders, `parse` reads back
  /// unchanged. Omitting it keeps the previous behavior.
  ///
  /// A negative [value] keeps its sign — only its magnitude is clamped. The mask
  /// itself never produces one (it reads digits only), so this matters solely for
  /// a value already stored as negative.
  static String format(
    int value, {
    int decimalDigits = 2,
    String locale = 'pt_BR',
    String symbol = '',
    int? maxDigits,
  }) {
    final magnitude = int.parse(_clampDigits('${value.abs()}', maxDigits) ?? '0');
    final clamped = value.isNegative ? -magnitude : magnitude;
    final formatter = _numberFormat(locale, symbol, decimalDigits);
    return formatter.format(clamped / _divisor(decimalDigits)).trim();
  }

  /// Digits of [text], truncated on the right at [maxDigits]; `null` when none.
  static String? _clampDigits(String text, int? maxDigits) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return maxDigits != null && digitsOnly.length > maxDigits
        ? digitsOnly.substring(0, maxDigits)
        : digitsOnly;
  }

  /// `NumberFormat` is expensive to build (it loads the locale symbols). Since
  /// an app uses only a few fixed combinations, one instance is kept per
  /// configuration — the field is rebuilt on every screen rebuild, and [format]
  /// is called once per row when building lists.
  static final Map<String, NumberFormat> _formatterCache = <String, NumberFormat>{};

  static NumberFormat _numberFormat(String locale, String symbol, int decimalDigits) {
    return _formatterCache.putIfAbsent(
      '$locale|$symbol|$decimalDigits',
      () => NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits),
    );
  }

  static int _divisor(int decimalDigits) {
    var divisor = 1;
    for (var i = 0; i < decimalDigits; i++) {
      divisor *= 10;
    }
    return divisor;
  }
}
