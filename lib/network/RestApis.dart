import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import '../main.dart';
import '../model/DashboardResponse.dart';
import '../model/CoinPackageModel.dart';
import '../network/NetworkUtils.dart';
import '../utils/constant.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/shared_pref.dart';

Future<List<Category>> getCategories() async {
  Iterable it = await (handleResponse(await buildHttpResponse('category.php?limit=$CATEGORY_LIMIT')));
  return it.map((e) => Category.fromJson(e)).toList();
}

Future<DashboardResponse> getDashboard() async {
  return await handleResponse(await buildHttpResponse('dashboard.php')).then((value) async {
    var res = DashboardResponse.fromJson(value);

    if (res.appconfiguration != null) {
      await setValue(TERMS_AND_CONDITION_PREF, res.appconfiguration!.termsCondition.validate());
      await setValue(PRIVACY_POLICY_PREF, res.appconfiguration!.privacyPolicy.validate());
      await setValue(CONTACT_PREF, res.appconfiguration!.contactUs.validate());
      await setValue(ABOUT_US_PREF, res.appconfiguration!.aboutUs.validate());
      await setValue(FACEBOOK, res.appconfiguration!.facebook.validate());
      await setValue(WHATSAPP, res.appconfiguration!.whatsapp.validate());
      await setValue(TWITTER, res.appconfiguration!.twitter.validate());
      await setValue(INSTAGRAM, res.appconfiguration!.instagram.validate());
      await setValue(COPYRIGHT, res.appconfiguration!.copyright.validate());
      await setValue(AD_REWARD_COINS, res.appconfiguration!.adRewardCoins ?? 10);
      await setValue(PDF_AD_PAGE_INTERVAL, res.appconfiguration!.pdfAdPageInterval ?? 5);
      await setValue(MIN_APP_VERSION_CODE, res.appconfiguration!.minAppVersionCode ?? 1);
      await setValue(PLAY_STORE_URL, res.appconfiguration!.playStoreUrl.validate());
    }

    if (res.adsconfiguration != null) {
      await setValue(ADD_TYPE, res.adsconfiguration!.adsType);
      await setValue(FACEBOOK_BANNER_PLACEMENT_ID, res.adsconfiguration!.facebookBannerId.validate());
      await setValue(FACEBOOK_INTERSTITIAL_PLACEMENT_ID, res.adsconfiguration!.facebookInterstitialId.validate());
      await setValue(FACEBOOK_BANNER_PLACEMENT_ID_IOS, res.adsconfiguration!.facebookBannerIdIos.validate());
      await setValue(FACEBOOK_INTERSTITIAL_PLACEMENT_ID_IOS, res.adsconfiguration!.facebookInterstitialIdIos.validate());

      await setValue(ADMOB_BANNER_ID, res.adsconfiguration!.admobBannerId.validate());
      await setValue(ADMOB_INTERSTITIAL_ID, res.adsconfiguration!.admobInterstitialId.validate());
      await setValue(ADMOB_BANNER_ID_IOS, res.adsconfiguration!.admobBannerIdIos.validate());
      await setValue(ADMOB_INTERSTITIAL_ID_IOS, res.adsconfiguration!.admobInterstitialIdIos.validate());
      
      await setValue(ADMOB_NATIVE_ID, res.adsconfiguration!.admobNativeId.validate());
      await setValue(ADMOB_NATIVE_ID_IOS, res.adsconfiguration!.admobNativeIdIos.validate());
      await setValue(ADMOB_ADAPTIVE_BANNER_ID, res.adsconfiguration!.admobAdaptiveBannerId.validate());
      await setValue(ADMOB_ADAPTIVE_BANNER_ID_IOS, res.adsconfiguration!.admobAdaptiveBannerIdIos.validate());
      await setValue(ADMOB_REWARDED_ID, res.adsconfiguration!.admobRewardedId.validate());
      await setValue(ADMOB_REWARDED_ID_IOS, res.adsconfiguration!.admobRewardedIdIos.validate());
      
      await setValue(FACEBOOK_NATIVE_ID, res.adsconfiguration!.facebookNativeId.validate());
      await setValue(FACEBOOK_NATIVE_ID_IOS, res.adsconfiguration!.facebookNativeIdIos.validate());
      await setValue(FACEBOOK_REWARDED_ID, res.adsconfiguration!.facebookRewardedId.validate());
      await setValue(FACEBOOK_REWARDED_ID_IOS, res.adsconfiguration!.facebookRewardedIdIos.validate());

      if (res.adsconfiguration!.interstitialAdsInterval.validate().isEmptyOrNull) {
        await setValue(INTERSTITIAL_ADS_INTERVAL, "1");
      } else {
        await setValue(INTERSTITIAL_ADS_INTERVAL, res.adsconfiguration!.interstitialAdsInterval.validate());
      }

      await setValue(BANNER_AD_BOOK_LIST, res.adsconfiguration!.bannerAdBookList.validate());
      await setValue(BANNER_AD_CATEGORY_LIST, res.adsconfiguration!.bannerAdCategoryList.validate());
      await setValue(BANNER_AD_BOOK_DETAIL, res.adsconfiguration!.bannerAdBookDetail.validate());
      await setValue(BANNER_AD_BOOK_SEARCH, res.adsconfiguration!.bannerAdBookSearch.validate());
      await setValue(INTERSTITIAL_AD_BOOK_LIST, res.adsconfiguration!.interstitialAdBookList.validate());
      await setValue(INTERSTITIAL_AD_CATEGORY_LIST, res.adsconfiguration!.interstitialAdCategoryList.validate());
      await setValue(INTERSTITIAL_AD_BOOK_DETAIL, res.adsconfiguration!.interstitialAdBookDetail.validate());
      await setValue(BANNER_AD_AUTHOR_LIST, res.adsconfiguration!.bannerAdAuthorList.validate());
      await setValue(BANNER_AD_AUTHOR_DETAIL, res.adsconfiguration!.bannerAdAuthorDetail.validate());
      await setValue(INTERSTITIAL_AD_AUTHOR_LIST, res.adsconfiguration!.interstitialAdAuthorList.validate());
      await setValue(INTERSTITIAL_AD_AUTHOR_DETAIL, res.adsconfiguration!.interstitialAdAuthorDetail.validate());
    }
    return res;
  });
}

