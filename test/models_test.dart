import 'package:flutter_test/flutter_test.dart';

import 'package:care247_assignment/models/address.dart';
import 'package:care247_assignment/models/customer.dart';
import 'package:care247_assignment/models/email.dart';
import 'package:care247_assignment/models/phone.dart';

void main() {
  group('Address', () {
    test('fromJson creates a valid Address', () {
      final json = {
        'id': 'a1',
        'type': 'Home',
        'street': '123 Oak Street',
        'city': 'Springfield',
        'state': 'IL',
        'zipCode': '62701',
      };

      final address = Address.fromJson(json);

      expect(address.id, 'a1');
      expect(address.type, 'Home');
      expect(address.street, '123 Oak Street');
      expect(address.city, 'Springfield');
      expect(address.state, 'IL');
      expect(address.zipCode, '62701');
    });

    test('toJson produces correct map', () {
      const address = Address(
        id: 'a1',
        type: 'Home',
        street: '123 Oak Street',
        city: 'Springfield',
        state: 'IL',
        zipCode: '62701',
      );

      final json = address.toJson();

      expect(json['id'], 'a1');
      expect(json['type'], 'Home');
      expect(json['street'], '123 Oak Street');
    });

    test('formatted returns correct string', () {
      const address = Address(
        id: 'a1',
        type: 'Home',
        street: '123 Oak Street',
        city: 'Springfield',
        state: 'IL',
        zipCode: '62701',
      );

      expect(address.formatted, '123 Oak Street, Springfield, IL 62701');
    });

    test('equality compares all fields', () {
      const a = Address(
        id: 'a1',
        type: 'Home',
        street: '123',
        city: 'C',
        state: 'S',
        zipCode: '00000',
      );
      const b = Address(
        id: 'a1',
        type: 'Home',
        street: '123',
        city: 'C',
        state: 'S',
        zipCode: '00000',
      );
      const c = Address(
        id: 'a2',
        type: 'Home',
        street: '123',
        city: 'C',
        state: 'S',
        zipCode: '00000',
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('Phone', () {
    test('fromJson creates a valid Phone', () {
      final json = {
        'id': 'p1',
        'type': 'Mobile',
        'number': '(555) 123-4567',
        'isPrimary': true,
      };

      final phone = Phone.fromJson(json);

      expect(phone.id, 'p1');
      expect(phone.type, 'Mobile');
      expect(phone.number, '(555) 123-4567');
      expect(phone.isPrimary, isTrue);
    });

    test('toJson produces correct map', () {
      const phone = Phone(
        id: 'p1',
        type: 'Mobile',
        number: '(555) 123-4567',
        isPrimary: true,
      );

      final json = phone.toJson();

      expect(json['isPrimary'], isTrue);
      expect(json['number'], '(555) 123-4567');
    });
  });

  group('Email', () {
    test('fromJson creates a valid Email', () {
      final json = {
        'id': 'e1',
        'type': 'Personal',
        'address': 'test@email.com',
        'isPrimary': true,
      };

      final email = Email.fromJson(json);

      expect(email.id, 'e1');
      expect(email.type, 'Personal');
      expect(email.address, 'test@email.com');
      expect(email.isPrimary, isTrue);
    });
  });

  group('Customer', () {
    late Map<String, dynamic> sampleCustomerJson;

    setUp(() {
      sampleCustomerJson = {
        'id': '1',
        'firstName': 'John',
        'lastName': 'Smith',
        'dateOfBirth': '1985-03-15',
        'maritalStatus': 'Married',
        'secureId': 'SSN-XXX-XX-1234',
        'addresses': [
          {
            'id': 'a1',
            'type': 'Home',
            'street': '123 Oak Street',
            'city': 'Springfield',
            'state': 'IL',
            'zipCode': '62701',
          },
        ],
        'phones': [
          {
            'id': 'p1',
            'type': 'Mobile',
            'number': '(555) 123-4567',
            'isPrimary': true,
          },
          {
            'id': 'p2',
            'type': 'Work',
            'number': '(555) 234-5678',
            'isPrimary': false,
          },
        ],
        'emails': [
          {
            'id': 'e1',
            'type': 'Personal',
            'address': 'john.smith@email.com',
            'isPrimary': true,
          },
          {
            'id': 'e2',
            'type': 'Work',
            'address': 'jsmith@company.com',
            'isPrimary': false,
          },
        ],
      };
    });

    test('fromJson creates a valid Customer with nested models', () {
      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.id, '1');
      expect(customer.firstName, 'John');
      expect(customer.lastName, 'Smith');
      expect(customer.dateOfBirth, '1985-03-15');
      expect(customer.maritalStatus, 'Married');
      expect(customer.secureId, 'SSN-XXX-XX-1234');
      expect(customer.addresses, hasLength(1));
      expect(customer.phones, hasLength(2));
      expect(customer.emails, hasLength(2));
    });

    test('fromJson correctly parses nested addresses', () {
      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.addresses.first.type, 'Home');
      expect(customer.addresses.first.street, '123 Oak Street');
    });

    test('fromJson correctly parses nested phones', () {
      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.phones.first.type, 'Mobile');
      expect(customer.phones.first.isPrimary, isTrue);
      expect(customer.phones[1].isPrimary, isFalse);
    });

    test('fromJson correctly parses nested emails', () {
      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.emails.first.address, 'john.smith@email.com');
      expect(customer.emails.first.isPrimary, isTrue);
    });

    test('fullName returns concatenated first and last name', () {
      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.fullName, 'John Smith');
    });

    test('primaryPhone returns the phone marked as primary', () {
      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.primaryPhone, isNotNull);
      expect(customer.primaryPhone!.number, '(555) 123-4567');
      expect(customer.primaryPhone!.isPrimary, isTrue);
    });

    test('primaryEmail returns the email marked as primary', () {
      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.primaryEmail, isNotNull);
      expect(customer.primaryEmail!.address, 'john.smith@email.com');
      expect(customer.primaryEmail!.isPrimary, isTrue);
    });

    test('primaryPhone returns first phone when none is primary', () {
      sampleCustomerJson['phones'] = [
        {
          'id': 'p1',
          'type': 'Mobile',
          'number': '(555) 111-1111',
          'isPrimary': false,
        },
      ];

      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.primaryPhone, isNotNull);
      expect(customer.primaryPhone!.number, '(555) 111-1111');
    });

    test('primaryPhone returns null when phones list is empty', () {
      sampleCustomerJson['phones'] = [];

      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.primaryPhone, isNull);
    });

    test('toJson produces correct map with nested models', () {
      final customer = Customer.fromJson(sampleCustomerJson);
      final json = customer.toJson();

      expect(json['id'], '1');
      expect(json['firstName'], 'John');
      expect(json['addresses'], isList);
      expect((json['addresses'] as List).first['type'], 'Home');
    });

    test('copyWith creates a modified copy', () {
      final customer = Customer.fromJson(sampleCustomerJson);
      final modified = customer.copyWith(firstName: 'Jane');

      expect(modified.firstName, 'Jane');
      expect(modified.lastName, 'Smith');
      expect(modified.id, '1');
    });

    test('equality is based on id', () {
      final a = Customer.fromJson(sampleCustomerJson);
      final b = Customer.fromJson(sampleCustomerJson);

      expect(a, equals(b));
    });

    test('fromJson handles empty nested lists', () {
      sampleCustomerJson['addresses'] = [];
      sampleCustomerJson['phones'] = [];
      sampleCustomerJson['emails'] = [];

      final customer = Customer.fromJson(sampleCustomerJson);

      expect(customer.addresses, isEmpty);
      expect(customer.phones, isEmpty);
      expect(customer.emails, isEmpty);
    });
  });
}
