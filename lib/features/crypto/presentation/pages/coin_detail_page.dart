import 'package:crypto_tracker_app/features/crypto/presentation/widgets/detail_topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/coin_detail/coin_detail_event.dart';
import '../viewmodels/coin_detail/coin_detail_state.dart';
import '../viewmodels/coin_detail/coin_detail_view_model.dart';
import '../widgets/detail_content.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/offline_banner.dart';

class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({
    required this.coinId,
    super.key,
  });

  final String coinId;

  @override
  Widget build(BuildContext context) {
    return _CoinDetailView(coinId: coinId);
  }
}

class _CoinDetailView extends StatelessWidget {
  const _CoinDetailView({required this.coinId});

  final String coinId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinDetailViewModel, CoinDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final background =
            isDark ? AppColors.darkBackground : AppColors.lightBackground;

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            bottom: false,
            child: switch (state.status) {
              CoinDetailStatus.loading => const LoadingView(),
              CoinDetailStatus.failure => ErrorView(
                  message: context.l10n.failureMessage(
                    state.failureCategory,
                    fallback: context.l10n.unableToLoadCoinDetail,
                  ),
                  onRetry: () {
                    context
                        .read<CoinDetailViewModel>()
                        .add(CoinDetailRequested(coinId));
                  },
                ),
              CoinDetailStatus.initial => const LoadingView(),
              CoinDetailStatus.success => detail == null
                  ? ErrorView(
                      message: context.l10n.coinDetailUnavailable,
                      onRetry: () {
                        context
                            .read<CoinDetailViewModel>()
                            .add(CoinDetailRequested(coinId));
                      },
                    )
                  : Column(
                      children: [
                        DetailTopBar(
                          detail: detail,
                          isFavorite: state.isFavorite,
                          onFavoritePressed: () {
                            context
                                .read<CoinDetailViewModel>()
                                .add(const CoinDetailFavoriteToggled());
                          },
                        ),
                        if (state.hasCachedData)
                          OfflineBanner(lastUpdated: state.lastUpdated),
                        Expanded(
                          child: DetailContent(
                            detail: detail,
                            descriptionText: state.descriptionText,
                          ),
                        ),
                      ],
                    ),
            },
          ),
        );
      },
    );
  }
}
