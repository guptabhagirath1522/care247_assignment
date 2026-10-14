import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/search_config.dart';
import '../state/customer_search_state.dart';
import 'dynamic_field.dart';

/// Configuration-driven search form.
///
/// Iterates over the [searchConfig] list, sorted by [FieldConfig.renderOrder],
/// and renders each field using [DynamicField]. Adding a new [FieldConfig]
/// entry to the configuration list will automatically render the new field
/// without modifying this widget's code.
class DynamicSearchForm extends StatefulWidget {
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const DynamicSearchForm({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<DynamicSearchForm> createState() => _DynamicSearchFormState();
}

class _DynamicSearchFormState extends State<DynamicSearchForm> {
  /// Focus nodes for text fields, enabling keyboard navigation.
  late final Map<String, FocusNode> _focusNodes;

  /// Sorted configuration, cached to avoid re-sorting on every build.
  late final List<FieldConfig> _sortedConfig;

  @override
  void initState() {
    super.initState();
    _sortedConfig = List<FieldConfig>.from(searchConfig)
      ..sort((a, b) => a.renderOrder.compareTo(b.renderOrder));
    _focusNodes = {
      for (final config in _sortedConfig)
        if (config.type == FieldType.text) config.key: FocusNode(),
    };
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.read<CustomerSearchState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _sortedConfig.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          DynamicField(
            config: _sortedConfig[i],
            value: searchState.searchCriteria[_sortedConfig[i].key] ?? '',
            onChanged: (value) {
              searchState.updateCriterion(_sortedConfig[i].key, value);
              setState(() {});
            },
            focusNode: _focusNodes[_sortedConfig[i].key],
            onFieldSubmitted: () => _moveToNextField(i),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  widget.onClear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  widget.onSearch();
                },
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Moves focus to the next text field, or unfocuses if at the end.
  void _moveToNextField(int currentIndex) {
    for (int i = currentIndex + 1; i < _sortedConfig.length; i++) {
      final nextKey = _sortedConfig[i].key;
      if (_focusNodes.containsKey(nextKey)) {
        _focusNodes[nextKey]!.requestFocus();
        return;
      }
    }
    FocusScope.of(context).unfocus();
  }
}
