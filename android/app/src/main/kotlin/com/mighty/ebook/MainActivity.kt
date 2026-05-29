package com.litrex.ebook

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

import android.os.Bundle
import android.view.WindowManager

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "listTileFactory", ListTileNativeAdFactory(context)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTileFactory")
    }
}

class ListTileNativeAdFactory(val context: Context) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_layout, null) as NativeAdView

        with(nativeAdView) {
            val iconView = findViewById<ImageView>(R.id.ad_app_icon)
            val headlineView = findViewById<TextView>(R.id.ad_headline)
            val bodyView = findViewById<TextView>(R.id.ad_body)
            val callToActionView = findViewById<Button>(R.id.ad_call_to_action)

            this.iconView = iconView
            this.headlineView = headlineView
            this.bodyView = bodyView
            this.callToActionView = callToActionView

            (this.headlineView as TextView).text = nativeAd.headline
            (this.bodyView as TextView).text = nativeAd.body
            (this.callToActionView as Button).text = nativeAd.callToAction
            
            // Set Icon
            if (nativeAd.icon != null) {
                iconView.setImageDrawable(nativeAd.icon!!.drawable)
                iconView.visibility = View.VISIBLE
            } else {
                iconView.visibility = View.GONE
            }

            nativeAdView.setNativeAd(nativeAd)
        }
        return nativeAdView
    }
}
