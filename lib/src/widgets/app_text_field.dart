import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/currency_input_formatter.dart';

/// Campo de texto com botão de limpar, rótulo flutuante e estado desabilitado.
///
/// Reage ao próprio [controller]: o sufixo alterna entre o botão de limpar
/// (quando há texto) e um chevron opcional ([showSuffixIcon]).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.hintText,
    this.onTap,
    this.readOnly = false,
    this.showSuffixIcon = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.inputFormatters,
    this.validator,
    this.errorText,
    this.disabledFillColor,
  });

  /// Campo de valor monetário no padrão brasileiro ("1.000,00").
  ///
  /// Usa teclado numérico puro (só dígitos) + [CurrencyInputFormatter], que
  /// insere automaticamente o separador de milhar e a vírgula decimal — o
  /// usuário nunca digita pontuação. Recupere o valor com
  /// `CurrencyInputFormatter.parse`.
  ///
  /// [decimalDigits] controla as casas decimais (padrão 2, ou seja, centavos).
  /// Com 0, o campo vira valor inteiro ("1.000"). Use o mesmo valor em
  /// `CurrencyInputFormatter.format` ao pré-preencher o campo.
  factory AppTextField.currency({
    Key? key,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool showSuffixIcon = false,
    int decimalDigits = 2,
    int maxDigits = 12,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
  }) {
    return AppTextField(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      readOnly: readOnly,
      showSuffixIcon: showSuffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      onTap: onTap,
      validator: validator,
      errorText: errorText,
      disabledFillColor: disabledFillColor,
      keyboardType: TextInputType.number,
      inputFormatters: [
        CurrencyInputFormatter(decimalDigits: decimalDigits, maxDigits: maxDigits),
      ],
    );
  }

  final FocusNode focusNode;
  final TextEditingController controller;
  final String hintText;
  final void Function()? onTap;
  final bool readOnly;
  final bool showSuffixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final void Function(String?)? onChanged;

  /// Disparado **apenas** ao confirmar no teclado (ação "done"/Enter), distinto
  /// de [onChanged] (que dispara a cada tecla). Quando `null`, cai no
  /// comportamento antigo (submit também chama [onChanged]).
  final void Function(String)? onSubmitted;

  /// Toque **fora** do campo. Passe um callback vazio (`(_) {}`) para impedir
  /// que toques na tela tirem o foco — útil quando a perda de foco é usada como
  /// sinal (ex.: "OK" do teclado numérico no iPhone). Quando `null`, mantém o
  /// comportamento padrão do Flutter (toque fora remove o foco).
  final void Function(PointerDownEvent)? onTapOutside;

  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  /// Mensagem de erro exibida abaixo do campo (validação inline). Quando `null`,
  /// nenhum erro é mostrado.
  final String? errorText;

  /// Cor de fundo quando o campo está desabilitado ([readOnly] sem [onTap]).
  /// Quando `null`, usa `Colors.grey.shade800` (tema escuro).
  final Color? disabledFillColor;

  @override
  Widget build(BuildContext context) {
    final InkWell buttonClear = InkWell(
      onTap: () {
        onChanged?.call('');
        controller.clear();
        focusNode.requestFocus();
      },
      child: const Icon(Icons.close, size: 24),
    );

    const Icon iconChevronRight = Icon(CupertinoIcons.chevron_right, size: 24);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, __, ___) {
        final Widget iconReturn = showSuffixIcon ? iconChevronRight : const SizedBox.shrink();
        // Campo readOnly sem onTap é tratado como desabilitado: visual apagado
        // e sem interação (não permite focar nem clicar dentro). Quando há
        // onTap, é um campo "toque para selecionar" — mantém-se interativo.
        final bool isDisabled = readOnly && onTap == null;
        // Campo desabilitado nunca exibe o botão de limpar — não deve permitir
        // apagar o valor (ex.: limite derivado das subcategorias).
        final Widget suffixIcon = !isDisabled && controller.text.isNotEmpty ? buttonClear : iconReturn;

        return TextFormField(
          validator: validator,
          controller: controller,
          enabled: !isDisabled,
          readOnly: readOnly,
          focusNode: focusNode,
          autocorrect: false,
          enableSuggestions: true,
          textInputAction: TextInputAction.done,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines,
          inputFormatters: inputFormatters,
          textCapitalization: TextCapitalization.sentences,
          onTapOutside: onTapOutside,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: isDisabled ? (disabledFillColor ?? Colors.grey.shade800) : null,
            hintText: hintText,
            labelText: hintText,
            errorText: errorText,
            suffixIcon: suffixIcon,
          ),
          onTap: onTap,
          onChanged: onChanged,
          onSaved: onChanged,
          onFieldSubmitted: (value) {
            if (onSubmitted != null) {
              onSubmitted!(value);
            } else {
              onChanged?.call(value);
            }
          },
        );
      },
    );
  }
}
