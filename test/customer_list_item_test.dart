import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:care247_assignment/models/customer.dart';
import 'package:care247_assignment/widgets/customer_list_item.dart';

void main() {
  final sampleCustomer = Customer.fromJson({
    'id': '1',
    'firstName': 'John',
    'lastName': 'Smith',
    'dateOfBirth': '1985-03-15',
    'maritalStatus': 'Married',
    'secureId': 'SSN-XXX-XX-1234',
    'addresses': [],
    'phones': [
      {
        'id': 'p1',
        'type': 'Mobile',
        'number': '(555) 123-4567',
        'isPrimary': true,
      },
    ],
    'emails': [
      {
        'id': 'e1',
        'type': 'Personal',
        'address': 'john.smith@email.com',
        'isPrimary': true,
      },
    ],
  });

  Widget buildTestWidget(CustomerListItem item) {
    return MaterialApp(home: Scaffold(body: item));
  }

  testWidgets('displays customer full name', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(CustomerListItem(customer: sampleCustomer, onTap: () {})),
    );

    expect(find.text('John Smith'), findsOneWidget);
  });

  testWidgets('displays formatted date of birth', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(CustomerListItem(customer: sampleCustomer, onTap: () {})),
    );

    expect(find.text('Mar 15, 1985'), findsOneWidget);
  });

  testWidgets('displays primary phone number', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(CustomerListItem(customer: sampleCustomer, onTap: () {})),
    );

    expect(find.text('(555) 123-4567'), findsOneWidget);
  });

  testWidgets('displays primary email address', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(CustomerListItem(customer: sampleCustomer, onTap: () {})),
    );

    expect(find.text('john.smith@email.com'), findsOneWidget);
  });

  testWidgets('calls onTap when tapped', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      buildTestWidget(
        CustomerListItem(customer: sampleCustomer, onTap: () => tapped = true),
      ),
    );

    await tester.tap(find.byType(CustomerListItem));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('handles customer with no phones or emails gracefully', (
    WidgetTester tester,
  ) async {
    final customerNoContacts = Customer.fromJson({
      'id': '2',
      'firstName': 'Jane',
      'lastName': 'Doe',
      'dateOfBirth': '1990-07-22',
      'maritalStatus': 'Single',
      'secureId': 'SSN-XXX-XX-5678',
      'addresses': [],
      'phones': [],
      'emails': [],
    });

    await tester.pumpWidget(
      buildTestWidget(
        CustomerListItem(customer: customerNoContacts, onTap: () {}),
      ),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
  });
}
