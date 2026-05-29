import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../store/AppStore.dart';
import '../store/AuthStore.dart';
import '../store/WishListStore/WishListStore.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/device_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/appWidget.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'AppTheme.dart';
import 'language/AppLocalizations.dart';
import 'screen/DashboardScreen.dart';
import 'language/BaseLanguage.dart';
import 'model/DashboardResponse.dart';
import 'model/LanguageDataModel.dart';
import 'screen/SplashScreen.dart';

AppStore appStore = AppStore();
AuthStore authStore = AuthStore();
WishListStore wishListStore = WishListStore();
late SharedPreferences sharedPreferences;
bool isCurrentlyOnNoInternet = false;

Color defaultLoaderBgColorGlobal = Colors.white;
Color? defaultLoaderAccentColorGlobal = primaryColor;

int passwordLengthGlobal = 6;
int mAdShowBookListCount = 0;
int mAdShowAuthorListCount = 0;
int mAdShowCategoryListCount = 0;
int mAdShowBookDetailCount = 0;
int mAdShowAuthorDetailCount = 0;
final navigatorKey = GlobalKey<NavigatorState>();

late BaseLanguage language;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;

Future<void> initialize({
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel = getSelectedLanguageModel(defaultLanguage: defaultLanguage);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();

  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await setValue('CURRENT_APP_VERSION_CODE', packageInfo.buildNumber);
  } catch (e) {
    print("PackageInfo error: $e");
  }

  appStore.setNotification(getBoolAsync(IS_NOTIFICATION_ON));
  String wishListString = getStringAsync(WISHLIST_ITEM_LIST);
  if (wishListString.isNotEmpty) {
    wishListStore.addAllWishListItem(
      jsonDecode(wishListString).map<Book>((e) => Book.fromJson(e)).toList(),
    );
  }

  if (isMobile) {
    // ANR qarşısını almaq üçün Firebase arxaplanda işə salınır
    Firebase.initializeApp().then((value) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    });
    oneSignalData();
  }

  if (!isWeb) {
    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == appThemeMode.themeModeLight) {
      appStore.setDarkMode(false);
    } else if (themeModeIndex == appThemeMode.themeModeDark) {
      appStore.setDarkMode(true);
    }
  }

  await initialize(aLocaleLanguageList: languageList());
  appStore.setLanguage(DEFAULT_LANGUAGE);

  runApp(const MyApp());
}

void oneSignalData() {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.consentRequired(false);

  OneSignal.initialize(mOneSignalID);
  OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print('NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
    event.preventDefault();
    event.notification.display();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    init();
    initDeepLinks();
  }

  void initDeepLinks() async {
    _appLinks = AppLinks();

    // Cold start deep link
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      log("DeepLink Error: $e");
    }

    // Warm/hot start deep links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      log("DeepLink Stream Error: $err");
    });
  }

  void _handleDeepLink(Uri uri) {
    log("Received Deep Link: $uri");
    if (uri.scheme == 'olib' && uri.host == 'addon') {
      final String? addonUrl = uri.queryParameters['url'];
      if (addonUrl != null && addonUrl.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAddonPromptDialog(addonUrl);
        });
      }
    }
  }

  void _showAddonPromptDialog(String addonUrl) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(language.lblAddNewAddon, style: boldTextStyle(size: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.lblEnterManifestUrl, style: secondaryTextStyle()),
            12.height,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                addonUrl,
                style: primaryTextStyle(size: 13, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.lblCancel, style: primaryTextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              List<String> urls = getStringListAsync('addon_urls') ?? [];
              
              // Migrate legacy url if exists
              String legacyUrl = getStringAsync('addon_url');
              if (legacyUrl.isNotEmpty && !urls.contains(legacyUrl)) {
                urls.add(legacyUrl);
                await setValue('addon_urls', urls);
                await setValue('addon_url', '');
              }

              if (urls.contains(addonUrl)) {
                toast(language.lblUrlAlreadyExists);
                return;
              }

              if (urls.length >= 5) {
                toast(language.lblMaxAddonsLimit);
                return;
              }

              urls.add(addonUrl);
              await setValue('addon_urls', urls);
              toast(language.lblAddonAddedSuccess);
              
              // Refresh app by restarting Dashboard
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(language.lblYes, style: boldTextStyle(color: Colors.white, size: 14)),
          ),
        ],
      ),
    );
  }

  void init() async {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      wishListStore.setConnectionState(e);
      if (e == ConnectivityResult.none) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        // Do not block the user with NoInternetScreen
        toast(language.lblOfflineReadToast);
      } else {
        if (isCurrentlyOnNoInternet) {
          isCurrentlyOnNoInternet = false;
          toast('Internet is connected.');
        }
        log('connected');
      }
    });
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        title: AppName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkModeOn ? ThemeMode.dark : ThemeMode.light,
        scrollBehavior: SBehavior(),
        navigatorKey: navigatorKey,
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage.validate(value: DEFAULT_LANGUAGE)),
      );
    });
  }
}
