import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekton_core/tekton_core.dart';

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;

  setUp(() {
    controller = TextEditingController();
    focusNode = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  Future<void> pumpField(WidgetTester tester, Widget field) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: field)),
    );
  }

  group('AppTextField', () {
    testWidgets('should render the hint as label', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
        ),
      );

      expect(find.text('Descrição'), findsWidgets);
    });

    testWidgets('should show clear button only when there is text', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should clear the controller when clear button is tapped', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, isEmpty);
    });

    testWidgets('should hide clear button when disabled (readOnly without onTap)', (tester) async {
      controller.text = 'travado';

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Limite',
          readOnly: true,
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should show error text below the field', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          errorText: 'Campo obrigatório',
        ),
      );

      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('should fall back to onChanged on submit when onSubmitted is null', (tester) async {
      final changed = <String?>[];

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          onChanged: changed.add,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Sem onSubmitted, o submit também dispara onChanged: uma vez na
      // digitação e outra na confirmação do teclado.
      expect(changed, ['abc', 'abc']);
    });

    testWidgets('should route submit to onSubmitted without an extra onChanged', (tester) async {
      final submitted = <String>[];
      final changed = <String?>[];

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          onChanged: changed.add,
          onSubmitted: submitted.add,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, ['abc']);
      expect(changed, ['abc']); // só o onChanged da digitação, não o do submit
    });
  });

  group('AppTextField.currency', () {
    testWidgets('should mask typed digits as cents by default', (tester) async {
      await pumpField(
        tester,
        AppTextField.currency(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Valor',
        ),
      );

      await tester.enterText(find.byType(TextFormField), '100000');
      await tester.pump();

      expect(controller.text, 'R\$\u{A0}1.000,00');
    });

    testWidgets('should mask without decimals when decimalDigits is zero', (tester) async {
      await pumpField(
        tester,
        AppTextField.currency(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Valor',
          decimalDigits: 0,
        ),
      );

      await tester.enterText(find.byType(TextFormField), '1000');
      await tester.pump();

      expect(controller.text, 'R\$\u{A0}1.000');
    });
  });

  group('AppTextField.suffixText', () {
    testWidgets('should render the suffix on an empty unfocused field', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Peso',
          suffixText: 'kg',
        ),
      );

      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('should render the suffix on a filled field', (tester) async {
      controller.text = '1.000,000';

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Peso',
          suffixText: 'kg',
        ),
      );

      expect(find.text('kg'), findsOneWidget);
    });
  });

  group('AppTextField.weight', () {
    testWidgets('should mask typed digits as grams and show the kg suffix', (tester) async {
      await pumpField(
        tester,
        AppTextField.weight(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Peso',
        ),
      );

      await tester.enterText(find.byType(TextFormField), '1000000');
      await tester.pump();

      expect(controller.text, '1.000,000');
      expect(controller.text, isNot(contains('kg')));
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('should let the preset read the typed value back in grams', (tester) async {
      await pumpField(
        tester,
        AppTextField.weight(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Peso',
        ),
      );

      await tester.enterText(find.byType(TextFormField), '1000000');
      await tester.pump();

      expect(UnitSpec.weight.parse(controller.text), 1000000);
    });

    testWidgets('should keep the clear button on a filled measurement field', (tester) async {
      await pumpField(
        tester,
        AppTextField.weight(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Peso',
        ),
      );

      await tester.enterText(find.byType(TextFormField), '1000000');
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('AppTextField.length', () {
    testWidgets('should mask typed digits as centimeters and show the m suffix', (tester) async {
      await pumpField(
        tester,
        AppTextField.length(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Altura',
        ),
      );

      await tester.enterText(find.byType(TextFormField), '100000');
      await tester.pump();

      expect(controller.text, '1.000,00');
      expect(find.text('m'), findsOneWidget);
    });
  });

  group('AppTextField.volume', () {
    testWidgets('should mask typed digits as milliliters and show the L suffix', (tester) async {
      await pumpField(
        tester,
        AppTextField.volume(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Volume',
        ),
      );

      await tester.enterText(find.byType(TextFormField), '1000000');
      await tester.pump();

      expect(controller.text, '1.000,000');
      expect(find.text('L'), findsOneWidget);
    });
  });

  group('AppTextField.unit', () {
    testWidgets('should mask typed digits according to the given spec', (tester) async {
      await pumpField(
        tester,
        AppTextField.unit(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Quantidade',
          spec: UnitSpec.length,
        ),
      );

      await tester.enterText(find.byType(TextFormField), '100000');
      await tester.pump();

      expect(controller.text, '1.000,00');
    });
  });

  group('AppTextField without external dependencies', () {
    testWidgets('should type and show the clear button with no focusNode and no controller', (tester) async {
      await pumpField(tester, const AppTextField(hintText: 'Descrição'));

      expect(find.byIcon(Icons.close), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(find.text('abc'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should follow a controller swapped after the first build', (tester) async {
      await pumpField(tester, const AppTextField(hintText: 'Descrição'));

      final TextEditingController swapped = TextEditingController();
      addTearDown(swapped.dispose);

      await pumpField(tester, AppTextField(controller: swapped, hintText: 'Descrição'));

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(swapped.text, 'abc');
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    test('should reject initialValue together with a controller', () {
      expect(
        () => AppTextField(controller: controller, initialValue: 'abc'),
        throwsAssertionError,
      );
    });

    testWidgets('should adopt a focusNode given after the first build', (tester) async {
      await pumpField(tester, const AppTextField(hintText: 'Descrição'));

      final FocusNode adopted = FocusNode();
      addTearDown(adopted.dispose);

      await pumpField(tester, AppTextField(focusNode: adopted, hintText: 'Descrição'));

      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      expect(adopted.hasFocus, isTrue);
    });

    testWidgets('should open on initialValue, clear button included', (tester) async {
      await pumpField(tester, const AppTextField(hintText: 'Descrição', initialValue: 'abc'));

      expect(find.text('abc'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not dispose a controller that came from outside', (tester) async {
      final TextEditingController external = TextEditingController(text: 'abc');

      await pumpField(tester, AppTextField(controller: external, hintText: 'Descrição'));
      await tester.pumpWidget(const SizedBox());

      expect(() => external.value = const TextEditingValue(text: 'still alive'), returnsNormally);
      external.dispose();
    });
  });

  group('AppTextField.decoration', () {
    testWidgets('should show the helper, and give the slot to the error text', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          decoration: const InputDecoration(helperText: 'Como aparece na etiqueta'),
        ),
      );

      expect(find.text('Como aparece na etiqueta'), findsOneWidget);

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          errorText: 'Informe a descrição',
          decoration: const InputDecoration(helperText: 'Como aparece na etiqueta'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Como aparece na etiqueta'), findsNothing);
      expect(find.text('Informe a descrição'), findsOneWidget);
    });

    testWidgets('should keep errorMaxLines so a long message is shown whole', (tester) async {
      const String message = 'Informe a descrição do produto com pelo menos três palavras '
          'para que ela apareça inteira na etiqueta impressa da prateleira.';

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          errorText: message,
          decoration: const InputDecoration(errorMaxLines: 3),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).decoration!.errorMaxLines, 3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should show prefixText on an empty field', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Altura',
          decoration: const InputDecoration(prefixText: 'até '),
        ),
      );

      expect(find.text('até '), findsOneWidget);
    });

    testWidgets('should show prefixIcon and keep the clear button working', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Buscar',
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, '');
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should keep a fillColor from the decoration while the field is not disabled', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          decoration: const InputDecoration(fillColor: Color(0xFF112233)),
        ),
      );

      expect(tester.widget<TextField>(find.byType(TextField)).decoration!.fillColor, const Color(0xFF112233));
    });

    testWidgets('should show a suffixIcon from the decoration when the clear button is off', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          showClearButton: false,
          decoration: const InputDecoration(suffixIcon: Icon(Icons.info_outline)),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should take the label from the decoration, and let hintText win over it', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
      );

      expect(find.text('Descrição'), findsOneWidget);

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Observação',
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
      );

      expect(find.text('Descrição'), findsNothing);
      expect(find.text('Observação'), findsWidgets);
    });
  });

  group('AppTextField.enabled', () {
    testWidgets('should refuse typing without dimming the field', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          enabled: false,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(controller.text, '');
      expect(tester.widget<TextField>(find.byType(TextField)).decoration!.fillColor, isNull);
    });

    testWidgets('should hide the clear button on a field with text', (tester) async {
      controller.text = 'abc';

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          enabled: false,
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('AppTextField.showClearButton', () {
    testWidgets('should hide the clear button on a field with text', (tester) async {
      controller.text = 'abc';

      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          showClearButton: false,
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('AppTextField.autofocus', () {
    testWidgets('should take the focus as soon as the field is shown', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Descrição',
          autofocus: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isTrue);
    });
  });

  group('AppTextField keyboard settings', () {
    testWidgets('should forward textCapitalization and textInputAction', (tester) async {
      await pumpField(
        tester,
        AppTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: 'Buscar',
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
        ),
      );

      final TextField field = tester.widget<TextField>(find.byType(TextField));

      expect(field.textCapitalization, TextCapitalization.none);
      expect(field.textInputAction, TextInputAction.next);
    });
  });

  group('AppTextField factories', () {
    final Map<String, AppTextField Function()> factories = <String, AppTextField Function()>{
      'unit': () => AppTextField.unit(
            spec: UnitSpec.weight,
            initialValue: '1.000,000',
            decoration: const InputDecoration(helperText: 'Peso líquido'),
            enabled: false,
            showClearButton: false,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
          ),
      'currency': () => AppTextField.currency(
            initialValue: '1.000,000',
            decoration: const InputDecoration(helperText: 'Peso líquido'),
            enabled: false,
            showClearButton: false,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
          ),
      'weight': () => AppTextField.weight(
            initialValue: '1.000,000',
            decoration: const InputDecoration(helperText: 'Peso líquido'),
            enabled: false,
            showClearButton: false,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
          ),
      'length': () => AppTextField.length(
            initialValue: '1.000,000',
            decoration: const InputDecoration(helperText: 'Peso líquido'),
            enabled: false,
            showClearButton: false,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
          ),
      'volume': () => AppTextField.volume(
            initialValue: '1.000,000',
            decoration: const InputDecoration(helperText: 'Peso líquido'),
            enabled: false,
            showClearButton: false,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
          ),
    };

    for (final MapEntry<String, AppTextField Function()> entry in factories.entries) {
      testWidgets('${entry.key} should build without focusNode, controller or hintText and forward every parameter',
          (tester) async {
        await pumpField(tester, entry.value());
        await tester.pumpAndSettle();

        final TextField field = tester.widget<TextField>(find.byType(TextField));

        expect(find.text('1.000,000'), findsOneWidget);
        expect(find.text('Peso líquido'), findsOneWidget);
        expect(field.enabled, isFalse);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(field.autofocus, isTrue);
        expect(field.textCapitalization, TextCapitalization.none);
        expect(field.textInputAction, TextInputAction.next);
      });
    }
  });
}
