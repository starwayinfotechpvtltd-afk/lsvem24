import 'dart:math';

import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/pages/shorts_ads/get_shorts_feed_ads_api.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_model.dart';
import 'package:metube/utils/settings/app_settings.dart';

/// Inserts one random sponsored ad after every [shortsBetweenAds] shorts videos.
class ShortsFeedAdInserter {
  ShortsFeedAdInserter({this.shortsBetweenAds = 4});

  static const int defaultShortsBetweenAds = 4;

  final int shortsBetweenAds;
  final Random _random = Random();

  List<ShortsFeedAd> _pool = [];
  bool _poolLoaded = false;
  int _shortsSeenInFeed = 0;

  void resetFeed() {
    _shortsSeenInFeed = 0;
  }

  /// Registers one short already placed in [target] (e.g. first video on preview open).
  Future<void> registerShort(Shorts short, List<dynamic> target) async {
    await ensurePoolLoaded();
    target.add(short);
    _shortsSeenInFeed++;
    _maybeInsertAd(target);
  }

  Future<void> ensurePoolLoaded() async {
    if (_poolLoaded) return;
    _pool = await GetShortsFeedAdsApi.callApi();
    _poolLoaded = true;
    AppSettings.showLog("Shorts feed ad pool size => ${_pool.length}");
  }

  ShortsFeedAd? pickRandomAd() {
    if (_pool.isEmpty) return null;
    return _pool[_random.nextInt(_pool.length)];
  }

  /// Appends shorts to [target] and inserts [ShortsFeedAdSlot] every N shorts.
  Future<void> appendShorts(List<Shorts> shorts, List<dynamic> target) async {
    if (shorts.isEmpty) return;
    await ensurePoolLoaded();

    for (final short in shorts) {
      target.add(short);
      _shortsSeenInFeed++;
      _maybeInsertAd(target);
    }
  }

  void _maybeInsertAd(List<dynamic> target) {
    if (_shortsSeenInFeed % shortsBetweenAds != 0) return;
    final ad = pickRandomAd();
    if (ad != null) {
      target.add(ShortsFeedAdSlot(ad));
      AppSettings.showLog(
          "Inserted shorts ad after $_shortsSeenInFeed shorts (${ad.isVideoAd ? 'video' : 'image'})");
    }
  }
}
