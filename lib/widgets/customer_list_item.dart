import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';

/// A reusable list item widget for displaying a customer summary.
///
/// Shows the customer's full name, date of birth, primary phone,
/// and primary email. Designed for use in [ListView.builder] for
/// efficient rendering.
class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryPhone = customer.primaryPhone;
    final primaryEmail = customer.primaryEmail;

    final initials =
        '${customer.firstName.isNotEmpty ? customer.firstName[0] : ''}${customer.lastName.isNotEmpty ? customer.lastName[0] : ''}'
            .toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customer.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.cake_outlined,
                label: _formatDate(customer.dateOfBirth),
              ),
              if (primaryPhone != null) ...[
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: primaryPhone.number,
                ),
              ],
              if (primaryEmail != null) ...[
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: primaryEmail.address,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}

/// A small reusable row with an icon and a label.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
