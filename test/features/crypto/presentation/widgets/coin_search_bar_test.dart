import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/coin_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Given search text is typed, when it is not submitted, then search callback is not called',
    (tester) async {
      final submittedQueries = <String>[];
      var clearCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: CoinSearchBar(
              onSubmitted: submittedQueries.add,
              onCleared: () => clearCount++,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'eth');
      await tester.pump();

      expect(submittedQueries, isEmpty);
      expect(clearCount, 0);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedQueries, ['eth']);
      expect(clearCount, 0);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();

      expect(submittedQueries, ['eth']);
      expect(clearCount, 1);
    },
  );
}
