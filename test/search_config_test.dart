import 'package:flutter_test/flutter_test.dart';

import 'package:care247_assignment/config/search_config.dart';

void main() {
  group('FieldConfig', () {
    test('searchConfig contains expected default fields', () {
      expect(searchConfig, isNotEmpty);
      expect(searchConfig.length, greaterThanOrEqualTo(3));
    });

    test('searchConfig contains firstName, lastName, dateOfBirth', () {
      final keys = searchConfig.map((c) => c.key).toList();

      expect(keys, contains('firstName'));
      expect(keys, contains('lastName'));
      expect(keys, contains('dateOfBirth'));
    });

    test('firstName field has correct configuration', () {
      final field = searchConfig.firstWhere((c) => c.key == 'firstName');

      expect(field.type, FieldType.text);
      expect(field.label, 'First Name');
      expect(field.placeholder, isNotNull);
      expect(field.renderOrder, 1);
    });

    test('dateOfBirth field has date type', () {
      final field = searchConfig.firstWhere((c) => c.key == 'dateOfBirth');

      expect(field.type, FieldType.date);
      expect(field.placeholder, 'YYYY-MM-DD');
      expect(field.renderOrder, 3);
    });

    test('fields are sortable by renderOrder', () {
      final sorted = List<FieldConfig>.from(searchConfig)
        ..sort((a, b) => a.renderOrder.compareTo(b.renderOrder));

      for (int i = 1; i < sorted.length; i++) {
        expect(
          sorted[i].renderOrder,
          greaterThanOrEqualTo(sorted[i - 1].renderOrder),
        );
      }
    });

    test('all fields have non-empty keys and labels', () {
      for (final config in searchConfig) {
        expect(config.key, isNotEmpty);
        expect(config.label, isNotEmpty);
      }
    });

    test('FieldType enum has expected values', () {
      expect(FieldType.values, contains(FieldType.text));
      expect(FieldType.values, contains(FieldType.date));
      expect(FieldType.values, contains(FieldType.dropdown));
    });

    test('a new field can be added to the configuration', () {
      final extendedConfig = [
        ...searchConfig,
        const FieldConfig(
          key: 'maritalStatus',
          type: FieldType.dropdown,
          label: 'Marital Status',
          placeholder: 'Select marital status',
          renderOrder: 4,
          options: ['Single', 'Married', 'Divorced', 'Widowed'],
        ),
      ];

      expect(extendedConfig.length, searchConfig.length + 1);

      final maritalField = extendedConfig.firstWhere(
        (c) => c.key == 'maritalStatus',
      );
      expect(maritalField.type, FieldType.dropdown);
      expect(maritalField.options, isNotNull);
      expect(maritalField.options, hasLength(4));
    });
  });
}
