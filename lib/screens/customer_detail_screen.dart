import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/address.dart';
import '../models/customer.dart';
import '../models/email.dart';
import '../models/phone.dart';
import '../widgets/theme_toggle_button.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.fullName),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              'Basic Information',
              Icons.person_outline,
            ),
            const SizedBox(height: 8),
            _buildBasicInfoCard(context),
            const SizedBox(height: 20),
            _buildSectionTitle(
              context,
              'Addresses',
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 8),
            if (customer.addresses.isEmpty)
              _buildEmptySection(context, 'No addresses on file')
            else
              ...customer.addresses.map(
                (address) => _buildAddressCard(context, address),
              ),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Phone Numbers', Icons.phone_outlined),
            const SizedBox(height: 8),
            if (customer.phones.isEmpty)
              _buildEmptySection(context, 'No phone numbers on file')
            else
              ...customer.phones.map(
                (phone) => _buildPhoneCard(context, phone),
              ),
            const SizedBox(height: 20),
            _buildSectionTitle(
              context,
              'Email Addresses',
              Icons.email_outlined,
            ),
            const SizedBox(height: 8),
            if (customer.emails.isEmpty)
              _buildEmptySection(context, 'No email addresses on file')
            else
              ...customer.emails.map(
                (email) => _buildEmailCard(context, email),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final initials = '${customer.firstName[0]}${customer.lastName[0]}'
        .toUpperCase();

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initials,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customer.fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              customer.maritalStatus,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(label: 'First Name', value: customer.firstName),
            const Divider(height: 16),
            _DetailRow(label: 'Last Name', value: customer.lastName),
            const Divider(height: 16),
            _DetailRow(
              label: 'Date of Birth',
              value: _formatDate(customer.dateOfBirth),
            ),
            const Divider(height: 16),
            _DetailRow(label: 'Marital Status', value: customer.maritalStatus),
            const Divider(height: 16),
            _DetailRow(label: 'Secure ID', value: customer.secureId),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                address.type,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Street', value: address.street),
            const SizedBox(height: 4),
            _DetailRow(label: 'City', value: address.city),
            const SizedBox(height: 4),
            _DetailRow(label: 'State', value: address.state),
            const SizedBox(height: 4),
            _DetailRow(label: 'ZIP Code', value: address.zipCode),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneCard(BuildContext context, Phone phone) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: phone.isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: phone.isPrimary ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                phone.type,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(phone.number, style: theme.textTheme.bodyLarge),
            ),
            if (phone.isPrimary)
              Chip(
                label: const Text('Primary'),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailCard(BuildContext context, Email email) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: email.isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: email.isPrimary ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                email.type,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                email.address,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (email.isPrimary)
              Chip(
                label: const Text('Primary'),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant
              .withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
