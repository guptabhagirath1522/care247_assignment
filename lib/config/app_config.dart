import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  AppConfig._();

  static const int apiPort = 3001;
  static const String defaultLanIp = '192.168.0.108';

  static String? customBaseUrl =
      const String.fromEnvironment('API_URL').trim().isNotEmpty
          ? const String.fromEnvironment('API_URL').trim()
          : null;

  static String? _activeBaseUrl;

  static String get activeBaseUrl => _activeBaseUrl ?? defaultBaseUrl;

  static set activeBaseUrl(String url) {
    _activeBaseUrl = _cleanUrl(url);
  }

  static void resetActiveBaseUrl() {
    _activeBaseUrl = null;
  }

  static String get defaultBaseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return _cleanUrl(customBaseUrl!);
    }
    if (kIsWeb) {
      return 'http://localhost:$apiPort';
    }
    if (Platform.isAndroid) {
      return 'http://localhost:$apiPort';
    }
    return 'http://localhost:$apiPort';
  }

  static List<String> get candidateBaseUrls {
    final list = <String>[];

    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      list.add(_cleanUrl(customBaseUrl!));
    }

    if (kIsWeb) {
      list.add('http://localhost:$apiPort');
      return list.toSet().toList();
    }

    if (Platform.isAndroid) {
      list.add('http://localhost:$apiPort');
      list.add('http://10.0.2.2:$apiPort');
      list.add('http://$defaultLanIp:$apiPort');
    } else {
      list.add('http://localhost:$apiPort');
      list.add('http://$defaultLanIp:$apiPort');
    }

    return list.toSet().toList();
  }

  static const String customersEndpoint = '/customers';

  static String get customersUrl => '$activeBaseUrl$customersEndpoint';

  static String _cleanUrl(String raw) {
    var cleaned = raw.trim();
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'http://$cleaned';
    }
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }
}
