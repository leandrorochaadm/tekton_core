import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekton_core/tekton_core.dart';

void main() {
  group('UnitInputFormatter', () {
    // Aplica o formatter como o framework faria ao digitar: ignora o oldValue
    // e recalcula a partir do texto novo.
    TextEditingValue applyInput(String text, {int maxDigits = 12}) {
      final formatter = UnitInputFormatter(maxDigits: maxDigits);
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: text),
      );
    }

    group('formatEditUpdate', () {
      test('should format digits as brazilian currency treating them as cents', () {
        final result = applyInput('100000');

        expect(result.text, '1.000,00');
      });

      test('should format a single digit as cents below one real', () {
        final result = applyInput('50');

        expect(result.text, '0,50');
      });

      test('should keep the cursor collapsed at the end of the text', () {
        final result = applyInput('100000');

        expect(
          result.selection,
          TextSelection.collapsed(offset: result.text.length),
        );
      });

      test('should return empty text when input has no digits', () {
        final result = applyInput('abc');

        expect(result.text, isEmpty);
      });

      test('should return empty text when input is empty', () {
        final result = applyInput('');

        expect(result.text, isEmpty);
      });

      test('should strip non-digit characters before formatting', () {
        final result = applyInput(r'R$ 1.234,xy');

        // Apenas os dígitos "1234" sobrevivem -> 12,34.
        expect(result.text, '12,34');
      });

      test('should clamp the digit count to maxDigits', () {
        final result = applyInput('123456', maxDigits: 4);

        // Mantém só os 4 primeiros dígitos ("1234") -> 12,34.
        expect(result.text, '12,34');
      });
    });

    group('parse', () {
      test('should parse formatted currency into cents', () {
        expect(UnitInputFormatter.parse('1.000,00'), 100000);
      });

      test('should parse value below one real into cents', () {
        expect(UnitInputFormatter.parse('0,50'), 50);
      });

      test('should parse values in the millions range into cents', () {
        expect(UnitInputFormatter.parse('1.234.567,89'), 123456789);
      });

      test('should parse small cents exactly (no floating point drift)', () {
        expect(UnitInputFormatter.parse('0,07'), 7);
      });

      test('should parse value ignoring currency symbol and spaces', () {
        expect(UnitInputFormatter.parse(r'R$ 50,00'), 5000);
      });

      test('should return zero for empty text', () {
        expect(UnitInputFormatter.parse(''), 0);
      });

      test('should return zero when there are no digits', () {
        expect(UnitInputFormatter.parse('abc'), 0);
      });
      test('should read every digit when maxDigits is omitted', () {
        expect(UnitInputFormatter.parse('1.234.567.890'), 1234567890);
      });

      test('should clamp extra digits when maxDigits is given', () {
        expect(UnitInputFormatter.parse('1.234.567.890', maxDigits: 9), 123456789);
      });
    });

    group('format', () {
      test('should format cents with thousands separator and decimals', () {
        expect(UnitInputFormatter.format(100000), '1.000,00');
      });

      test('should format cents below one real with leading zero', () {
        expect(UnitInputFormatter.format(50), '0,50');
      });

      test('should format zero', () {
        expect(UnitInputFormatter.format(0), '0,00');
      });

      test('should format millions of cents with grouped thousands', () {
        expect(UnitInputFormatter.format(123456789), '1.234.567,89');
      });

      test('should format small cents value', () {
        expect(UnitInputFormatter.format(7), '0,07');
      });

      test('should clamp extra digits when maxDigits is given', () {
        expect(UnitInputFormatter.format(9999999999, maxDigits: 9), '9.999.999,99');
        expect(UnitInputFormatter.format(9999999999), '99.999.999,99');
      });

      test('should keep the sign of a negative value while clamping', () {
        expect(UnitInputFormatter.format(-500), contains('5,00'));
        expect(UnitInputFormatter.format(-500), startsWith('-'));
        expect(UnitInputFormatter.format(-9999999999, maxDigits: 9), contains('9.999.999,99'));
        expect(UnitInputFormatter.format(-9999999999, maxDigits: 9), startsWith('-'));
      });
    });

    group('round-trip', () {
      test('parse should reverse format for arbitrary cents', () {
        const valueInCents = 123456;

        final formatted = UnitInputFormatter.format(valueInCents);
        final parsed = UnitInputFormatter.parse(formatted);

        expect(parsed, valueInCents);
      });
    });
  });

  group('UnitInputFormatter.decimalDigits', () {
    TextEditingValue applyInput(String text, {required int decimalDigits}) {
      final formatter = UnitInputFormatter(decimalDigits: decimalDigits);
      return formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: text),
      );
    }

    test('should default to two decimal digits', () {
      expect(UnitInputFormatter().decimalDigits, 2);
    });

    test('should format without decimals when decimalDigits is zero', () {
      final result = applyInput('1000', decimalDigits: 0);

      expect(result.text, '1.000');
    });

    test('should format with three decimals when decimalDigits is three', () {
      final result = applyInput('1000000', decimalDigits: 3);

      expect(result.text, '1.000,000');
    });

    test('should keep parse independent of decimalDigits', () {
      expect(UnitInputFormatter.parse('1.000'), 1000);
      expect(UnitInputFormatter.parse('1.000,000'), 1000000);
    });

    test('should format smallest unit back to text honoring decimalDigits', () {
      expect(UnitInputFormatter.format(1000, decimalDigits: 0), '1.000');
      expect(UnitInputFormatter.format(100000), '1.000,00');
      expect(UnitInputFormatter.format(1000000, decimalDigits: 3), '1.000,000');
    });

    test('should reject negative decimalDigits', () {
      expect(() => UnitInputFormatter(decimalDigits: -1), throwsAssertionError);
    });
  });
}
