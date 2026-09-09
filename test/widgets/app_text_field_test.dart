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
}
