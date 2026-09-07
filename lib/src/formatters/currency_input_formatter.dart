import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatador de moeda para campos de texto, no padrão brasileiro.
///
/// Trata a entrada como a menor unidade da moeda (centavos, quando
/// [decimalDigits] é 2): o usuário digita apenas dígitos e o campo é formatado
/// automaticamente como "1.000,00". Isso torna impossível digitar um formato
/// inválido — o separador de milhar e a vírgula decimal são inseridos pelo
/// próprio formatter.
class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter({
    this.maxDigits = 12,
    this.decimalDigits = 2,
    this.locale = 'pt_BR',
    this.symbol = '',
  })  : assert(decimalDigits >= 0, 'decimalDigits não pode ser negativo'),
        assert(maxDigits > 0, 'maxDigits deve ser positivo');

  /// Limite de dígitos para evitar overflow numérico (até bilhões com centavos).
  final int maxDigits;

  /// Casas decimais exibidas. Com 2 (padrão), os dígitos digitados são
  /// centavos; com 0, o campo vira valor inteiro ("1.000").
  final int decimalDigits;

  /// Locale usado na formatação (separadores de milhar e decimal).
  final String locale;

  /// Símbolo prefixado ao valor. Vazio por padrão — o rótulo do campo costuma
  /// já indicar a moeda.
  final String symbol;

  late final NumberFormat _formatter = _numberFormat(locale, symbol, decimalDigits);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final clamped = digitsOnly.length > maxDigits ? digitsOnly.substring(0, maxDigits) : digitsOnly;

    // Interpreta os dígitos como a menor unidade: "100000" -> 1000,00 (2 casas).
    final value = int.parse(clamped) / _divisor(decimalDigits);
    final formatted = _formatter.format(value).trim();

    // Mantém o cursor sempre no final do texto formatado.
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Converte o texto formatado ("1.000,00") na menor unidade (100000).
  ///
  /// Como a máscara é baseada na menor unidade, os próprios dígitos JÁ são o
  /// resultado — basta extraí-los, sem dividir. Robusto contra separadores de
  /// milhar e vírgula decimal, e independente de [decimalDigits].
  static int parse(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return 0;
    return int.parse(digitsOnly);
  }

  /// Formata a menor unidade (100000) no texto de moeda ("1.000,00").
  ///
  /// Usado para pré-preencher o campo ao editar — o formatter só atua na
  /// digitação do usuário, não em texto setado programaticamente.
  ///
  /// [decimalDigits] deve casar com o do [CurrencyInputFormatter] usado no campo.
  static String format(
    int value, {
    int decimalDigits = 2,
    String locale = 'pt_BR',
    String symbol = '',
  }) {
    final formatter = _numberFormat(locale, symbol, decimalDigits);
    return formatter.format(value / _divisor(decimalDigits)).trim();
  }

  /// `NumberFormat` é caro de construir (carrega os símbolos do locale). Como as
  /// combinações usadas por um app são poucas e fixas, guarda uma instância por
  /// configuração — o campo é reconstruído a cada rebuild da tela, e [format] é
  /// chamado a cada linha ao montar listas.
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
