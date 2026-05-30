import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import '../../component/NoInternetComponent.dart';
import '../component/ItemWidget.dart';
import '../model/DashboardResponse.dart';
import '../network/RestApis.dart';
import '../network/NetworkUtils.dart';
import '../network/AuthApis.dart';
import '../screen/CategoryScreen.dart';
import '../screen/ViewAllScreen.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/colors.dart';
import '../component/AuthorComponent.dart';
import '../component/DialogComponent.dart';
import '../component/HomeSliderComponent.dart';
import '../component/ItemWidget.dart';
import '../component/ContinueReadingWidget.dart';
import '../component/CategoryItemWidget.dart';
import '../main.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/HorizontalList.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/appWidget.dart';
import '../utils/constant.dart';
import 'AuthorDetailScreen.dart';
import 'AuthorListScreen.dart';
import 'BookDetailScreen.dart';
import 'SearchScreen.dart';
import 'PremiumScreen.dart';
import 'DownloadScreen.dart';
import '../component/NativeAdWidget.dart';
import '../utils/OfflineReadingService.dart';
import '../component/CoinBalanceComponent.dart';
import '../component/RatingDialog.dart';
import '../component/StreakBalanceComponent.dart';

import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // ... existing variables ...
  List<Category> mCategoryList = [];
  List<Book> mPopularList = [];
  List<Book> mLatestList = [];
  List<Book> mFeaturedList = [];
  List<Book> mSuggestedList = [];
  List<String> mCategoryId = [];
  List<AppSlider> mSliderList = [];
  List<Author> mAuthorList = [];

  int? currentIndex = 0;
  bool? isLoading = true;
  String? mErrorMsg = "";
  int downloadCount = 0;

  PageController? pageController;

  // --- Reklam dəyişənləri ---
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  double _bannerHeight = 0;

  @override
  void initState() {
    super.initState();
    init();
    _loadAdaptiveBanner();
  }
  
  String _getAdaptiveAdUnitId() {
    String? adId;
    if (Platform.isIOS) {
        adId = getStringAsync(ADMOB_ADAPTIVE_BANNER_ID_IOS);
    } else {
        adId = getStringAsync(ADMOB_ADAPTIVE_BANNER_ID);
    }

    if (adId.validate().isNotEmpty) {
      return adId;
    }
    
    // Default / Fallback ID
    return 'ca-app-pub-2970306107465777/7229016697';
  }

  Future<void> _loadAdaptiveBanner() async {
    if (authStore.isPremiumUser) return;

    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: _getAdaptiveAdUnitId(),
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
            _bannerHeight = size.height.toDouble();
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Adaptive Banner failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> init() async {
    List<String>? mIdList = getStringListAsync(chooseTopicList);

    for (var element in mIdList!) {
      mCategoryId.add(element);
    }

    getFilterBooks(list: mCategoryId).then((res) {
      mSuggestedList = res;
      setState(() {});
    });

    getDashboard().then((res) {
      mSliderList = res.slider!;
      mPopularList = res.popularBook!;
      mLatestList = res.latestBook!;
      mFeaturedList = res.featuredBook!;
      mCategoryList = res.category!;
      mAuthorList = res.author!;
      isLoading = false;
      setState(() {});

      // --- Addon kitablarını birləşdir ---
      _mergeAddonBooks();
      
      // --- Məcburi Yenilənmə (Force Update) ---
      _checkForceUpdate();
      
      // --- Dəyərləndirmə Pəncərəsi ---
      _checkRating();

      // --- Reading Streaks (Alovlu Seriya) ---
      _syncStreak();
    }).catchError((e) {
      isLoading = false;
      mErrorMsg = e.toString();
      setState(() {});
    });

    OfflineReadingService().getDownloadedBooks().then((books) {
      downloadCount = books.length;
      setState(() {});
    });
  }

  Future<void> _checkForceUpdate() async {
    int minVersion = getIntAsync(MIN_APP_VERSION_CODE, defaultValue: 1);
    String playStoreUrl = getStringAsync(PLAY_STORE_URL);

    if (minVersion > 1) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentVersion = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (currentVersion > 0 && currentVersion < minVersion) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false, // Geri qayıtma düyməsini bloklayır
              child: AlertDialog(
                backgroundColor: context.cardColor,
                title: Text(language.lblUpdateAvailable, style: boldTextStyle(size: 20)),
                content: Text(language.lblUpdateRequiredMsg, style: primaryTextStyle()),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (playStoreUrl.isNotEmpty) {
                        StoreRedirect.redirect(androidAppId: "com.litrex.ebook");
                      } else {
                        StoreRedirect.redirect(androidAppId: "com.litrex.ebook");
                      }
                    },
                    child: Text(language.lblUpdateNow, style: boldTextStyle(color: primaryColor)),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _checkRating() async {
    int appOpenCount = getIntAsync('APP_OPEN_COUNT', defaultValue: 0);
    bool isRated = getBoolAsync('IS_APP_RATED', defaultValue: false);

    if (!isRated) {
      appOpenCount++;
      await setValue('APP_OPEN_COUNT', appOpenCount);

      // 3-cü və 10-cu dəfə açılanda göstər
      if (appOpenCount == 3 || appOpenCount == 10 || appOpenCount == 25) {
        // Bir az gözləyək ki, tətbiq tam açılsın
        await Future.delayed(Duration(seconds: 3));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return RatingDialog(playStoreUrl: "https://play.google.com/store/apps/details?id=com.litrex.ebook");
          },
        ).then((_) {
          // Gələcəkdə bir daha göstərməmək üçün true edə bilərik, amma istifadəçi 5 ulduz vermədisə yenə soruşa bilərik
        });
      }
    }
  }

  Future<void> _syncStreak() async {
    if (!authStore.isLoggedIn) return;

    // Sadece günde bir kez API'ye istek atmak için yerel kontrol yapalım
    String lastChecked = getStringAsync('LAST_STREAK_CHECK_DATE');
    String today = DateTime.now().toIso8601String().split('T')[0];

    if (lastChecked == today) return;

    try {
      final res = await checkStreak();
      if (res['success'] == true) {
        int streak = res['current_streak'] ?? 0;
        bool updated = res['streak_updated'] ?? false;
        int coins = res['coins_earned'] ?? 0;

        // Yerel veriyi güncelle (UI yenilenecek)
        await setValue('CURRENT_STREAK', streak);
        currentStreakNotifier.value = streak;
        await setValue('LAST_STREAK_CHECK_DATE', today);

        if (updated && coins > 0) {
          // Bakiye güncelle (authStore)
          authStore.coins += coins;
          await setValue('COINS', authStore.coins);

          // Popup göster
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded, size: 60, color: Colors.orange),
                      16.height,
                      Text("Tebrikler!", style: boldTextStyle(size: 24)),
                      12.height,
                      Text("$streak Günlük Seri!", style: boldTextStyle(size: 18, color: Colors.deepOrange)),
                      8.height,
                      Text("Günlük girişiniz için $coins Jeton kazandınız. Zinciri kırmayın!", 
                        style: secondaryTextStyle(size: 16), textAlign: TextAlign.center),
                      24.height,
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Harika", style: boldTextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size(double.infinity, 45)
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          );
        }
      }
    } catch (e) {
      log("Streak check error: $e");
    }
  }

  /// Kənar Addon bazalarından kitabları paralel çəkib mövcud siyahılara birləşdirən metod
  Future<void> _mergeAddonBooks() async {
    List<String> urls = getStringListAsync('addon_urls') ?? [];
    String legacyUrl = getStringAsync('addon_url');
    if (legacyUrl.isNotEmpty && !urls.contains(legacyUrl)) {
      urls.add(legacyUrl);
    }

    // Təkrarlanan URL-ləri təmizləyirik
    urls = urls.toSet().toList();

    print("ADDON DEBUG: ${urls.length} addon URL tapıldı: $urls");
    if (urls.isEmpty) {
      print("ADDON DEBUG: Baza URL siyahısı boşdur, çıxırıq.");
      return;
    }

    List<Future<void>> futures = urls.map((url) => _fetchAndMergeSingleAddon(url)).toList();
    await Future.wait(futures);
  }

  /// Tək bir Addon-u oxuyub birləşdirən alt metod (Biri sıradan çıxsa, digərləri işləsin)
  Future<void> _fetchAndMergeSingleAddon(String addonUrl) async {
    try {
      print("ADDON DEBUG: Manifest oxunur: $addonUrl");
      var manifestRes = await httpGetWithAddonHeaders(addonUrl, timeout: Duration(seconds: 10));
      print("ADDON DEBUG: Manifest status: ${manifestRes.statusCode}");
      if (manifestRes.statusCode != 200) return;
      var manifest = jsonDecode(manifestRes.body);

      // 2. Dashboard endpoint-dən kitabları al
      String dashboardUrl = manifest['endpoints']['dashboard'];
      print("ADDON DEBUG: Dashboard oxunur: $dashboardUrl");
      var dashRes = await httpGetWithAddonHeaders(dashboardUrl, timeout: Duration(seconds: 10));
      print("ADDON DEBUG: Dashboard status: ${dashRes.statusCode}, body length: ${dashRes.body.length}");
      if (dashRes.statusCode != 200) return;
      var dashData = jsonDecode(dashRes.body);

      // 3. Kitabları mövcud siyahılara əlavə et
      bool dataChanged = false;
      
      if (dashData['latest_book'] != null) {
        var addonBooks = (dashData['latest_book'] as List).map((e) {
          Book book = Book.fromJson(e);
          _mapCategory(book, e['category_name'] ?? '');
          return book;
        }).toList();
        print("ADDON DEBUG: ${addonBooks.length} addon kitab latest siyahısına əlavə edilir.");
        List<Book> newBooks = [];
        for (var b in addonBooks) {
          if (!mLatestList.any((existing) => existing.id == b.id)) {
            newBooks.add(b);
            dataChanged = true;
          }
        }
        mLatestList.insertAll(0, newBooks);
      }

      if (dashData['popular_book'] != null) {
        var addonBooks = (dashData['popular_book'] as List).map((e) {
          Book book = Book.fromJson(e);
          _mapCategory(book, e['category_name'] ?? '');
          return book;
        }).toList();
        List<Book> newBooks = [];
        for (var b in addonBooks) {
          if (!mPopularList.any((existing) => existing.id == b.id)) {
            newBooks.add(b);
            dataChanged = true;
          }
        }
        mPopularList.insertAll(0, newBooks);
      }

      if (dashData['featured_book'] != null) {
        var addonBooks = (dashData['featured_book'] as List).map((e) {
          Book book = Book.fromJson(e);
          _mapCategory(book, e['category_name'] ?? '');
          return book;
        }).toList();
        List<Book> newBooks = [];
        for (var b in addonBooks) {
          if (!mFeaturedList.any((existing) => existing.id == b.id)) {
            newBooks.add(b);
            dataChanged = true;
          }
        }
        mFeaturedList.insertAll(0, newBooks);
      }
      
      // Hər bir addon yükləndikdə ekrana yansımasını təmin et
      if (dataChanged && mounted) {
        setState(() {});
      }
    } catch (e) {
      print("ADDON DEBUG ERROR ($addonUrl): $e");
    }
  }

  /// Addon kitabının kateqoriyasını Litrex-in mövcud kateqoriyalarına ad üzrə uyğunlaşdırır
  void _mapCategory(Book book, String categoryName) {
    if (categoryName.isEmpty || mCategoryList.isEmpty) return;
    for (var cat in mCategoryList) {
      if (cat.name != null && cat.name!.toLowerCase() == categoryName.toLowerCase()) {
        book.categoryId = cat.id;
        book.categoryName = cat.name;
        return;
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mHeading(String title,
      {int? id,
        bool? isFeatured = false,
        bool? isLatest = false,
        bool? isPopular = false,
        bool? isSuggested = false,
        bool? isCategory = false,
        bool? isCategoryViewAll = false,
        bool? isAuthor = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: boldTextStyle(
                size: 20,
                fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w500)
                    .fontFamily)),
        IconButton(
          onPressed: () {
            if (isCategoryViewAll == true) {
              CategoryScreen(isCategory: true).launch(context);
            } else if (isAuthor == true) {
              AuthorListScreen().launch(context);
            } else {
              ViewAllScreen(
                categoryId: id,
                title: title,
                isLatest: isLatest,
                isFeatured: isFeatured,
                isCategory: isCategory,
                isSuggested: isSuggested,
                isPopular: isPopular,
              ).launch(context);
            }
          },
          icon: Icon(Icons.keyboard_arrow_right, color: textSecondaryColor),
        ),
      ],
    ).paddingOnly(left: 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(size: 28),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        title: Text(AppName,
            style: boldTextStyle(size: 20, color: Colors.white)),
        actions: [
          StreakBalanceComponent(),
          CoinBalanceComponent(),
          if (!authStore.isPremiumUser)
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
              borderRadius: radius(20),
            ),
            child: InkWell(
              onTap: () { PremiumScreen().launch(context); },
              borderRadius: radius(20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                     Icon(Icons.diamond, color: Colors.white, size: 16),
                     4.width,
                     Text("Premium", style: boldTextStyle(color: Colors.white, size: 12)),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Ionicons.search_sharp, color: Colors.white),
            onPressed: () {
              SearchScreen().launch(context);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2));
          init();
          setState(() {});
        },
        child: Stack(
          children: [
            // Əsas məzmun
            isLoading == false
                ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slider
                  if (mSliderList.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(
                          height: context.height() * 0.25,
                          width: context.width(),
                          child: PageView.builder(
                            itemCount: mSliderList.length,
                            controller: pageController,
                            itemBuilder: (context, i) {
                              return HomeSliderComponent(mSliderList[i]);
                            },
                            onPageChanged: (int i) {
                              currentIndex = i;
                              setState(() {});
                            },
                          ),
                        ),
                        dotIndicator(mSliderList, currentIndex)
                            .paddingTop(8),
                        16.height,
                      ],
                    ),

                  // Continue Reading Widget
                  ContinueReadingWidget(),

                  // Downloads Banner
                  if (downloadCount > 0)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationWithRoundedCornersWidget(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        borderRadius: radius(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            child: Icon(Ionicons.cloud_download, color: Colors.white, size: 20),
                          ),
                          16.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${language.lblYouHave} $downloadCount ${language.lblDownloadedBooks}".trim(), style: boldTextStyle(size: 14)),
                                Text(language.lblTapToStartReading, style: secondaryTextStyle(size: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
                        ],
                      ),
                    ).onTap(() {
                      DownloadScreen().launch(context).then((value) {
                         // Refresh count when returning
                         OfflineReadingService().getDownloadedBooks().then((books) {
                            downloadCount = books.length;
                            setState(() {});
                         });
                      });
                    }),
                  
                  16.height,

                  // Latest
                  if (mLatestList.isNotEmpty)
                    Column(
                      children: [
                        mHeading(language.lblLatest, isLatest: true),
                        HorizontalList(
                          itemCount: mLatestList.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          itemBuilder: (context1, index) {
                            return ItemWidget(
                              mLatestList[index],
                              isFeatured: true,
                              onTap: () async {
                                BookDetailScreen(data: mLatestList[index])
                                    .launch(context,
                                    pageRouteAnimation:
                                    PageRouteAnimation.Slide);
                              },
                            );
                          },
                        ),
                        16.height,
                      ],
                    ),

                  // Category
                  if (mCategoryList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mHeading(language.lblCategory,
                            isCategory: true, isCategoryViewAll: true),
                        Wrap(
                          alignment: WrapAlignment.start,
                          runSpacing: 12,
                          spacing: 10,
                          children: List.generate(
                            mCategoryList.length > 6
                                ? 6
                                : mCategoryList.length,
                                (index) {
                              return AnimationConfiguration.staggeredGrid(
                                duration: Duration(milliseconds: 750),
                                columnCount: 1,
                                position: index,
                                child: CategoryItemWidget(
                                  mCategoryList[index],
                                  onTap: () {
                                    ViewAllScreen(
                                      title: mCategoryList[index].name,
                                      categoryId:
                                      mCategoryList[index].id.toInt(),
                                      isCategory: true,
                                    ).launch(context);
                                  },
                                ),
                              );
                            },
                          ),
                        ).paddingOnly(left: 14, right: 12, bottom: 16)
                      ],
                    ),

                  NativeAdWidget(),


                  // Popular
                  if (mPopularList.isNotEmpty)
                    Column(
                      children: [
                        mHeading(language.lblPopular, isPopular: true),
                        HorizontalList(
                          itemCount: mPopularList.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          itemBuilder: (context1, index) {
                            return ItemWidget(
                              mPopularList[index],
                              isFeatured: true,
                              onTap: () async {
                                BookDetailScreen(data: mPopularList[index])
                                    .launch(context,
                                    pageRouteAnimation:
                                    PageRouteAnimation.Slide);
                              },
                            );
                          },
                        ),
                        16.height,
                      ],
                    ),

                  // Featured
                  if (mFeaturedList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mHeading(language.lblFeatured, isFeatured: true),
                        HorizontalList(
                          itemCount: mFeaturedList.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          itemBuilder: (context1, index) {
                            return ItemWidget(
                              mFeaturedList[index],
                              isFeatured: true,
                              onTap: () async {
                                BookDetailScreen(data: mFeaturedList[index])
                                    .launch(context,
                                    pageRouteAnimation:
                                    PageRouteAnimation.Slide);
                              },
                            );
                          },
                        ),
                        16.height,
                      ],
                    ),

                  NativeAdWidget(),

                  // Suggested
                  if (mSuggestedList.isNotEmpty)

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mHeading(language.lblSuggested,
                            isSuggested: true),
                        HorizontalList(
                          itemCount: mSuggestedList.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          itemBuilder: (context1, index) {
                            return ItemWidget(
                              mSuggestedList[index],
                              isFeatured: true,
                              onTap: () async {
                                BookDetailScreen(data: mSuggestedList[index])
                                    .launch(context,
                                    pageRouteAnimation:
                                    PageRouteAnimation.Slide);
                              },
                            );
                          },
                        ),
                        16.height,
                      ],
                    ),

                  // Authors
                  if (mAuthorList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mHeading(language.lblAuthors, isAuthor: true),
                        HorizontalList(
                          itemCount: mAuthorList.length,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context1, index) {
                            return AuthorComponent(
                              mAuthorList[index],
                              isSlider: true,
                              onTap: () async {
                                AuthorDetailScreen(mAuthorList[index])
                                    .launch(context,
                                    pageRouteAnimation:
                                    PageRouteAnimation.Slide);
                              },
                            );
                          },
                        ),
                        16.height,
                      ],
                    ),

                  // Banner üçün boşluq
                  SizedBox(height: (_isBannerAdLoaded ? _bannerHeight : 0) + 36),
                ],
              ),
            )
                : mProgress(),

            // --- Adaptive Banner (sabit alt hissədə) ---
            if (_isBannerAdLoaded && _bannerAd != null)
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),

            // İnternet yoxdur
            wishListStore.isNetworkAvailable
                ? Offstage()
                : NoInternetComponent().center(),

            // Xəta mesajı
            if (mErrorMsg != null && mErrorMsg!.isNotEmpty && isLoading == false)
              Text(mErrorMsg!, style: primaryTextStyle()).center(),
          ],
        ),
      ),
    );
  }
}