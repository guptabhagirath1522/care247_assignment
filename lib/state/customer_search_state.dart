import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../data/customer_api.dart';
import '../data/customer_repository.dart';
import '../models/customer.dart';

enum SearchStatus { initial, loading, success, empty, error }

class CustomerSearchState extends ChangeNotifier {
  final CustomerRepository _repository;

  CustomerSearchState({CustomerRepository? repository})
      : _repository = repository ?? CustomerRepository();

  SearchStatus _status = SearchStatus.initial;
  List<Customer> _customers = [];
  String _errorMessage = '';
  Map<String, String> _searchCriteria = {};
  bool _isDisposed = false;

  SearchStatus get status => _status;
  List<Customer> get customers => List.unmodifiable(_customers);
  String get errorMessage => _errorMessage;
  Map<String, String> get searchCriteria => Map.unmodifiable(_searchCriteria);
  bool get isDemoMode => _repository.isDemoMode;
  String get activeEndpoint => AppConfig.activeBaseUrl;
  CustomerRepository get repository => _repository;

  bool get hasSearchCriteria =>
      _searchCriteria.values.any((v) => v.trim().isNotEmpty);

  void updateCriterion(String key, String value) {
    _searchCriteria = {..._searchCriteria, key: value};
  }

  void clearSearch() {
    _searchCriteria = {};
    _customers = [];
    _errorMessage = '';
    _status = SearchStatus.initial;
    notifyListeners();
  }

  void setDemoMode(bool enabled) {
    if (_repository.isDemoMode != enabled) {
      _repository.isDemoMode = enabled;
      notifyListeners();
    }
  }

  Future<void> useDemoDataAndSearch() async {
    _repository.isDemoMode = true;
    await searchCustomers();
  }

  Future<void> switchToLiveAndSearch(String url) async {
    AppConfig.activeBaseUrl = url;
    _repository.isDemoMode = false;
    await searchCustomers();
  }

  Future<void> searchCustomers() async {
    _status = SearchStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _repository.searchCustomers(_searchCriteria);

      if (_isDisposed) return;

      _customers = results;
      _status = results.isEmpty ? SearchStatus.empty : SearchStatus.success;
    } on CustomerApiException catch (e) {
      if (_isDisposed) return;
      _errorMessage = e.message;
      _status = SearchStatus.error;
    } catch (e) {
      if (_isDisposed) return;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _status = SearchStatus.error;
    }

    notifyListeners();
  }

  Future<void> refreshResults() async {
    await searchCustomers();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _repository.dispose();
    super.dispose();
  }
}
