import 'unit_input_formatter.dart';

/// Preset of a quantity: binds the typed minor unit, the displayed decimal
/// digits, the prefix (currency) and the suffix (unit of measurement).
///
/// The decimal digits are NOT a free choice: they describe the ratio between the
/// minor unit and the displayed one (gram to kilogram is 3 digits, centimeter to
/// meter is 2). Keeping both together here prevents a screen from pairing grams
/// with 2 digits.
class UnitSpec {
  const UnitSpec({
    required this.decimalDigits,
    this.symbol = '',
    this.suffix,
    this.maxDigits = 9,
  })  : assert(decimalDigits >= 0, 'decimalDigits must not be negative'),
        assert(maxDigits > 0, 'maxDigits must be positive');

  /// Decimal digits displayed; the exponent between the minor unit and the
  /// displayed one. With `0` the field becomes an integer amount.
  final int decimalDigits;

  /// Prefix, to the left of the number. No trailing space: the `pt_BR` pattern
  /// already inserts one between symbol and number.
  final String symbol;

  /// Suffix, to the right of the number. Rendered by the `InputDecoration`,
  /// outside the field text — it never reaches `controller.text`.
  final String? suffix;

  /// Digit ceiling, guards against numeric overflow. Every preset uses `9`,
  /// the ceiling shared by the whole package.
  final int maxDigits;

  /// Cents displayed as reais: typing `100000` shows `R$ 1.000,00`.
  static const UnitSpec currency = UnitSpec(decimalDigits: 2, symbol: r'R$');

  /// Grams displayed as kilograms: typing `1000000` shows `1.000,000 kg`.
  static const UnitSpec weight = UnitSpec(decimalDigits: 3, suffix: 'kg');

  /// Centimeters displayed as meters: typing `100000` shows `1.000,00 m`.
  static const UnitSpec length = UnitSpec(decimalDigits: 2, suffix: 'm');

  /// Milliliters displayed as liters: typing `1000000` shows `1.000,000 L`.
  static const UnitSpec volume = UnitSpec(decimalDigits: 3, suffix: 'L');

  /// Formatter ready for a field of this quantity.
  UnitInputFormatter formatter({String locale = 'pt_BR'}) => UnitInputFormatter(
        decimalDigits: decimalDigits,
        maxDigits: maxDigits,
        locale: locale,
        symbol: symbol,
      );

  /// Formats the minor unit as display text, to prefill the field.
  ///
  /// The result carries the [symbol] prefix but never the [suffix]: the suffix is
  /// drawn by the decoration, so adding it here would put it inside the text.
  ///
  /// Clamped to [maxDigits], like [parse] and the mask — so
  /// `spec.parse(spec.format(v))` returns `v` for every `v` within the ceiling
  /// and returns the clamped value for anything above it, never a third number.
  String format(int value, {String locale = 'pt_BR'}) => UnitInputFormatter.format(
        value,
        decimalDigits: decimalDigits,
        locale: locale,
        symbol: symbol,
        maxDigits: maxDigits,
      );

  /// Converts the field text back to the minor unit, clamped to [maxDigits].
  ///
  /// The clamp mirrors what the mask does while typing: a pasted or programmatic
  /// text longer than [maxDigits] would otherwise yield a value the field itself
  /// could never produce.
  int parse(String text) => UnitInputFormatter.parse(text, maxDigits: maxDigits);
}
