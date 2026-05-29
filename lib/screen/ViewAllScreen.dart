import 'dart:convert';
import 'package:http/http.dart' as http;
import '../component/ItemWidget.dart';
import '../network/RestApis.dart';
import '../network/NetworkUtils.dart';
import '../screen/BookDetailScreen.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/appWidget.dart';
import '../utils/constant.dart';
import '../component/NativeAdWidget.dart';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../model/DashboardResponse.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/colors.dart';

class ViewAllScreen extends StatefulWidget {
  static String tag = '/ViewAllScreen';
  final int? categoryId;
  final bool? isFeatured;
  final bool? isPopular;
  final bool? isSuggested;
  final bool? isLatest;
  final String? title;
  final bool? isCategory;

  const ViewAllScreen({super.key, this.categoryId, this.title, this.isFeatured = false, this.isLatest = false, this.isCategory = false, this.isPopular = false, this.isSuggested = false});

  @override
  ViewAllScreenState createState() => ViewAllScreenState();
}

class ViewAllScreenState extends State<ViewAllScreen> {
  ScrollController scrollController = ScrollController();

  int currentPage = 1;
  bool isLastPage = false;

  List<Book> mBookList = [];
  List<String> mCategoryId = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      scrollHandler();
    });
    FacebookAudienceNetwork.init(
      testingId: FACEBOOK_KEY,
      iOSAdvertiserTrackingEnabled: true,
    );
    if (widget.isCategory == true) {
      if (mCategoryViewAllInterstitialAds == '1') loadInterstitialAds();
    } else {
      if (mViewAllInterstitialAds == '1') loadInterstitialAds();
    }
  }

  Future<void> init() async {
    await getAPI();
    await _fetchAddons();
  }

  void scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
      currentPage++;
      init();
    }
  }

  @override
  void dispose() {
    if (widget.isCategory == true) {
      if (mCategoryViewAllInterstitialAds == '1') {
        if (mAdShowCategoryListCount < int.parse(adsInterval)) {
          mAdShowCategoryListCount++;
        } else {
          mAdShowCategoryListCount = 0;
          showInterstitialAds();
        }
      }
    } else {
      if (mViewAllInterstitialAds == '1') {
        if (mAdShowBookListCount < int.parse(adsInterval)) {
          mAdShowBookListCount++;
        } else {
          mAdShowBookListCount = 0;
          showInterstitialAds();
        }
      }
    }
    scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void loadData(List<Book> value) {
    if (!mounted) return;
    setState(() {
      appStore.setLoading(false);
      isLastPage = false;
      if (currentPage == 1) {
        mBookList.clear();
      }
      mBookList.addAll(value);
    });
  }

  void catchData() {
    if (!mounted) return;
    isLastPage = true;
    appStore.setLoading(false);
  }

  Future<Null> getAPI() {
    appStore.setLoading(true);
    if (widget.isFeatured == true) {
      return getFilterBooks(isFeature: true, page: currentPage).then((value) {
        loadData(value);
      }).catchError((e) {
        catchData();
        toast(e.toString());
      });
    } else if (widget.isPopular == true) {
      return getFilterBooks(isPopular: true, page: currentPage).then((value) {
        loadData(value);
      }).catchError((e) {
        catchData();
        toast(e.toString());
      });
    } else if (widget.isSuggested == true) {
      List<String>? mIdList = getStringListAsync(chooseTopicList);
      for (var element in mIdList!) {
        mCategoryId.add(element);
      }
      return getFilterBooks(list: mCategoryId, page: currentPage).then((value) {
        loadData(value);
      }).catchError((e) {
        catchData();
        toast(e.toString());
      });
    } else if (widget.isCategory == true) {
      return getFilterBooks(isCategory: true, categoryId: widget.categoryId, page: currentPage).then((value) {
        loadData(value);
      }).catchError((e) {
        catchData();
        toast(e.toString());
      });
    }
    if (widget.isLatest == true) {
      return getFilterBooks(isLatest: true, page: currentPage).then((value) {
        loadData(value);
      }).catchError((e) {
        catchData();
        toast(e.toString());
      });
    } else {
      return getFilterBooks(isFeature: true, page: currentPage).then((value) {
        loadData(value);
      }).catchError((e) {
        catchData();
        toast(e.toString());
      });
    }
  }

  Future<void> _fetchAddons() async {
    if (currentPage > 1) return; // Addons loaded only on first page for simplicity

    List<String> urls = getStringListAsync('addon_urls') ?? [];
    String legacyUrl = getStringAsync('addon_url');
    if (legacyUrl.isNotEmpty && !urls.contains(legacyUrl)) urls.add(legacyUrl);
    if (urls.isEmpty) return;

    List<Future<void>> futures = urls.map((url) async {
      try {
        var manifestRes = await httpGetWithAddonHeaders(url, timeout: Duration(seconds: 8));
        if (manifestRes.statusCode == 200) {
          var manifest = jsonDecode(manifestRes.body);
          String addonName = manifest['name'] ?? 'Harici Eklenti';
          
          String? targetUrl;
          if (widget.isCategory == true && widget.categoryId != null) {
            if (manifest['endpoints']['category'] != null) {
               targetUrl = manifest['endpoints']['category'] + widget.categoryId.toString();
            }
          } else if (widget.isLatest == true || widget.isPopular == true || widget.isFeatured == true) {
            if (manifest['endpoints']['dashboard'] != null) {
               var dashRes = await httpGetWithAddonHeaders(manifest['endpoints']['dashboard'], timeout: Duration(seconds: 8));
               if (dashRes.statusCode == 200) {
                 var dashData = jsonDecode(dashRes.body);
                 List<Book> addonBooks = [];
                 if (widget.isLatest == true && dashData['latest_book'] != null) {
                    addonBooks = (dashData['latest_book'] as List).map((e) => Book.fromJson(e)).toList();
                 } else if (widget.isPopular == true && dashData['popular_book'] != null) {
                    addonBooks = (dashData['popular_book'] as List).map((e) => Book.fromJson(e)).toList();
                 } else if (widget.isFeatured == true && dashData['featured_book'] != null) {
                    addonBooks = (dashData['featured_book'] as List).map((e) => Book.fromJson(e)).toList();
                 }
                 if (addonBooks.isNotEmpty) {
                    for (var b in addonBooks) b.addonSource = addonName;
                    if (mounted) {
                      setState(() {
                        List<Book> newBooks = [];
                        for (var b in addonBooks) {
                          if (!mBookList.any((existing) => existing.id == b.id)) {
                            newBooks.add(b);
                          }
                        }
                        mBookList.insertAll(0, newBooks);
                      });
                    }
                 }
               }
            }
            return;
          }
          
          if (targetUrl != null) {
            var res = await httpGetWithAddonHeaders(targetUrl, timeout: Duration(seconds: 8));
            if (res.statusCode == 200) {
              var data = jsonDecode(res.body);
              if (data['data'] != null) {
                List<Book> books = (data['data'] as List).map((e) {
                  Book book = Book.fromJson(e);
                  book.addonSource = addonName;
                  return book;
                }).toList();
                if (mounted) {
                  setState(() {
                    List<Book> newBooks = [];
                    for (var b in books) {
                      if (!mBookList.any((existing) => existing.id == b.id)) {
                        newBooks.add(b);
                      }
                    }
                    mBookList.insertAll(0, newBooks);
                  });
                }
              }
            }
          }
        }
      } catch (e) {
        log("ViewAll addon error ($url): $e");
      }
    }).toList();
    
    await Future.wait(futures);
  }

  String getTitle() {
    if (widget.isFeatured == true) {
      return language.lblFeatured;
    } else if (widget.isPopular == true) {
      return language.lblPopular;
    } else if (widget.isSuggested == true) {
      return widget.title!;
    } else
      return widget.title!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(getTitle(), color: primaryColor, textColor: Colors.white, showBack: true),
        bottomNavigationBar: widget.isCategory == true
            ? mCategoryViewAllBannerAds == '1'
                ? showBannerAds()
                : SizedBox()
            : mViewAllBannerAds == '1'
                ? showBannerAds()
                : SizedBox(),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                physics: NeverScrollableScrollPhysics(),
                itemCount: mBookList.length + (mBookList.length ~/ 5),
                padding: EdgeInsets.all(12),
                itemBuilder: (_, i) {
                  if ((i + 1) % 6 == 0) {
                    return NativeAdWidget();
                  }
                  
                  int bookIndex = i - (i ~/ 6);
                  if (bookIndex >= mBookList.length) return SizedBox();

                  return ItemWidget(
                    mBookList[bookIndex],
                    onTap: () async {
                      BookDetailScreen(data: mBookList[bookIndex]).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                    },
                  );
                },

              ),
            ),
            if (!appStore.isLoading && mBookList.isEmpty) noDataWidget(context).center(),
            mProgress().center().visible(appStore.isLoading),
          ],
        ));
  }
}
