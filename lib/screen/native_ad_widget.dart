import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110', // Test Ad Unit
      factoryId: 'listTile', // default fabrikanı istifadə edirik
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('NativeAd failed to load: $error');
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded) return SizedBox(height: 0);

    return Container(
      width: double.infinity,
      height: 100, // adaptiv üçün MediaQuery istifadə edə bilərsən
      alignment: Alignment.center,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
