import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/customer_search_state.dart';
import '../widgets/dynamic_search_form.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/server_config_sheet.dart';
import '../widgets/theme_toggle_button.dart';
import 'customer_results_screen.dart';

class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<CustomerSearchState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Search'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Server & Data Source',
            icon: Icon(
              searchState.isDemoMode
                  ? Icons.dataset_outlined
                  : Icons.dns_outlined,
            ),
            onPressed: () => ServerConfigSheet.show(context),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (searchState.isDemoMode) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.offline_bolt_outlined,
                          size: 20,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Offline Demo Mode active (Bundled db.json)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ServerConfigSheet.show(context),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  'Find a Customer',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter search criteria below to find customers.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                DynamicSearchForm(
                  onSearch: () => _performSearch(context),
                  onClear: () => _clearSearch(context),
                ),
                const SizedBox(height: 24),
                Consumer<CustomerSearchState>(
                  builder: (context, state, _) {
                    return switch (state.status) {
                      SearchStatus.initial => const EmptyStateWidget(
                          icon: Icons.search,
                          title: 'Search for customers',
                          subtitle:
                              'Enter at least one criterion and tap Search.',
                        ),
                      SearchStatus.loading => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      SearchStatus.error => ErrorStateWidget(
                          message: state.errorMessage,
                          onRetry: () => _performSearch(context),
                          onUseDemoData: () {
                            state.useDemoDataAndSearch().then((_) {
                              if (!context.mounted) return;
                              if (state.status == SearchStatus.success ||
                                  state.status == SearchStatus.empty) {
                                _navigateToResults(context, state);
                              }
                            });
                          },
                          onConfigureServer: () =>
                              ServerConfigSheet.show(context),
                        ),
                      SearchStatus.success => const SizedBox.shrink(),
                      SearchStatus.empty => const SizedBox.shrink(),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _performSearch(BuildContext context) {
    final state = context.read<CustomerSearchState>();
    state.searchCustomers().then((_) {
      if (!context.mounted) return;

      if (state.status == SearchStatus.success ||
          state.status == SearchStatus.empty) {
        _navigateToResults(context, state);
      }
    });
  }

  void _navigateToResults(BuildContext context, CustomerSearchState state) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<CustomerSearchState>.value(
          value: state,
          child: const CustomerResultsScreen(),
        ),
      ),
    );
  }

  void _clearSearch(BuildContext context) {
    context.read<CustomerSearchState>().clearSearch();
  }
}