Future<List<Book>> getBooks({int? id, bool isFilter = false, Map? request, int? page}) async {
  Iterable it = await (handleResponse(await buildHttpResponse('book.php', request: request, method: HttpMethod.POST)));
  return it.map((e) => Book.fromJson(e)).toList();
}

/// ✅ Step 1: Updated getFilterBooks function
Future<List<Book>> getFilterBooks(
    {List<String>? list,
      String? searchText,
      bool? isPopular = false,
      bool? isFeature = false,
      int? categoryId,
      bool? isCategory = false,
      bool? isLatest = false,
      int? page}) async {
  try {
    final multiPartRequest = MultipartRequest('POST', Uri.parse('$mDomainUrl${'book.php'}'));
    multiPartRequest.fields['page'] = page?.toString() ?? '1';

    if (isPopular == true) {
      multiPartRequest.fields['is_popular'] = "true";
    } else if (isFeature == true) {
      multiPartRequest.fields['is_featured'] = "true";
    } else if (isCategory == true) {
      multiPartRequest.fields['category_id'] = categoryId.toString();
    } else if (isLatest == true) {
      multiPartRequest.fields['order'] = "desc";
      multiPartRequest.fields['order_by'] = "id";
    } else if (searchText != null && searchText.isNotEmpty) {
      multiPartRequest.fields['search_text'] = searchText;
    } else if (list != null) {
      multiPartRequest.fields['category_ids'] = list.join(",");
    }

    multiPartRequest.headers.addAll(buildHeaderTokens(endPoint: 'book.php'));

    final streamedResponse = await multiPartRequest.send();
    final response = await Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return [];

      final responseJson = json.decode(response.body);
      final mCategory = responseJson as Iterable?;

      return mCategory?.map((e) => Book.fromJson(e)).toList() ?? [];
    } else {
      throw Exception('Failed to load books. Status: ${response.statusCode}');
    }
  } catch (e) {
    print("Error in getFilterBooks: $e");
    rethrow;
  }
}

Future<List<Book>> getFavourite() async {
  return wishListStore.wishList;
}

