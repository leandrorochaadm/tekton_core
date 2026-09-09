import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/unit_input_formatter.dart';
import '../formatters/unit_spec.dart';

/// Text field with a clear button, a floating label and a disabled state.
///
/// Reacts to its own [controller]: the suffix toggles between the clear button
/// (while there is text) and an optional chevron ([showSuffixIcon]).
///
/// [focusNode] and [controller] are optional: when either is `null`, the widget
/// creates its own and disposes it — never the one that came from outside.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.focusNode,
    this.controller,
    this.hintText,
    this.initialValue,
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
    this.decoration,
    this.enabled = true,
    this.showClearButton = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction = TextInputAction.done,
  }) : assert(
          controller == null || initialValue == null,
          'Pass initialValue only when controller is null — a controller already carries its own text.',
        );

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
    FocusNode? focusNode,
    TextEditingController? controller,
    String? hintText,
    required UnitSpec spec,
    String? initialValue,
    bool readOnly = false,
    bool showSuffixIcon = false,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
    InputDecoration? decoration,
    bool enabled = true,
    bool showClearButton = true,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return AppTextField(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      initialValue: initialValue,
      readOnly: readOnly,
      showSuffixIcon: showSuffixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTapOutside: onTapOutside,
      onTap: onTap,
      validator: validator,
      errorText: errorText,
      disabledFillColor: disabledFillColor,
      decoration: decoration,
      enabled: enabled,
      showClearButton: showClearButton,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
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
    FocusNode? focusNode,
    TextEditingController? controller,
    String? hintText,
    String? initialValue,
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
    InputDecoration? decoration,
    bool enabled = true,
    bool showClearButton = true,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      initialValue: initialValue,
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
      decoration: decoration,
      enabled: enabled,
      showClearButton: showClearButton,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
    );
  }

  /// Weight field: the user types grams, the field shows "1.000,000 kg".
  ///
  /// Read the value in grams with `UnitSpec.weight.parse(controller.text)`.
  factory AppTextField.weight({
    Key? key,
    FocusNode? focusNode,
    TextEditingController? controller,
    String? hintText,
    String? initialValue,
    bool readOnly = false,
    bool showSuffixIcon = false,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
    InputDecoration? decoration,
    bool enabled = true,
    bool showClearButton = true,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      initialValue: initialValue,
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
      decoration: decoration,
      enabled: enabled,
      showClearButton: showClearButton,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
    );
  }

  /// Length field: the user types centimeters, the field shows "1.000,00 m".
  ///
  /// Read the value in centimeters with `UnitSpec.length.parse(controller.text)`.
  factory AppTextField.length({
    Key? key,
    FocusNode? focusNode,
    TextEditingController? controller,
    String? hintText,
    String? initialValue,
    bool readOnly = false,
    bool showSuffixIcon = false,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
    InputDecoration? decoration,
    bool enabled = true,
    bool showClearButton = true,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      initialValue: initialValue,
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
      decoration: decoration,
      enabled: enabled,
      showClearButton: showClearButton,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
    );
  }

  /// Volume field: the user types milliliters, the field shows "1.000,000 L".
  ///
  /// Read the value in milliliters with `UnitSpec.volume.parse(controller.text)`.
  factory AppTextField.volume({
    Key? key,
    FocusNode? focusNode,
    TextEditingController? controller,
    String? hintText,
    String? initialValue,
    bool readOnly = false,
    bool showSuffixIcon = false,
    void Function(String?)? onChanged,
    void Function(String)? onSubmitted,
    void Function(PointerDownEvent)? onTapOutside,
    void Function()? onTap,
    String? Function(String?)? validator,
    String? errorText,
    Color? disabledFillColor,
    InputDecoration? decoration,
    bool enabled = true,
    bool showClearButton = true,
    bool autofocus = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return AppTextField.unit(
      key: key,
      focusNode: focusNode,
      controller: controller,
      hintText: hintText,
      initialValue: initialValue,
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
      decoration: decoration,
      enabled: enabled,
      showClearButton: showClearButton,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
    );
  }

  /// The field's focus node. When `null`, the widget creates and disposes its own.
  final FocusNode? focusNode;

  /// The field's controller. When `null`, the widget creates and disposes its own,
  /// seeded with [initialValue].
  final TextEditingController? controller;

  /// The field's label and placeholder. When `null`, the label comes from
  /// [decoration] (`labelText`/`hintText`); when given, it wins over both.
  final String? hintText;

  /// The text the field opens with, when [controller] is `null`. Passing both is
  /// a usage error — a controller already carries its own text.
  final String? initialValue;

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

  /// Extra decoration for the field. What this widget owns — the floating label,
  /// the fill, the clear button, [errorText] and [suffixText] — is applied on top;
  /// everything else (helper, prefix, border, density, padding) comes from here.
  ///
  /// A `suffixIcon` given here shows only while the widget has no suffix of its
  /// own (no clear button and no chevron).
  ///
  /// Note on `prefixText`/`suffixText`: the Material `InputDecorator` draws them
  /// only while the label floats. This widget always floats it
  /// ([FloatingLabelBehavior.always]), so a `prefixText` passed here shows even
  /// with the field empty.
  final InputDecoration? decoration;

  /// Whether the field accepts interaction. `false` while an action is in flight
  /// (a save, a reload) — different from [readOnly], which is the field that fills
  /// in by tapping instead of typing.
  final bool enabled;

  /// Whether the clear button (`✕`) shows while there is text. `false` for a field
  /// too narrow to spend 24 px on it — a column inside a repeated row.
  final bool showClearButton;

  /// Whether the field takes the focus as soon as it is shown. Meant for a dialog
  /// or a sheet that opens with a single field.
  final bool autofocus;

  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownFocusNode;
  TextEditingController? _ownController;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController(text: widget.initialValue));

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A controller (or focus node) coming from outside makes the one created
    // here garbage: drop it right away instead of waiting for dispose.
    if (widget.controller != null && _ownController != null) {
      _ownController!.dispose();
      _ownController = null;
    }
    if (widget.focusNode != null && _ownFocusNode != null) {
      _ownFocusNode!.dispose();
      _ownFocusNode = null;
    }
  }

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = _controller;

    final InkWell buttonClear = InkWell(
      onTap: () {
        widget.onChanged?.call('');
        controller.clear();
        _focusNode.requestFocus();
      },
      child: const Icon(Icons.close, size: 24),
    );

    const Icon iconChevronRight = Icon(CupertinoIcons.chevron_right, size: 24);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, __, ___) {
        // A readOnly field without onTap is treated as disabled: dimmed and
        // non-interactive (it can neither be focused nor tapped into). With an
        // onTap it is a "tap to pick" field and stays interactive.
        final bool isDisabled = widget.readOnly && widget.onTap == null;
        // Neither a disabled nor an unavailable field shows the clear button —
        // the button is a bare InkWell, so the decorator does not mute it, and a
        // tap would erase a value the user cannot retype.
        final Widget? clear =
            widget.enabled && !isDisabled && widget.showClearButton && controller.text.isNotEmpty ? buttonClear : null;
        // The slot is only taken when this widget has something to put in it;
        // otherwise the caller's own suffixIcon (if any) survives the copyWith.
        final Widget suffix = clear ??
            (widget.showSuffixIcon ? iconChevronRight : widget.decoration?.suffixIcon ?? const SizedBox.shrink());

        return TextFormField(
          validator: widget.validator,
          controller: controller,
          enabled: widget.enabled && !isDisabled,
          readOnly: widget.readOnly,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          autocorrect: false,
          enableSuggestions: true,
          textInputAction: widget.textInputAction,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          minLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          onTapOutside: widget.onTapOutside,
          // copyWith is `field ?? this.field`, so every null below keeps what the
          // caller passed in [decoration].
          decoration: (widget.decoration ?? const InputDecoration()).copyWith(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: isDisabled ? (widget.disabledFillColor ?? Colors.grey.shade800) : null,
            hintText: widget.hintText,
            labelText: widget.hintText,
            errorText: widget.errorText,
            suffixText: widget.suffixText,
            suffixIcon: suffix,
          ),
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onSaved: widget.onChanged,
          onFieldSubmitted: (value) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!(value);
            } else {
              widget.onChanged?.call(value);
            }
          },
        );
      },
    );
  }
}
