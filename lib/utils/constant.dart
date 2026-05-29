import '../utils/Extensions/shared_pref.dart';

const AppName = "Litrex eBook";

/// Note: /api/ is required after your domain. Ex if your domain is www.abc.com then ${mBaseUrl} will be  https://www.abc.com/api/
/// Note: Do not end base url with Slash (/)
const mBaseUrl = 'https://litresfer.com';
const mDomainUrl = "$mBaseUrl/api/";

// Facebook
const FACEBOOK_KEY = '';
const fbBannerId = "YOUR_FACEBOOK_BANNER_ID";
const fbBannerIdIos = "YOUR_FACEBOOK_BANNER_ID_IOS";
const fbInterstitialId = "YOUR_FACEBOOK_INTERSTITIAL_ID";
const fbInterstitialIdIos = "YOUR_FACEBOOK_INTERSTITIAL_ID_IOS";

//AdmobId
const adMobBannerId = "ca-app-pub-3940256099942544/6300978111"; // Test ID
const adMobInterstitialId = "ca-app-pub-3940256099942544/1033173712"; // Test ID
const adMobBannerIdIos = "ca-app-pub-3940256099942544/2934735716"; // Test ID
const adMobInterstitialIdIos = "ca-app-pub-3940256099942544/4411468910"; // Test ID
const adMobRewardedId = "ca-app-pub-3940256099942544/5224354917"; // Test ID
const adMobRewardedIdIos = "ca-app-pub-3940256099942544/1712485313"; // Test ID

const mOneSignalID = 'fa92acd8-f88e-4d26-9077-7836bade6c9b';

const ADD_TYPE = 'ads_type';
const NONE = 'none';
const FACEBOOK_BANNER_PLACEMENT_ID = 'facebook_banner_id';
const FACEBOOK_INTERSTITIAL_PLACEMENT_ID = 'facebook_interstitial_id';
const FACEBOOK_BANNER_PLACEMENT_ID_IOS = 'facebook_banner_id_ios';
const FACEBOOK_INTERSTITIAL_PLACEMENT_ID_IOS = 'facebook_interstitial_id_ios';

const ADMOB_BANNER_ID = 'admob_banner_id';
const ADMOB_INTERSTITIAL_ID = 'admob_interstitial_id';
const ADMOB_BANNER_ID_IOS = 'admob_banner_id_ios';
const ADMOB_INTERSTITIAL_ID_IOS = 'admob_interstitial_id_ios';
const ADMOB_NATIVE_ID = 'admob_native_id';
const ADMOB_NATIVE_ID_IOS = 'admob_native_id_ios';
const ADMOB_ADAPTIVE_BANNER_ID = 'admob_adaptive_banner_id';
const ADMOB_ADAPTIVE_BANNER_ID_IOS = 'admob_adaptive_banner_id_ios';
const ADMOB_REWARDED_ID = 'admob_rewarded_id';
const ADMOB_REWARDED_ID_IOS = 'admob_rewarded_id_ios';

const FACEBOOK_NATIVE_ID = 'facebook_native_id';
const FACEBOOK_NATIVE_ID_IOS = 'facebook_native_id_ios';
const FACEBOOK_REWARDED_ID = 'facebook_rewarded_id';
const FACEBOOK_REWARDED_ID_IOS = 'facebook_rewarded_id_ios';

const INTERSTITIAL_ADS_INTERVAL = "interstitial_ads_interval";
const BANNER_AD_BOOK_LIST = "banner_ad_book_list";
const BANNER_AD_CATEGORY_LIST = "banner_ad_category_list";
const BANNER_AD_AUTHOR_LIST = "banner_ad_author_list";
const BANNER_AD_AUTHOR_DETAIL = "banner_ad_author_detail";
const BANNER_AD_BOOK_DETAIL = "banner_ad_book_detail";
const BANNER_AD_BOOK_SEARCH = "banner_ad_book_search";
const INTERSTITIAL_AD_BOOK_LIST = "interstitial_ad_book_list";
const INTERSTITIAL_AD_CATEGORY_LIST = "interstitial_ad_category_list";
const INTERSTITIAL_AD_BOOK_DETAIL = "interstitial_ad_book_detail";
const INTERSTITIAL_AD_AUTHOR_LIST = "interstitial_ad_author_list";
const INTERSTITIAL_AD_AUTHOR_DETAIL = "interstitial_ad_author_detail";

const TERMS_AND_CONDITION_PREF = 'TermsAndConditionPref';
const PRIVACY_POLICY_PREF = 'PrivacyPolicyPref';
const CONTACT_PREF = 'ContactPref';
const ABOUT_US_PREF = 'AboutUsPref';
const FACEBOOK = 'facebook';
const WHATSAPP = 'whatsapp';
const TWITTER = 'twitter';
const INSTAGRAM = 'instagram';
const COPYRIGHT = 'copyright';
const AD_REWARD_COINS = 'ad_reward_coins';
const PDF_AD_PAGE_INTERVAL = 'pdf_ad_page_interval';
const MIN_APP_VERSION_CODE = 'min_app_version_code';
const PLAY_STORE_URL = 'play_store_url';
const WISHLIST_ITEM_LIST = 'WISHLIST_ITEM_LIST';
const IS_NOTIFICATION_ON = "IS_NOTIFICATION_ON";

// Auth Constants
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const AUTH_TOKEN = 'AUTH_TOKEN';
const USER_ID = 'USER_ID';
const USER_NAME = 'USER_NAME';
const USER_EMAIL = 'USER_EMAIL';
const USER_PHONE = 'USER_PHONE';
const USER_AVATAR = 'USER_AVATAR';
const USER_BIO = 'USER_BIO';

const msg = 'message';

const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

String isGoogleAds = "admob";
String isFacebookAds = "facebook";

String adsInterval = getStringAsync(INTERSTITIAL_ADS_INTERVAL);

String mSearchBannerAds = getStringAsync(BANNER_AD_BOOK_SEARCH);
String mAuthorBannerAds = getStringAsync(BANNER_AD_AUTHOR_LIST);
String mAuthorDetailBannerAds = getStringAsync(BANNER_AD_AUTHOR_DETAIL);
String mWebBannerAds = getStringAsync(BANNER_AD_BOOK_DETAIL);
String mViewAllBannerAds = getStringAsync(BANNER_AD_BOOK_LIST);
String mCategoryViewAllBannerAds = getStringAsync(BANNER_AD_CATEGORY_LIST);

String mCategoryViewAllInterstitialAds = getStringAsync(
  INTERSTITIAL_AD_CATEGORY_LIST,
);
String mWebInterstitialAds = getStringAsync(INTERSTITIAL_AD_BOOK_DETAIL);
String mAuthorListInterstitialAds = getStringAsync(INTERSTITIAL_AD_AUTHOR_LIST);
String mAuthorDetailInterstitialAds = getStringAsync(
  INTERSTITIAL_AD_AUTHOR_DETAIL,
);
String mViewAllInterstitialAds = getStringAsync(INTERSTITIAL_AD_BOOK_LIST);

final String chooseTopicList = 'chooseTopicList';

AppThemeMode appThemeMode = AppThemeMode();

class AppThemeMode {
  final int themeModeLight = 1;
  final int themeModeDark = 2;
  final int themeModeSystem = 0;
}

const AUTHOR_LIMIT = 100;
const CATEGORY_LIMIT = 50;

class DefaultValues {
  final String defaultLanguage = "tr";
}

DefaultValues defaultValues = DefaultValues();
