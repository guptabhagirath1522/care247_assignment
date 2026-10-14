import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../state/customer_search_state.dart';
import '../widgets/customer_list_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/server_config_sheet.dart';
import '../widgets/theme_toggle_button.dart';
import 'customer_detail_screen.dart';

class CustomerResultsScreen extends StatelessWidget {
  const CustomerResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<CustomerSearchState>();

    return Scaffold(
      appBar: AppBar(
        title: Consumer<CustomerSearchState>(
          builder: (context, state, _) {
            final count = state.customers.length;
            return Text(
              state.status == SearchStatus.success
                  ? '$count Customer${count == 1 ? '' : 's'} Found'
                  : 'Search Results',
            );
          },
        ),
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
      body: Consumer<CustomerSearchState>(
        builder: (context, state, _) {
          return switch (state.status) {
            SearchStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            SearchStatus.error => ErrorStateWidget(
                message: state.errorMessage,
                onRetry: () => state.refreshResults(),
                onUseDemoData: () => state.useDemoDataAndSearch(),
                onConfigureServer: () => ServerConfigSheet.show(context),
              ),
            SearchStatus.empty => const EmptyStateWidget(
                icon: Icons.person_search,
                title: 'No customers found',
                subtitle:
                    'Try adjusting your search criteria and searching again.',
              ),
            SearchStatus.success => _buildResultsList(context, state),
            SearchStatus.initial => const EmptyStateWidget(
                icon: Icons.search,
                title: 'No search performed',
              ),
          };
        },
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, CustomerSearchState state) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => state.refreshResults(),
      child: Column(
        children: [
          if (state.isDemoMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
              child: Row(
                children: [
                  Icon(
                    Icons.offline_bolt_outlined,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offline Demo Results (Bundled db.json)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.customers.length,
              itemBuilder: (context, index) {
                final customer = state.customers[index];
                return CustomerListItem(
                  customer: customer,
                  onTap: () => _navigateToDetail(context, customer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(customer: customer),
      ),
    );
  }
}
