import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/images.dart';
import 'package:flutter/material.dart';
import '../component/AdMobComponent.dart';
import '../component/FacebookdComponent.dart';
import '../main.dart';
import '../model/LanguageDataModel.dart';
import 'Extensions/Constants.dart';
import 'Extensions/decorations.dart';
import 'Extensions/shared_pref.dart';
import 'Extensions/text_styles.dart';
import 'colors.dart';
import 'constant.dart';

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'asset/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'asset/flag/ic_in.png'),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'asset/flag/ic_ar.png'),
    LanguageDataModel(id: 4, name: 'French', subTitle: 'français', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'asset/flag/ic_fr.png'),
    LanguageDataModel(id: 5, name: 'Portuguese', subTitle: 'português', languageCode: 'pt', fullLanguageCode: 'pt-PT', flag: 'asset/flag/ic_pt.png'),
    LanguageDataModel(id: 6, name: 'Turkish', subTitle: 'Türk', languageCode: 'tr', fullLanguageCode: 'tr-TR', flag: 'asset/flag/ic_tr.png'),
    LanguageDataModel(id: 7, name: 'Afrikaans', subTitle: 'Afrikaans', languageCode: 'af', fullLanguageCode: 'af-AF', flag: 'asset/flag/ic_af.png'),
    LanguageDataModel(id: 8, name: 'Vietnamese', subTitle: 'Tiếng Việt', languageCode: 'vi', fullLanguageCode: 'vi-VI', flag: 'asset/flag/ic_vi.png'),
  ];
}

Widget cachedImage(String? url, {double? height, Color? color, double? width, BoxFit? fit, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    );
  } else {
    return Image.asset(url!, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset(ic_placeholder, height: height, width: width, fit: fit ?? BoxFit.fill, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

Widget mProgress() {
  return Container(
    alignment: Alignment.center,
    child: Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 4,
      margin: EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: radius(50)),
      child: Container(
        width: 40,
        height: 40,
        padding: EdgeInsets.all(8.0),
        child: Theme(
          data: ThemeData(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: appStore.isDarkModeOn ? Colors.white : primaryColor)),
          child: CircularProgressIndicator(strokeWidth: 3, color: appStore.isDarkModeOn ? Colors.white : primaryColor),
        ),
      ),
    ),
  );
}

Widget noDataWidget(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(ic_no_data, fit: BoxFit.fill, height: 100, width: 100),
      Text(language.lblNoDataFound, style: boldTextStyle()),
    ],
  ).center();
}

InputDecoration inputDecoration(BuildContext context, {String? label, Widget? prefixIcon}) {
  return InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: context.theme.colorScheme.error)),
    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: Colors.transparent)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(defaultRadius), borderSide: BorderSide(color: context.theme.colorScheme.error)),
    alignLabelWithHint: true,
    filled: true,
    isDense: true,
    labelText: label ?? "Sample Text",
    labelStyle: secondaryTextStyle(),
  );
}

void loadInterstitialAds() {
  if (authStore.isPremiumUser) return;
  getStringAsync(ADD_TYPE) != NONE
      ? getStringAsync(ADD_TYPE) == isGoogleAds
          ? createInterstitialAd()
          : loadFacebookInterstitialAd()
      : SizedBox();
}

void showInterstitialAds() {
  if (authStore.isPremiumUser) return;
  getStringAsync(ADD_TYPE) != NONE
      ? getStringAsync(ADD_TYPE) == isGoogleAds
          ? adShow()
          : showFacebookInterstitialAd()
      : SizedBox();
}

Widget showBannerAds() {
  if (authStore.isPremiumUser) return SizedBox();
  return getStringAsync(ADD_TYPE) != NONE
      ? getStringAsync(ADD_TYPE) == isGoogleAds
          ? SizedBox(
              height: 60,
              child: AdWidget(
                ad: BannerAd(
                  adUnitId: getBannerAdUnitId()!,
                  size: AdSize.banner,
                  request: AdRequest(),
                  listener: BannerAdListener(),
                )..load(),
              ),
            )
          : loadFacebookBannerId()
      : SizedBox();
}
