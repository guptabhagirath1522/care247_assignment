import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:care247_assignment/config/search_config.dart';
import 'package:care247_assignment/widgets/dynamic_field.dart';

void main() {
  Widget buildTestWidget(DynamicField field) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: field),
      ),
    );
  }

  group('DynamicField - Text type', () {
    testWidgets('renders a text field with label and placeholder', (
      WidgetTester tester,
    ) async {
      const config = FieldConfig(
        key: 'firstName',
        type: FieldType.text,
        label: 'First Name',
        placeholder: 'Enter first name',
        renderOrder: 1,
      );

      await tester.pumpWidget(
        buildTestWidget(
          DynamicField(config: config, value: '', onChanged: (_) {}),
        ),
      );

      expect(find.text('First Name'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (
      WidgetTester tester,
    ) async {
      String? changedValue;
      const config = FieldConfig(
        key: 'lastName',
        type: FieldType.text,
        label: 'Last Name',
        placeholder: 'Enter last name',
        renderOrder: 2,
      );

      await tester.pumpWidget(
        buildTestWidget(
          DynamicField(
            config: config,
            value: '',
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Smith');

      expect(changedValue, 'Smith');
    });
  });

  group('DynamicField - Date type', () {
    testWidgets(
      'renders a date field with calendar icon and YYYY-MM-DD placeholder',
      (WidgetTester tester) async {
        const config = FieldConfig(
          key: 'dateOfBirth',
          type: FieldType.date,
          label: 'Date of Birth',
          placeholder: 'YYYY-MM-DD',
          renderOrder: 3,
        );

        await tester.pumpWidget(
          buildTestWidget(
            DynamicField(config: config, value: '', onChanged: (_) {}),
          ),
        );

        expect(find.text('Date of Birth'), findsOneWidget);
        expect(find.text('YYYY-MM-DD'), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      },
    );

    testWidgets('displays formatted date when value is provided', (
      WidgetTester tester,
    ) async {
      const config = FieldConfig(
        key: 'dateOfBirth',
        type: FieldType.date,
        label: 'Date of Birth',
        placeholder: 'YYYY-MM-DD',
        renderOrder: 3,
      );

      await tester.pumpWidget(
        buildTestWidget(
          DynamicField(config: config, value: '1985-03-15', onChanged: (_) {}),
        ),
      );

      expect(find.text('1985-03-15'), findsOneWidget);
    });

    testWidgets('updates displayed date when value changes dynamically', (
      WidgetTester tester,
    ) async {
      const config = FieldConfig(
        key: 'dateOfBirth',
        type: FieldType.date,
        label: 'Date of Birth',
        placeholder: 'YYYY-MM-DD',
        renderOrder: 3,
      );

      await tester.pumpWidget(
        buildTestWidget(
          DynamicField(config: config, value: '', onChanged: (_) {}),
        ),
      );

      expect(find.text('1985-03-15'), findsNothing);

      await tester.pumpWidget(
        buildTestWidget(
          DynamicField(config: config, value: '1985-03-15', onChanged: (_) {}),
        ),
      );

      expect(find.text('1985-03-15'), findsOneWidget);
    });

    testWidgets('clears displayed date when clear icon is pressed', (
      WidgetTester tester,
    ) async {
      String? changedValue = '1985-03-15';
      const config = FieldConfig(
        key: 'dateOfBirth',
        type: FieldType.date,
        label: 'Date of Birth',
        placeholder: 'YYYY-MM-DD',
        renderOrder: 3,
      );

      await tester.pumpWidget(
        buildTestWidget(
          DynamicField(
            config: config,
            value: '1985-03-15',
            onChanged: (val) => changedValue = val,
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(changedValue, '');
    });
  });

  group('DynamicField - Dropdown type', () {
    testWidgets('renders a dropdown with options', (WidgetTester tester) async {
      const config = FieldConfig(
        key: 'maritalStatus',
        type: FieldType.dropdown,
        label: 'Marital Status',
        placeholder: 'Select marital status',
        renderOrder: 4,
        options: ['Single', 'Married', 'Divorced'],
      );

      await tester.pumpWidget(
        buildTestWidget(
          DynamicField(config: config, value: '', onChanged: (_) {}),
        ),
      );

      expect(find.text('Marital Status'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });
  });
}
