import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:care247_assignment/data/customer_api.dart';
import 'package:care247_assignment/data/customer_repository.dart';
import 'package:care247_assignment/models/customer.dart';
import 'package:care247_assignment/state/customer_search_state.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late MockCustomerRepository mockRepository;
  late CustomerSearchState state;

  final sampleCustomers = [
    Customer.fromJson({
      'id': '1',
      'firstName': 'John',
      'lastName': 'Smith',
      'dateOfBirth': '1985-03-15',
      'maritalStatus': 'Married',
      'secureId': 'SSN-XXX-XX-1234',
      'addresses': [],
      'phones': [],
      'emails': [],
    }),
  ];

  setUp(() {
    mockRepository = MockCustomerRepository();
    state = CustomerSearchState(repository: mockRepository);
  });

  tearDown(() {
    state.dispose();
  });

  group('Initial state', () {
    test('starts with initial status', () {
      expect(state.status, SearchStatus.initial);
    });

    test('starts with empty customers list', () {
      expect(state.customers, isEmpty);
    });

    test('starts with empty error message', () {
      expect(state.errorMessage, isEmpty);
    });

    test('hasSearchCriteria is false initially', () {
      expect(state.hasSearchCriteria, isFalse);
    });
  });

  group('updateCriterion', () {
    test('updates search criteria', () {
      state.updateCriterion('firstName', 'John');

      expect(state.searchCriteria['firstName'], 'John');
    });

    test('hasSearchCriteria is true when a criterion has value', () {
      state.updateCriterion('firstName', 'John');

      expect(state.hasSearchCriteria, isTrue);
    });

    test('hasSearchCriteria is false when criterion is empty', () {
      state.updateCriterion('firstName', '   ');

      expect(state.hasSearchCriteria, isFalse);
    });
  });

  group('clearSearch', () {
    test('resets all state to initial', () {
      state.updateCriterion('firstName', 'John');
      state.clearSearch();

      expect(state.status, SearchStatus.initial);
      expect(state.customers, isEmpty);
      expect(state.errorMessage, isEmpty);
      expect(state.searchCriteria, isEmpty);
    });
  });

  group('searchCustomers', () {
    test('transitions to loading then success with results', () async {
      when(() => mockRepository.searchCustomers(any()))
          .thenAnswer((_) async => sampleCustomers);

      final statusLog = <SearchStatus>[];
      state.addListener(() => statusLog.add(state.status));

      await state.searchCustomers();

      expect(statusLog, [SearchStatus.loading, SearchStatus.success]);
      expect(state.customers, hasLength(1));
      expect(state.customers.first.firstName, 'John');
    });

    test('transitions to empty when no results', () async {
      when(() => mockRepository.searchCustomers(any()))
          .thenAnswer((_) async => []);

      await state.searchCustomers();

      expect(state.status, SearchStatus.empty);
      expect(state.customers, isEmpty);
    });

    test('transitions to error on API exception', () async {
      when(() => mockRepository.searchCustomers(any()))
          .thenThrow(const CustomerApiException('Network error'));

      await state.searchCustomers();

      expect(state.status, SearchStatus.error);
      expect(state.errorMessage, 'Network error');
    });

    test('transitions to error on unexpected exception', () async {
      when(() => mockRepository.searchCustomers(any()))
          .thenThrow(Exception('unexpected'));

      await state.searchCustomers();

      expect(state.status, SearchStatus.error);
      expect(state.errorMessage, contains('unexpected error'));
    });

    test('passes current criteria to repository', () async {
      when(() => mockRepository.searchCustomers(any()))
          .thenAnswer((_) async => []);

      state.updateCriterion('firstName', 'Jane');
      state.updateCriterion('lastName', 'Doe');

      await state.searchCustomers();

      final captured =
          verify(() => mockRepository.searchCustomers(captureAny()))
                  .captured
                  .first
              as Map<String, String>;

      expect(captured['firstName'], 'Jane');
      expect(captured['lastName'], 'Doe');
    });
  });

  group('refreshResults', () {
    test('re-executes the search', () async {
      when(() => mockRepository.searchCustomers(any()))
          .thenAnswer((_) async => sampleCustomers);

      await state.refreshResults();

      verify(() => mockRepository.searchCustomers(any())).called(1);
      expect(state.status, SearchStatus.success);
    });
  });
}
