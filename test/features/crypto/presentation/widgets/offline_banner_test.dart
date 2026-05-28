import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Given cached data metadata, when offline banner renders, then localized last-updated message is shown',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: OfflineBanner(
              lastUpdated: DateTime.utc(2026, 1, 1, 12),
            ),
          ),
        ),
      );

      expect(find.textContaining('Showing cached data'), findsOneWidget);
      expect(find.textContaining('Last updated'), findsOneWidget);
    },
  );
}
