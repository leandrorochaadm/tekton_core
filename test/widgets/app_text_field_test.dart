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

      expect(controller.text, '1.000,00');
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

      expect(controller.text, '1.000');
    });
  });
}
