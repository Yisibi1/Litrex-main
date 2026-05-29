// lib/component/NativeAdWidget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../main.dart'; // To access authStore
import '../utils/constant.dart';
import '../utils/Extensions/context_extensions.dart';

import 'dart:io';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!authStore.isPremiumUser) {
      _loadNativeAd();
    }
  }

  String _getAdUnitId() {
    String? adId;
    if (Platform.isIOS) {
      adId = getStringAsync(ADMOB_NATIVE_ID_IOS);
    } else {
      adId = getStringAsync(ADMOB_NATIVE_ID);
    }

    if (adId.validate().isNotEmpty) {
      return adId;
    }

    return 'ca-app-pub-2970306107465777/4585793055';
  }

  void _loadNativeAd() {
     _nativeAd = NativeAd(
      adUnitId: _getAdUnitId(),
      factoryId: 'listTileFactory',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          print('Native Ad loaded successfully');
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          print('Native Ad failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (authStore.isPremiumUser) return SizedBox.shrink();
    if (!_isLoaded || _nativeAd == null) return SizedBox.shrink();

    // Native Ad Container
    // We rely on the Android Implementation (XML) to layout the ad components.
    // This Container provides the size constraint for the NativeAd.
    return Container(
      height: 160, 
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, spreadRadius: 0)
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AdWidget(ad: _nativeAd!)
      ),
    );
  }
}
