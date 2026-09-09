import 'package:flutter_test/flutter_test.dart';
import 'package:tekton_core/tekton_core.dart';

void main() {
  group('UnitSpec presets', () {
    test('should bind currency to cents with two decimals and the currency prefix', () {
      expect(UnitSpec.currency.decimalDigits, 2);
      expect(UnitSpec.currency.symbol, r'R$');
      expect(UnitSpec.currency.suffix, isNull);
      expect(UnitSpec.currency.maxDigits, 9);
    });

    test('should bind weight to grams with three decimals and the kg suffix', () {
      expect(UnitSpec.weight.decimalDigits, 3);
      expect(UnitSpec.weight.symbol, '');
      expect(UnitSpec.weight.suffix, 'kg');
      expect(UnitSpec.weight.maxDigits, 9);
    });

    test('should bind length to centimeters with two decimals and the m suffix', () {
      expect(UnitSpec.length.decimalDigits, 2);
      expect(UnitSpec.length.suffix, 'm');
      expect(UnitSpec.length.maxDigits, 9);
    });

    test('should bind volume to milliliters with three decimals and the L suffix', () {
      expect(UnitSpec.volume.decimalDigits, 3);
      expect(UnitSpec.volume.suffix, 'L');
      expect(UnitSpec.volume.maxDigits, 9);
    });
  });

  group('UnitSpec.format', () {
    test('should format grams as kilograms', () {
      expect(UnitSpec.weight.format(1000000), '1.000,000');
    });

    test('should format centimeters as meters', () {
      expect(UnitSpec.length.format(100000), '1.000,00');
    });

    test('should format milliliters as liters', () {
      expect(UnitSpec.volume.format(1500), '1,500');
    });

    test('should format cents as reais with the prefix separated by a NBSP', () {
      expect(UnitSpec.currency.format(100000), 'R\$\u{A0}1.000,00');
    });

    test('should never carry the suffix inside the formatted text', () {
      expect(UnitSpec.weight.format(1000000), isNot(contains('kg')));
    });
  });

  group('UnitSpec.parse', () {
    test('should read grams back from the formatted text with its unit', () {
      expect(UnitSpec.weight.parse('1.000,000 kg'), 1000000);
    });

    test('should read cents back from the formatted text with its prefix', () {
      expect(UnitSpec.currency.parse('R\$\u{A0}1.000,00'), 100000);
    });

    test('should read empty text as zero', () {
      expect(UnitSpec.weight.parse(''), 0);
    });
  });

  group('UnitSpec round-trip', () {
    const specs = <String, UnitSpec>{
      'currency': UnitSpec.currency,
      'weight': UnitSpec.weight,
      'length': UnitSpec.length,
      'volume': UnitSpec.volume,
    };

    for (final entry in specs.entries) {
      test('parse should reverse format at the ceiling for ${entry.key}', () {
        final spec = entry.value;

        expect(spec.parse(spec.format(999999999)), 999999999);
      });

      test('parse should reverse format for a small value for ${entry.key}', () {
        final spec = entry.value;

        expect(spec.parse(spec.format(5)), 5);
      });

      test('format and parse should clamp at the same point for ${entry.key}', () {
        final spec = entry.value;

        expect(spec.parse(spec.format(9999999999)), 999999999);
      });
    }
  });

  group('UnitSpec.formatter', () {
    test('should build a formatter carrying the preset configuration', () {
      final formatter = UnitSpec.weight.formatter();

      expect(formatter.decimalDigits, 3);
      expect(formatter.maxDigits, 9);
      expect(formatter.symbol, '');
      expect(formatter.locale, 'pt_BR');
    });

    test('should honor a custom locale', () {
      final formatter = UnitSpec.currency.formatter(locale: 'en_US');

      expect(formatter.locale, 'en_US');
    });
  });

  group('UnitSpec asserts', () {
    test('should reject negative decimalDigits', () {
      expect(() => UnitSpec(decimalDigits: -1), throwsAssertionError);
    });

    test('should reject a non-positive maxDigits', () {
      expect(() => UnitSpec(decimalDigits: 2, maxDigits: 0), throwsAssertionError);
    });
  });
}
