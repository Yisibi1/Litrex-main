import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/constant.dart';

InterstitialAd? interstitialAd;

Future<void> adShow() async {
  if (interstitialAd == null) {
    print('Warning: attempt to show interstitial before loaded.');
    return;
  }
  interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('$ad onAdDismissedFullScreenContent.');
      ad.dispose();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('$ad onAdFailedToShowFullScreenContent: $error');
      ad.dispose();
      createInterstitialAd();
    },
  );
  interstitialAd!.show();
}

void createInterstitialAd() {
  InterstitialAd.load(
    adUnitId: getInterstitialAdUnitId()!,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        print('$ad loaded');
        interstitialAd = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        print('InterstitialAd failed to load: $error.');
        interstitialAd = null;
      },
    ),
  );
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return getStringAsync(ADMOB_INTERSTITIAL_ID_IOS).isNotEmpty ? getStringAsync(ADMOB_INTERSTITIAL_ID_IOS) : adMobInterstitialIdIos;
  } else if (Platform.isAndroid) {
    return getStringAsync(ADMOB_INTERSTITIAL_ID).isNotEmpty ? getStringAsync(ADMOB_INTERSTITIAL_ID) : adMobInterstitialId;
  }
  return null;
}

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return getStringAsync(ADMOB_BANNER_ID_IOS).isNotEmpty ? getStringAsync(ADMOB_BANNER_ID_IOS) : adMobBannerIdIos;
  } else if (Platform.isAndroid) {
    return getStringAsync(ADMOB_BANNER_ID).isNotEmpty ? getStringAsync(ADMOB_BANNER_ID) : adMobBannerId;
  }
  return null;
}

RewardedAd? rewardedAd;

String? getRewardedAdUnitId() {
  if (Platform.isIOS) {
    return getStringAsync(ADMOB_REWARDED_ID_IOS).isNotEmpty ? getStringAsync(ADMOB_REWARDED_ID_IOS) : adMobRewardedIdIos;
  } else if (Platform.isAndroid) {
    return getStringAsync(ADMOB_REWARDED_ID).isNotEmpty ? getStringAsync(ADMOB_REWARDED_ID) : adMobRewardedId;
  }
  return null;
}

void createRewardedAd() {
  RewardedAd.load(
    adUnitId: getRewardedAdUnitId()!,
    request: AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (RewardedAd ad) {
        rewardedAd = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        rewardedAd = null;
      },
    ),
  );
}

bool showRewardedAd({required Function onUserEarnedReward}) {
  if (rewardedAd == null) {
     createRewardedAd();
     return false;
  }
  rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdDismissedFullScreenContent: (RewardedAd ad) {
      ad.dispose();
      createRewardedAd();
    },
    onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
      ad.dispose();
      createRewardedAd();
    },
  );

  rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
    onUserEarnedReward();
  });
  rewardedAd = null;
  return true;
}
