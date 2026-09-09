import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/unit_input_formatter.dart';
import '../formatters/unit_spec.dart';

/// Text field with a clear button, a floating label and a disabled state.
///
/// Reacts to its own [controller]: the suffix toggles between the clear button
/// (while there is text) and an optional chevron ([showSuffixIcon]).
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
    this.suffixText,
  });

  /// Numeric field for any quantity, configured by [spec].
  ///
  /// The user types digits only, in the minor unit of the quantity (grams for
  /// [UnitSpec.weight]); the mask inserts the thousands separator and the decimal
  /// comma, and the decoration renders the unit. Read the value back with
  /// `spec.parse(controller.text)`, which returns an `int` in the minor unit.
  ///
  /// To prefill the field, use `spec.format(value)` — it carries the same prefix
  /// the mask produces.
  factory AppTextField.unit({
    Key? key,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    required UnitSpec spec,
    bool readOnly = false,
    bool showSuffixIcon = false,
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
      suffixText: spec.suffix,
      keyboardType: TextInputType.number,
      inputFormatters: [spec.formatter()],
    );
  }

  /// Currency field in the Brazilian pattern ("R$ 1.000,00").
  ///
  /// Uses a digits-only keyboard plus a [UnitInputFormatter], which inserts the
  /// thousands separator and the decimal comma on its own — the user never types
  /// punctuation. Read the value back with `UnitInputFormatter.parse`.
  ///
  /// [decimalDigits] controls the decimal places (2 by default, that is, cents).
  /// With `0` the field becomes an integer amount ("R$ 1.000").
  ///
  /// To prefill the field, pass the SAME [symbol] used here:
  /// `UnitSpec.currency.format(value)` with the defaults, or
  /// `UnitInputFormatter.format(value, symbol: symbol)` with a custom one. The
  /// default of `UnitInputFormatter.format` is `''`, so calling it without the
  /// argument opens the field on "1.000,00" and the text jumps to
  /// "R$ 1.000,00" at the first keystroke.
  factory AppTextField.currency({
    Key? key,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool showSuffixIcon = false,
    int decimalDigits = 2,
    int maxDigits = 9,
    String symbol = r'R$',
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      spec: UnitSpec(decimalDigits: decimalDigits, maxDigits: maxDigits, symbol: symbol),
      readOnly: readOnly,
      showSuffixIcon: showSuffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      onTap: onTap,
      validator: validator,
      errorText: errorText,
      disabledFillColor: disabledFillColor,
    );
  }

  /// Weight field: the user types grams, the field shows "1.000,000 kg".
  ///
  /// Read the value in grams with `UnitSpec.weight.parse(controller.text)`.
  factory AppTextField.weight({
    Key? key,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool showSuffixIcon = false,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      spec: UnitSpec.weight,
      readOnly: readOnly,
      showSuffixIcon: showSuffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      onTap: onTap,
      validator: validator,
      errorText: errorText,
      disabledFillColor: disabledFillColor,
    );
  }

  /// Length field: the user types centimeters, the field shows "1.000,00 m".
  ///
  /// Read the value in centimeters with `UnitSpec.length.parse(controller.text)`.
  factory AppTextField.length({
    Key? key,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool showSuffixIcon = false,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      spec: UnitSpec.length,
      readOnly: readOnly,
      showSuffixIcon: showSuffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      onTap: onTap,
      validator: validator,
      errorText: errorText,
      disabledFillColor: disabledFillColor,
    );
  }

  /// Volume field: the user types milliliters, the field shows "1.000,000 L".
  ///
  /// Read the value in milliliters with `UnitSpec.volume.parse(controller.text)`.
  factory AppTextField.volume({
    Key? key,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool showSuffixIcon = false,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      spec: UnitSpec.volume,
      readOnly: readOnly,
      showSuffixIcon: showSuffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      onTap: onTap,
      validator: validator,
      errorText: errorText,
      disabledFillColor: disabledFillColor,
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

  /// Fired **only** when the keyboard action is confirmed ("done"/Enter),
  /// unlike [onChanged] (fired on every keystroke). When `null`, falls back to
  /// the older behavior (submit also calls [onChanged]).
  final void Function(String)? onSubmitted;

  /// A tap **outside** the field. Pass an empty callback (`(_) {}`) to keep taps
  /// on the screen from dropping the focus — useful when losing focus is used as
  /// a signal (for example the "OK" key of the iPhone numeric keyboard). When
  /// `null`, keeps the Flutter default (a tap outside removes the focus).
  final void Function(PointerDownEvent)? onTapOutside;

  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  /// Error message shown below the field (inline validation). When `null`, no
  /// error is shown.
  final String? errorText;

  /// Fill color while the field is disabled ([readOnly] without [onTap]). When
  /// `null`, uses `Colors.grey.shade800` (dark theme).
  final Color? disabledFillColor;

  /// Fixed text shown after the value, inside the field (for example "kg").
  ///
  /// It is not part of the controller text: the user cannot erase it and it never
  /// reaches `parse`.
  final String? suffixText;

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
        // A readOnly field without onTap is treated as disabled: dimmed and
        // non-interactive (it can neither be focused nor tapped into). With an
        // onTap it is a "tap to pick" field and stays interactive.
        final bool isDisabled = readOnly && onTap == null;
        // A disabled field never shows the clear button — erasing the value must
        // not be allowed (for example a limit derived from the subcategories).
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
            suffixText: suffixText,
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
