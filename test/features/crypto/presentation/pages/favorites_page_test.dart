import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/favorites_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorites_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/pages/favorites_page.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/favorites/favorites_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock
    implements CryptoRepository, FavoritesRepository {}

void main() {
  testWidgets(
      'search empty state clears back to favorites and last removal shows onboarding',
      (tester) async {
    final repository = _Repository();
    when(() => repository.getFavorites())
        .thenAnswer((_) async => const Result.success([
              Coin(
                  id: 'bitcoin',
                  name: 'Bitcoin',
                  symbol: 'btc',
                  isFavorite: true),
            ]));
    when(() => repository.toggleFavorite('bitcoin'))
        .thenAnswer((_) async => const Result.success(false));
    final model = FavoritesViewModel(
        GetFavoritesUseCase(repository), ToggleFavoriteUseCase(repository));
    addTearDown(model.close);
    await model.load();
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(value: model, child: const FavoritesPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bitcoin'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching favorites'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Bitcoin'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove favorite'));
    await tester.pumpAndSettle();
    expect(find.text('No favorites yet'), findsOneWidget);
    expect(find.text('Browse markets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
