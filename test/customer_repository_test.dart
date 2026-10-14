import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:care247_assignment/data/customer_api.dart';
import 'package:care247_assignment/data/customer_repository.dart';
import 'package:care247_assignment/models/customer.dart';

class MockCustomerApi extends Mock implements CustomerApi {}

void main() {
  late MockCustomerApi mockApi;
  late CustomerRepository repository;

  final sampleData = [
    {
      'id': '1',
      'firstName': 'John',
      'lastName': 'Smith',
      'dateOfBirth': '1985-03-15',
      'maritalStatus': 'Married',
      'secureId': 'SSN-123',
      'addresses': [],
      'phones': [],
      'emails': [],
    },
    {
      'id': '2',
      'firstName': 'Jane',
      'lastName': 'Doe',
      'dateOfBirth': '1990-07-22',
      'maritalStatus': 'Single',
      'secureId': 'SSN-456',
      'addresses': [],
      'phones': [],
      'emails': [],
    },
  ];

  final sampleCustomers =
      sampleData.map((d) => Customer.fromJson(d)).toList();

  final mockAssetString = json.encode({'customers': sampleData});

  setUp(() {
    mockApi = MockCustomerApi();
    repository = CustomerRepository(
      api: mockApi,
      bundledAssetLoader: () async => mockAssetString,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  group('CustomerRepository - Live API mode', () {
    test('fetches all customers when criteria is empty', () async {
      when(() => mockApi.searchCustomers({})).thenAnswer((_) async => sampleCustomers);

      final results = await repository.searchCustomers({});

      expect(results, hasLength(2));
      verify(() => mockApi.searchCustomers({})).called(1);
    });

    test('filters customers by firstName case-insensitively', () async {
      when(() => mockApi.searchCustomers({})).thenAnswer((_) async => sampleCustomers);

      final results = await repository.searchCustomers({'firstName': 'john'});

      expect(results, hasLength(1));
      expect(results.first.firstName, 'John');
    });

    test('filters customers by maritalStatus', () async {
      when(() => mockApi.searchCustomers({})).thenAnswer((_) async => sampleCustomers);

      final results = await repository.searchCustomers({'maritalStatus': 'single'});

      expect(results, hasLength(1));
      expect(results.first.firstName, 'Jane');
    });

    test('filters customers by normalized date format (YYYY-MM-DD)', () async {
      when(() => mockApi.searchCustomers({})).thenAnswer((_) async => sampleCustomers);

      final results = await repository.searchCustomers({'dateOfBirth': '1985-03-15'});

      expect(results, hasLength(1));
      expect(results.first.firstName, 'John');
    });

    test('filters customers by alternative date format (DD/MM/YYYY)', () async {
      when(() => mockApi.searchCustomers({})).thenAnswer((_) async => sampleCustomers);

      final results = await repository.searchCustomers({'dateOfBirth': '15/03/1985'});

      expect(results, hasLength(1));
      expect(results.first.firstName, 'John');
    });
  });

  group('CustomerRepository - Offline Demo mode', () {
    test('loads and filters from bundled asset when isDemoMode is true', () async {
      repository.isDemoMode = true;

      final results = await repository.searchCustomers({'firstName': 'Jane'});

      expect(results, hasLength(1));
      expect(results.first.firstName, 'Jane');
      verifyNever(() => mockApi.searchCustomers(any()));
    });

    test('getCustomerById retrieves correct customer in demo mode', () async {
      repository.isDemoMode = true;

      final customer = await repository.getCustomerById('2');

      expect(customer.firstName, 'Jane');
      expect(customer.id, '2');
    });

    test('getCustomerById throws when customer not found in demo mode', () async {
      repository.isDemoMode = true;

      expect(
        () => repository.getCustomerById('999'),
        throwsA(isA<CustomerApiException>()),
      );
    });
  });
}
