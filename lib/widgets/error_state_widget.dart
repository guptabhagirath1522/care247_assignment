import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onUseDemoData;
  final VoidCallback? onConfigureServer;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.onUseDemoData,
    this.onConfigureServer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Issue',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry Connection'),
                  ),
                if (onUseDemoData != null)
                  FilledButton.tonalIcon(
                    onPressed: onUseDemoData,
                    icon: const Icon(Icons.dataset_outlined, size: 18),
                    label: const Text('Use Bundled Demo Data'),
                  ),
                if (onConfigureServer != null)
                  OutlinedButton.icon(
                    onPressed: onConfigureServer,
                    icon: const Icon(Icons.dns_outlined, size: 18),
                    label: const Text('Server Settings'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
