import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/Extensions/shared_pref.dart';
import '../component/ItemWidget.dart';
import '../model/DashboardResponse.dart';
import '../network/RestApis.dart';
import '../network/NetworkUtils.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/appWidget.dart';
import '../main.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import 'BookDetailScreen.dart';
import '../component/NativeAdWidget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchCont = TextEditingController();
  ScrollController scrollController = ScrollController();

  int currentPage = 1;
  bool isLastPage = false;
  List<Book> mBookList = [];
  List<Book> mSearchList = [];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  void init() async {
    getAPI(data: searchCont.text);
  }

  void scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
      currentPage++;
      appStore.setLoading(true);
      init();
    }
  }

  void loadData(List<Book> value) {
    if (!mounted) return;
    setState(() {
      appStore.setLoading(false);
      isLastPage = false;
      if (currentPage == 1) {
        mSearchList.clear();
        mBookList.clear();
      }
      mBookList.addAll(value);
      mSearchList = List.from(mBookList);
    });
  }

  void catchData() {}

  Future getAPI({String? data}) {
    if (currentPage == 1) {
      mSearchList.clear();
      mBookList.clear();
    }
    return getFilterBooks(searchText: data, page: currentPage).then((value) {
      appStore.setLoading(false);
      isLastPage = false;
      if (data != searchCont.text && data != null) return; // Prevent race conditions
      
      setState(() {
        mBookList.addAll(value);
        mSearchList = List.from(mBookList);
      });
      if (currentPage == 1 && data != null && data.isNotEmpty) {
        _searchAddons(data);
      }
    }).catchError((e) {
      if (!mounted) return;
      isLastPage = true;
      appStore.setLoading(false);
      log(e.toString());
      if (currentPage == 1 && data != null && data.isNotEmpty) {
        _searchAddons(data);
      }
    });
  }

  Future<void> _searchAddons(String query) async {
    List<String> urls = getStringListAsync('addon_urls') ?? [];
    String legacyUrl = getStringAsync('addon_url');
    if (legacyUrl.isNotEmpty && !urls.contains(legacyUrl)) {
      urls.add(legacyUrl);
    }
    
    // Eyni Addon-un bir neçə dəfə əlavə edilməsinin qarşısını alırıq
    urls = urls.toSet().toList();
    if (urls.isEmpty) return;

    List<Future<void>> futures = urls.map((url) async {
      try {
        var manifestRes = await httpGetWithAddonHeaders(url, timeout: Duration(seconds: 8));
        if (manifestRes.statusCode == 200) {
          var manifest = jsonDecode(manifestRes.body);
          String addonName = manifest['name'] ?? 'Harici Eklenti';
          String searchUrl = manifest['endpoints']['search'];
          
          var searchRes = await httpGetWithAddonHeaders(searchUrl + Uri.encodeComponent(query), timeout: Duration(seconds: 8));
          if (searchRes.statusCode == 200) {
            var searchData = jsonDecode(searchRes.body);
            if (searchData['data'] != null) {
              List<Book> books = (searchData['data'] as List).map((e) {
                Book book = Book.fromJson(e);
                // Tag the book with addon source name
                book.addonSource = addonName;
                return book;
              }).toList();
              
              if (query == searchCont.text) { // Yalnız son yazılan sorğunun nəticəsini ekrana basırıq
                setState(() {
                  // Duplicate check before insert
                  for (var b in books) {
                    if (!mBookList.any((existing) => existing.id == b.id)) {
                      mBookList.insert(0, b);
                    }
                  }
                  mSearchList = List.from(mBookList);
                });
              }
            }
          }
        }
      } catch (e) {
        log("Addon search error ($url): $e");
      }
    }).toList();

    await Future.wait(futures);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("", color: primaryColor, textColor: Colors.white, showBack: true),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  autoFocus: true,
                  textFieldType: TextFieldType.OTHER,
                  decoration: inputDecoration(context, label: language.lblSearchBook, prefixIcon: Icon(Ionicons.search_outline)),
                  controller: searchCont,
                  onFieldSubmitted: (c) async {
                    appStore.setLoading(true);
                    getAPI(data: searchCont.text);
                  },
                  onChanged: (c) {
                    appStore.setLoading(true);
                    getAPI(data: searchCont.text);
                  },
                ).paddingOnly(left: 16, top: 16, bottom: 0, right: 16),
                if (mSearchList.isNotEmpty)
                  ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: mSearchList.length + (mSearchList.length ~/ 5),
                    padding: EdgeInsets.all(12),
                    itemBuilder: (_, i) {
                      if ((i + 1) % 6 == 0) {
                        return NativeAdWidget();
                      }

                      int bookIndex = i - (i ~/ 6);
                      if (bookIndex >= mSearchList.length) return SizedBox();

                      return ItemWidget(
                        mSearchList[bookIndex],
                        onTap: () async {
                          BookDetailScreen(data: mSearchList[bookIndex]).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                        },
                      );
                    },
                  ).expand(),
              ],
            ),
            if (mSearchList.isEmpty && !appStore.isLoading) noDataWidget(context).center(),
            if (appStore.isLoading) mProgress().center()
          ],
        );
      }),
      bottomNavigationBar: mSearchBannerAds == '1' ? showBannerAds() : SizedBox(),
    );
  }
}
