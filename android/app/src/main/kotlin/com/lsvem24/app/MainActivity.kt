package com.lsvem24.app


//import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin


class MainActivity: FlutterFragmentActivity() {

    //class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val context: Context = applicationContext

        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "medium", MediumNativeAdFactory(context))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "large", LargeNativeAdFactory(context))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "full", FullNativeAdFactory(context))
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        val context: Context = applicationContext

        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "medium")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "large")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "full")
    }
}