Future<List<Author>> getAuthor() async {
  Iterable it = await (handleResponse(await buildHttpResponse('author.php?limit=$AUTHOR_LIMIT', method: HttpMethod.GET)));
  return it.map((e) => Author.fromJson(e)).toList();
}

/// ✅ Step 2: Updated getAuthorBook function
Future<List<Book>> getAuthorBook(Map? request) async {
  try {
    final multiPartRequest = MultipartRequest('POST', Uri.parse('$mDomainUrl${'book.php'}'));

    request?.forEach((key, value) {
      if (value != null) multiPartRequest.fields[key.toString()] = value.toString();
    });

    multiPartRequest.headers.addAll(buildHeaderTokens());

    final response = await Response.fromStream(await multiPartRequest.send());

    if (response.statusCode != 200 || response.body.isEmpty) return [];

    final responseJson = json.decode(response.body);
    return (responseJson as Iterable).map((e) => Book.fromJson(e)).toList();
  } catch (e) {
    print("Error in getAuthorBook: $e");
    rethrow;
  }
}

/// Destek mesajı gönder
Future<Map<String, dynamic>> sendSupportMessage({
  required String subject,
  required String message,
  String? email,
  String? name,
}) async {
  final response = await buildHttpResponse(
    'support/send_message.php',
    method: HttpMethod.POST,
    request: {
      'subject': subject,
      'message': message,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
    },
  );
  return await handleResponse(response);
}

/// Reklam izleyip jeton kazanma bildirimi
Future<Map<String, dynamic>> rewardAd() async {
  final response = await buildHttpResponse(
    'coins/reward-ad.php',
    method: HttpMethod.POST,
  );
  return await handleResponse(response);
}

/// Reklam limiti ön-yoxlama (jeton vermədən yalnız limit yoxlayır)
Future<Map<String, dynamic>> checkAdLimit() async {
  final response = await buildHttpResponse(
    'coins/reward-ad.php',
    method: HttpMethod.POST,
    request: {'check_only': true},
  );
  return await handleResponse(response);
}

/// Jeton ile kitap açma (harcanan jetonlar iade edilmez)
Future<Map<String, dynamic>> unlockBookWithCoins(String bookId) async {
  final response = await buildHttpResponse(
    'books/unlock-with-coins.php',
    method: HttpMethod.POST,
    request: {
      'book_id': bookId,
    },
  );
  return await handleResponse(response);
}

/// Kitaba erişim yetkisi var mı anlık olarak kontrol et
Future<Map<String, dynamic>> checkBookAccess(String bookId, String userId) async {
  final response = await buildHttpResponse(
    'books/check-access.php',
    method: HttpMethod.POST,
    request: {
      'book_id': bookId,
      'user_id': userId,
    },
  );
  return await handleResponse(response);
}

/// API yanıtından jeton paket listesini parse eder (test edilebilir saf fonksiyon).
List<CoinPackage> parseCoinPackagesResponse(dynamic data) {
  if (data is List) {
    return data.map((e) => CoinPackage.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  if (data is Map && data['packages'] != null) {
    final list = data['packages'] as List;
    return list.map((e) => CoinPackage.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  return [];
}

/// Admin tarafından eklenen jeton paketlerini getir (SKU, coin miktarı vb.)
Future<List<CoinPackage>> getCoinPackages() async {
  final response = await buildHttpResponse(
    'coins/packages.php',
    method: HttpMethod.GET,
  );
  final data = await handleResponse(response);
  return parseCoinPackagesResponse(data);
}

/// Jeton satın alımını backend'de doğrula; Google'dan gelen token ile coin eklenir.
Future<Map<String, dynamic>> verifyCoinPurchase({
  required String purchaseToken,
  required String productId,
  required String orderId,
  required String purchaseTime,
}) async {
  final response = await buildHttpResponse(
    'coins/verify-purchase.php',
    method: HttpMethod.POST,
    request: {
      'purchase_token': purchaseToken,
      'product_id': productId,
      'order_id': orderId,
      'purchase_time': purchaseTime,
      'type': Platform.isAndroid ? 'android' : 'ios',
    },
  );
  return await handleResponse(response);
}

