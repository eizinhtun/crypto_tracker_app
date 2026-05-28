import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    this.lastUpdated,
    super.key,
  });

  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message = switch (lastUpdated) {
      final updatedAt? => context.l10n.cachedDataLastUpdated(updatedAt),
      null => context.l10n.offline,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
