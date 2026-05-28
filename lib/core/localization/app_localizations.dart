import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../error/failures.dart';
import 'localization_keys.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const fallbackLocale = Locale('en');
  static const supportedLocales = [
    Locale('en'),
    Locale('my'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(fallbackLocale);
  }

  String get appName => _text(LocalizationKeys.appName);
  String get searchHint => _text(LocalizationKeys.searchHint);
  String get favorites => _text(LocalizationKeys.favorites);
  String get retry => _text(LocalizationKeys.retry);
  String get emptyCoins => _text(LocalizationKeys.emptyCoins);
  String get emptyCachedCoins => _text(LocalizationKeys.emptyCachedCoins);
  String get offline => _text(LocalizationKeys.offline);
  String cachedDataLastUpdated(DateTime lastUpdated) {
    return _text(LocalizationKeys.offlineWithLastUpdated)
        .replaceAll('{time}', _time(lastUpdated.toLocal()));
  }

  String get noData => _text(LocalizationKeys.noData);
  String get unableToLoadData => _text(LocalizationKeys.unableToLoadData);
  String get rateLimited => _text(LocalizationKeys.rateLimited);
  String get noInternetConnection =>
      _text(LocalizationKeys.noInternetConnection);
  String get cachedDataUnavailable =>
      _text(LocalizationKeys.cachedDataUnavailable);
  String get somethingWentWrong => _text(LocalizationKeys.somethingWentWrong);
  String get requestTimedOut => _text(LocalizationKeys.requestTimedOut);
  String get requestedDataNotFound =>
      _text(LocalizationKeys.requestedDataNotFound);
  String get markets => _text(LocalizationKeys.markets);
  String get liveCoinGecko => _text(LocalizationKeys.liveCoinGecko);
  String get asset => _text(LocalizationKeys.asset);
  String get price24h => _text(LocalizationKeys.price24h);
  String get clearSearch => _text(LocalizationKeys.clearSearch);
  String get addFavorite => _text(LocalizationKeys.addFavorite);
  String get removeFavorite => _text(LocalizationKeys.removeFavorite);
  String get back => _text(LocalizationKeys.back);
  String get switchLanguage => _text(LocalizationKeys.switchLanguage);
  String get marketStats => _text(LocalizationKeys.marketStats);
  String get marketCap => _text(LocalizationKeys.marketCap);
  String get volume24h => _text(LocalizationKeys.volume24h);
  String get allTimeHigh => _text(LocalizationKeys.allTimeHigh);
  String get allTimeLow => _text(LocalizationKeys.allTimeLow);
  String get circulatingSupply => _text(LocalizationKeys.circulatingSupply);
  String get maxSupply => _text(LocalizationKeys.maxSupply);
  String get uncappedSupply => _text(LocalizationKeys.uncappedSupply);
  String get noDescription => _text(LocalizationKeys.noDescription);
  String get coinDetailUnavailable =>
      _text(LocalizationKeys.coinDetailUnavailable);
  String get unableToLoadCoins => _text(LocalizationKeys.unableToLoadCoins);
  String get unableToLoadCoinDetail =>
      _text(LocalizationKeys.unableToLoadCoinDetail);
  String get globalMarketCap => _text(LocalizationKeys.globalMarketCap);
  String get volume24hShort => _text(LocalizationKeys.volume24hShort);
  String get trending24h => _text(LocalizationKeys.trending24h);
  String get hours24 => _text(LocalizationKeys.hours24);
  String get loading => _text(LocalizationKeys.loading);

  String coinCount(int count) {
    final key = count == 1
        ? LocalizationKeys.coinCountOne
        : LocalizationKeys.coinCountOther;
    return _text(key).replaceAll('{count}', count.toString());
  }

  String aboutCoin(String coinName) {
    return _text(LocalizationKeys.aboutCoin)
        .replaceAll('{coin}', coinName.toUpperCase());
  }

  String sourceHost(String host) {
    return _text(LocalizationKeys.sourceHost).replaceAll('{host}', host);
  }

  String rankLabel(int? rank) {
    if (rank == null) {
      return _text(LocalizationKeys.rankUnavailable);
    }

    return _text(LocalizationKeys.rankNumber)
        .replaceAll('{rank}', rank.toString());
  }

  String failureMessage(
    FailureCategory? category, {
    String? fallback,
  }) {
    return switch (category) {
      FailureCategory.network => noInternetConnection,
      FailureCategory.server => unableToLoadData,
      FailureCategory.rateLimit => rateLimited,
      FailureCategory.notFound => requestedDataNotFound,
      FailureCategory.unauthorized => unableToLoadData,
      FailureCategory.timeout => requestTimedOut,
      FailureCategory.cacheUnavailable => cachedDataUnavailable,
      FailureCategory.unknown => somethingWentWrong,
      null => fallback ?? somethingWentWrong,
    };
  }

  String _text(String key) {
    final languageCode = locale.languageCode;
    return _localizedValues[languageCode]?[key] ??
        _localizedValues[fallbackLocale.languageCode]?[key] ??
        key;
  }

  String _time(DateTime dateTime) {
    return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

extension AppLocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    final resolvedLocale = isSupported(locale)
        ? Locale(locale.languageCode)
        : AppLocalizations.fallbackLocale;
    return SynchronousFuture(AppLocalizations(resolvedLocale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const _localizedValues = <String, Map<String, String>>{
  'en': {
    LocalizationKeys.appName: 'Crypto Tracker',
    LocalizationKeys.searchHint: 'Search coins',
    LocalizationKeys.favorites: 'Favorites',
    LocalizationKeys.retry: 'Retry',
    LocalizationKeys.emptyCoins: 'No coins found',
    LocalizationKeys.emptyCachedCoins: 'No cached results found',
    LocalizationKeys.offline: 'Offline mode. Showing cached data.',
    LocalizationKeys.offlineWithLastUpdated:
        'Showing cached data · Last updated: {time}',
    LocalizationKeys.noData: 'No data available',
    LocalizationKeys.unableToLoadData: 'Unable to load data. Please try again.',
    LocalizationKeys.rateLimited:
        'Too many requests. Please wait and try again.',
    LocalizationKeys.noInternetConnection:
        'No internet connection. Showing cached data if available.',
    LocalizationKeys.cachedDataUnavailable: 'Cached data is unavailable.',
    LocalizationKeys.somethingWentWrong:
        'Something went wrong. Please try again.',
    LocalizationKeys.requestTimedOut: 'Request timed out. Please try again.',
    LocalizationKeys.requestedDataNotFound: 'Requested data was not found.',
    LocalizationKeys.markets: 'Markets',
    LocalizationKeys.liveCoinGecko: 'LIVE / COINGECKO',
    LocalizationKeys.asset: 'ASSET',
    LocalizationKeys.price24h: 'PRICE  ·  24H',
    LocalizationKeys.clearSearch: 'Clear search',
    LocalizationKeys.addFavorite: 'Add favorite',
    LocalizationKeys.removeFavorite: 'Remove favorite',
    LocalizationKeys.back: 'Back',
    LocalizationKeys.switchLanguage: 'Switch language',
    LocalizationKeys.marketStats: 'MARKET STATS',
    LocalizationKeys.marketCap: 'MARKET CAP',
    LocalizationKeys.volume24h: 'VOLUME 24H',
    LocalizationKeys.allTimeHigh: 'ALL-TIME HIGH',
    LocalizationKeys.allTimeLow: 'ALL-TIME LOW',
    LocalizationKeys.circulatingSupply: 'CIRCULATING SUPPLY',
    LocalizationKeys.maxSupply: 'MAX SUPPLY',
    LocalizationKeys.uncappedSupply: '∞ uncapped',
    LocalizationKeys.noDescription: 'No description available for this coin.',
    LocalizationKeys.coinDetailUnavailable: 'Coin detail is unavailable',
    LocalizationKeys.unableToLoadCoins: 'Unable to load coins',
    LocalizationKeys.unableToLoadCoinDetail: 'Unable to load coin detail',
    LocalizationKeys.globalMarketCap: 'GLOBAL CAP  ·  24H',
    LocalizationKeys.volume24hShort: 'VOL 24H',
    LocalizationKeys.trending24h: 'TRENDING  ·  24H',
    LocalizationKeys.hours24: '24h',
    LocalizationKeys.loading: 'Loading',
    LocalizationKeys.coinCountOne: '{count} COIN →',
    LocalizationKeys.coinCountOther: '{count} COINS →',
    LocalizationKeys.aboutCoin: 'ABOUT {coin}',
    LocalizationKeys.sourceHost: '○  SOURCE  ·  {host}',
    LocalizationKeys.rankUnavailable: 'RANK -',
    LocalizationKeys.rankNumber: 'RANK #{rank}',
  },
  'my': {
    LocalizationKeys.appName: 'Crypto Tracker',
    LocalizationKeys.searchHint: 'ဒင်္ဂါးများ ရှာဖွေပါ',
    LocalizationKeys.favorites: 'နှစ်သက်ရာများ',
    LocalizationKeys.retry: 'ထပ်မံကြိုးစားမည်',
    LocalizationKeys.emptyCoins: 'ဒင်္ဂါး မတွေ့ပါ',
    LocalizationKeys.emptyCachedCoins: 'သိမ်းထားသော ရလဒ် မတွေ့ပါ',
    LocalizationKeys.offline:
        'အော့ဖ်လိုင်းမုဒ်။ သိမ်းထားသော အချက်အလက်များကို ပြနေသည်။',
    LocalizationKeys.offlineWithLastUpdated:
        'သိမ်းထားသော အချက်အလက်များကို ပြနေသည် · နောက်ဆုံးအပ်ဒိတ်: {time}',
    LocalizationKeys.noData: 'အချက်အလက် မရှိသေးပါ',
    LocalizationKeys.unableToLoadData:
        'အချက်အလက် မရယူနိုင်ပါ။ ထပ်မံကြိုးစားပါ။',
    LocalizationKeys.rateLimited:
        'တောင်းဆိုမှုများလွန်းနေသည်။ ခဏစောင့်ပြီး ထပ်မံကြိုးစားပါ။',
    LocalizationKeys.noInternetConnection:
        'အင်တာနက်ချိတ်ဆက်မှု မရှိပါ။ ရှိပါက သိမ်းထားသော အချက်အလက်များကို ပြပါမည်။',
    LocalizationKeys.cachedDataUnavailable: 'သိမ်းထားသော အချက်အလက် မရှိသေးပါ။',
    LocalizationKeys.somethingWentWrong:
        'တစ်ခုခု မှားယွင်းသွားသည်။ ထပ်မံကြိုးစားပါ။',
    LocalizationKeys.requestTimedOut:
        'တောင်းဆိုမှု အချိန်ကျော်သွားသည်။ ထပ်မံကြိုးစားပါ။',
    LocalizationKeys.requestedDataNotFound:
        'တောင်းဆိုထားသော အချက်အလက် မတွေ့ပါ။',
    LocalizationKeys.markets: 'စျေးကွက်များ',
    LocalizationKeys.liveCoinGecko: 'LIVE / COINGECKO',
    LocalizationKeys.asset: 'ပိုင်ဆိုင်မှု',
    LocalizationKeys.price24h: 'စျေးနှုန်း  ·  ၂၄နာရီ',
    LocalizationKeys.clearSearch: 'ရှာဖွေမှု ဖျက်မည်',
    LocalizationKeys.addFavorite: 'နှစ်သက်ရာထဲ ထည့်မည်',
    LocalizationKeys.removeFavorite: 'နှစ်သက်ရာမှ ဖယ်မည်',
    LocalizationKeys.back: 'နောက်သို့',
    LocalizationKeys.switchLanguage: 'ဘာသာစကား ပြောင်းမည်',
    LocalizationKeys.marketStats: 'စျေးကွက် အချက်အလက်',
    LocalizationKeys.marketCap: 'စျေးကွက်တန်ဖိုး',
    LocalizationKeys.volume24h: '၂၄နာရီ အရောင်းအဝယ်',
    LocalizationKeys.allTimeHigh: 'အမြင့်ဆုံးစျေး',
    LocalizationKeys.allTimeLow: 'အနိမ့်ဆုံးစျေး',
    LocalizationKeys.circulatingSupply: 'လည်ပတ်နေသော ပမာဏ',
    LocalizationKeys.maxSupply: 'အများဆုံး ပမာဏ',
    LocalizationKeys.uncappedSupply: '∞ ကန့်သတ်မထားပါ',
    LocalizationKeys.noDescription: 'ဤဒင်္ဂါးအတွက် ဖော်ပြချက် မရှိသေးပါ။',
    LocalizationKeys.coinDetailUnavailable: 'ဒင်္ဂါးအသေးစိတ် မရနိုင်ပါ',
    LocalizationKeys.unableToLoadCoins: 'ဒင်္ဂါးစာရင်း မရယူနိုင်ပါ',
    LocalizationKeys.unableToLoadCoinDetail: 'ဒင်္ဂါးအသေးစိတ် မရယူနိုင်ပါ',
    LocalizationKeys.globalMarketCap: 'စုစုပေါင်းတန်ဖိုး  ·  ၂၄နာရီ',
    LocalizationKeys.volume24hShort: '၂၄နာရီ VOL',
    LocalizationKeys.trending24h: 'ရေပန်းစား  ·  ၂၄နာရီ',
    LocalizationKeys.hours24: '၂၄နာရီ',
    LocalizationKeys.loading: 'လုပ်ဆောင်နေသည်',
    LocalizationKeys.coinCountOne: '{count} COIN →',
    LocalizationKeys.coinCountOther: '{count} COINS →',
    LocalizationKeys.aboutCoin: '{coin} အကြောင်း',
    LocalizationKeys.sourceHost: '○  SOURCE  ·  {host}',
    LocalizationKeys.rankUnavailable: 'အဆင့် -',
    LocalizationKeys.rankNumber: 'အဆင့် #{rank}',
  },
};
