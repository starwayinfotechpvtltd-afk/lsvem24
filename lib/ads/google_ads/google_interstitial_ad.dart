// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// import 'google_ad_helper.dart';
//
// class GoogleInterstitialAd {
//   static bool _isLoaded = false; // This Variable Use to Check Ads Is Loaded or Not
//   static Function function = () {}; // This Function Use to Navigation...
//   static InterstitialAd? interstitialAd;
//   static int interstitialCount = 0;
//
//   static void loadAd() {
//     debugPrint("Google Interstitial Ads Loading...");
//     _isLoaded = false;
//     InterstitialAd.load(
//       adUnitId: GoogleAdHelper.interstitialAdUnitId,
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) {
//           _isLoaded = true;
//           ad.fullScreenContentCallback = FullScreenContentCallback(onAdShowedFullScreenContent: (ad) {
//             debugPrint("Google Interstitial Ads Showed");
//           }, onAdImpression: (ad) {
//             debugPrint("Google Interstitial Ads Impression");
//           }, onAdFailedToShowFullScreenContent: (ad, err) {
//             debugPrint("Google Interstitial Ads Loading Failed");
//             ad.dispose();
//           }, onAdDismissedFullScreenContent: (ad) {
//             function();
//             debugPrint("Google Interstitial Ads Closed");
//             ad.dispose();
//           }, onAdClicked: (ad) {
//             debugPrint("Google Interstitial Ads On Clicked");
//           });
//           debugPrint("Google Interstitial Ads Loaded Success");
//           interstitialAd = ad;
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           debugPrint('Google InterstitialAd Loading Failed');
//         },
//       ),
//     );
//   }
//
//   static showAd([Function? navigation]) {
//     function = () => navigation!();
//     if (_isLoaded) {
//       interstitialAd!.show();
//       debugPrint("Google Showed InterstitialAd");
//     } else {}
//     loadAd();
//   }
// }
