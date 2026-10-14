import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../data/customer_api.dart';
import '../state/customer_search_state.dart';

class ServerConfigSheet extends StatefulWidget {
  const ServerConfigSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ServerConfigSheet(),
    );
  }

  @override
  State<ServerConfigSheet> createState() => _ServerConfigSheetState();
}

class _ServerConfigSheetState extends State<ServerConfigSheet> {
  late final TextEditingController _urlController;
  final CustomerApi _testApi = CustomerApi(
    probeTimeout: const Duration(seconds: 2),
  );

  bool _isTesting = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: AppConfig.activeBaseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _testApi.dispose();
    super.dispose();
  }

  Future<void> _runConnectionTest(String targetUrl) async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing connection...';
      _testSuccess = null;
    });

    final success = await _testApi.testEndpoint(targetUrl);

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testSuccess = success;
      _testResult = success
          ? 'Connected successfully (HTTP 200)'
          : 'Could not reach server at $targetUrl';
    });
  }

  Future<void> _runAutoDetect() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Auto-detecting available hosts...';
      _testSuccess = null;
    });

    final host = await _testApi.autoDiscoverWorkingHost();

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      if (host != null) {
        _urlController.text = host;
        _testSuccess = true;
        _testResult = 'Discovered active server at $host';
      } else {
        _testSuccess = false;
        _testResult = 'No active server found on candidate endpoints.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<CustomerSearchState>();
    final theme = Theme.of(context);
    final isDemo = searchState.isDemoMode;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dns_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data Source & Server',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Mode Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDemo
                    ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4)
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDemo
                      ? theme.colorScheme.tertiary.withValues(alpha: 0.3)
                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDemo
                            ? Icons.dataset_outlined
                            : Icons.check_circle_outline,
                        color: isDemo
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isDemo
                            ? 'Offline Demo Mode'
                            : 'Live Server Mode',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDemo
                        ? 'Using bundled db.json asset. No local server or network connection required.'
                        : 'Connected to: ${AppConfig.activeBaseUrl}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      if (isDemo) {
                        searchState.setDemoMode(false);
                        _runConnectionTest(_urlController.text.trim());
                      } else {
                        searchState.setDemoMode(true);
                      }
                    },
                    child: Text(
                      isDemo ? 'Switch to Live Server' : 'Switch to Demo Mode',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Server Endpoint URL',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'API Base URL',
                      hintText: 'http://localhost:3001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Test Connection',
                  onPressed: _isTesting
                      ? null
                      : () => _runConnectionTest(_urlController.text.trim()),
                  icon: _isTesting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check),
                ),
              ],
            ),

            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _testSuccess == true
                        ? Icons.check_circle
                        : (_testSuccess == false
                            ? Icons.error
                            : Icons.info_outline),
                    size: 16,
                    color: _testSuccess == true
                        ? Colors.green
                        : (_testSuccess == false
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _testResult!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _testSuccess == true
                            ? Colors.green
                            : (_testSuccess == false
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            Text(
              'Quick Presets:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.usb, size: 16),
                  label: const Text('USB Device (localhost:3001)'),
                  onPressed: () {
                    _urlController.text = 'http://localhost:${AppConfig.apiPort}';
                    _runConnectionTest(_urlController.text);
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.phone_android, size: 16),
                  label: const Text('Emulator (10.0.2.2:3001)'),
                  onPressed: () {
                    _urlController.text = 'http://10.0.2.2:${AppConfig.apiPort}';
                    _runConnectionTest(_urlController.text);
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.wifi, size: 16),
                  label: Text('Wi-Fi (${AppConfig.defaultLanIp}:3001)'),
                  onPressed: () {
                    _urlController.text =
                        'http://${AppConfig.defaultLanIp}:${AppConfig.apiPort}';
                    _runConnectionTest(_urlController.text);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _runAutoDetect,
                    icon: const Icon(Icons.travel_explore, size: 18),
                    label: const Text('Auto-Detect'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final chosenUrl = _urlController.text.trim();
                      if (chosenUrl.isNotEmpty) {
                        AppConfig.activeBaseUrl = chosenUrl;
                      }
                      searchState.setDemoMode(false);
                      Navigator.of(context).pop();
                      if (searchState.hasSearchCriteria) {
                        searchState.searchCustomers();
                      }
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Apply & Use'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
