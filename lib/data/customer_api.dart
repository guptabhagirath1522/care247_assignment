import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/customer.dart';

class CustomerApiException implements Exception {
  final String message;
  final int? statusCode;

  const CustomerApiException(this.message, {this.statusCode});

  @override
  String toString() => 'CustomerApiException: $message (status: $statusCode)';
}

class CustomerApi {
  final http.Client _client;
  final Duration _requestTimeout;
  final Duration _probeTimeout;

  CustomerApi({
    http.Client? client,
    Duration? requestTimeout,
    Duration? probeTimeout,
  })  : _client = client ?? http.Client(),
        _requestTimeout = requestTimeout ?? const Duration(seconds: 4),
        _probeTimeout = probeTimeout ?? const Duration(milliseconds: 1500);

  Future<List<Customer>> searchCustomers(
    Map<String, String> queryParameters,
  ) async {
    try {
      return await _executeSearch(
        AppConfig.customersUrl,
        queryParameters,
      );
    } on SocketException catch (_) {
      return await _retryWithAutoDiscovery(
        (url) => _executeSearch(url, queryParameters),
      );
    } on TimeoutException catch (_) {
      return await _retryWithAutoDiscovery(
        (url) => _executeSearch(url, queryParameters),
      );
    } on http.ClientException catch (_) {
      return await _retryWithAutoDiscovery(
        (url) => _executeSearch(url, queryParameters),
      );
    }
  }

  Future<Customer> getCustomerById(String id) async {
    try {
      return await _executeGetById('${AppConfig.customersUrl}/$id');
    } on SocketException catch (_) {
      return await _retryWithAutoDiscovery(
        (url) => _executeGetById('$url/$id'),
      );
    } on TimeoutException catch (_) {
      return await _retryWithAutoDiscovery(
        (url) => _executeGetById('$url/$id'),
      );
    } on http.ClientException catch (_) {
      return await _retryWithAutoDiscovery(
        (url) => _executeGetById('$url/$id'),
      );
    }
  }

  Future<List<Customer>> _executeSearch(
    String baseUrl,
    Map<String, String> queryParameters,
  ) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          return decoded
              .map((item) => Customer.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        throw const CustomerApiException(
          'Unexpected response format from server.',
        );
      }

      throw CustomerApiException(
        'Server returned an error. Please try again.',
        statusCode: response.statusCode,
      );
    } on FormatException {
      throw const CustomerApiException(
        'Received an invalid response from the server.',
      );
    }
  }

  Future<Customer> _executeGetById(String fullUrl) async {
    final uri = Uri.parse(fullUrl);

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        return Customer.fromJson(decoded as Map<String, dynamic>);
      }

      if (response.statusCode == 404) {
        throw const CustomerApiException('Customer not found.');
      }

      throw CustomerApiException(
        'Server returned an error. Please try again.',
        statusCode: response.statusCode,
      );
    } on FormatException {
      throw const CustomerApiException(
        'Received an invalid response from the server.',
      );
    }
  }

  Future<T> _retryWithAutoDiscovery<T>(
    Future<T> Function(String customersUrl) operation,
  ) async {
    final workingHost = await autoDiscoverWorkingHost();
    if (workingHost != null) {
      AppConfig.activeBaseUrl = workingHost;
      try {
        return await operation(AppConfig.customersUrl);
      } catch (_) {
        // Fall through to error
      }
    }

    throw const CustomerApiException(
      'Unable to reach the server. Please check your connection and ensure JSON Server is running.',
    );
  }

  Future<String?> autoDiscoverWorkingHost() async {
    for (final candidate in AppConfig.candidateBaseUrls) {
      final isWorking = await testEndpoint(candidate);
      if (isWorking) {
        return candidate;
      }
    }
    return null;
  }

  Future<bool> testEndpoint(String baseUrl) async {
    try {
      var cleaned = baseUrl.trim();
      if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
        cleaned = 'http://$cleaned';
      }
      if (cleaned.endsWith('/')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }

      final uri = Uri.parse('$cleaned${AppConfig.customersEndpoint}');
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_probeTimeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
