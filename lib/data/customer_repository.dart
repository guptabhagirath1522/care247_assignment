import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/customer.dart';
import 'customer_api.dart';

class CustomerRepository {
  final CustomerApi _api;
  final Future<String> Function()? bundledAssetLoader;
  bool isDemoMode = false;
  List<Customer>? _cachedBundledCustomers;

  CustomerRepository({
    CustomerApi? api,
    this.bundledAssetLoader,
  }) : _api = api ?? CustomerApi();

  Future<List<Customer>> searchCustomers(Map<String, String> criteria) async {
    final activeCriteria = <String, String>{};
    for (final entry in criteria.entries) {
      final value = entry.value.trim();
      if (value.isNotEmpty) {
        activeCriteria[entry.key] = value;
      }
    }

    final List<Customer> allCustomers;
    if (isDemoMode) {
      allCustomers = await loadBundledCustomers();
    } else {
      allCustomers = await _api.searchCustomers({});
    }

    if (activeCriteria.isEmpty) {
      return allCustomers;
    }

    return allCustomers.where((customer) {
      for (final entry in activeCriteria.entries) {
        final key = entry.key;
        final query = entry.value.toLowerCase();

        if (key == 'firstName') {
          if (!customer.firstName.toLowerCase().contains(query)) return false;
        } else if (key == 'lastName') {
          if (!customer.lastName.toLowerCase().contains(query)) return false;
        } else if (key == 'dateOfBirth') {
          if (!_matchesDate(customer.dateOfBirth, entry.value)) return false;
        } else if (key == 'maritalStatus') {
          if (customer.maritalStatus.toLowerCase() != query) return false;
        }
      }
      return true;
    }).toList();
  }

  Future<List<Customer>> loadBundledCustomers() async {
    if (_cachedBundledCustomers != null) {
      return _cachedBundledCustomers!;
    }

    final String jsonString;
    final loader = bundledAssetLoader;
    if (loader != null) {
      jsonString = await loader();
    } else {
      jsonString = await rootBundle.loadString('db.json');
    }

    final dynamic decoded = json.decode(jsonString);
    if (decoded is Map<String, dynamic> && decoded['customers'] is List) {
      _cachedBundledCustomers = (decoded['customers'] as List)
          .map((item) => Customer.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedBundledCustomers!;
    }

    return [];
  }

  bool _matchesDate(String customerDate, String queryDate) {
    if (customerDate == queryDate) return true;
    final cNorm = _normalizeDate(customerDate);
    final qNorm = _normalizeDate(queryDate);
    if (cNorm != null && qNorm != null) {
      return cNorm == qNorm;
    }
    return false;
  }

  String? _normalizeDate(String dateStr) {
    final clean = dateStr.trim();
    try {
      final d = DateTime.parse(clean);
      return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {}
    final parts = clean.split(RegExp(r'[/ -]'));
    if (parts.length == 3) {
      if (parts[0].length <= 2 && parts[2].length == 4) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        }
      }
    }
    return null;
  }

  Future<Customer> getCustomerById(String id) async {
    if (isDemoMode) {
      final list = await loadBundledCustomers();
      return list.firstWhere(
        (c) => c.id == id,
        orElse: () => throw const CustomerApiException('Customer not found.'),
      );
    }
    return _api.getCustomerById(id);
  }

  CustomerApi get api => _api;

  void dispose() {
    _api.dispose();
  }
}
