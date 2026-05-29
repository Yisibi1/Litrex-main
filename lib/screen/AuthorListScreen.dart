import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../component/AuthorComponent.dart';
import '../screen/AuthorDetailScreen.dart';
import '../main.dart';
import '../model/DashboardResponse.dart';
import '../network/RestApis.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/appWidget.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/Extensions/AppTextField.dart';

class AuthorListScreen extends StatefulWidget {
  static String tag = '/AuthorListScreen';

  const AuthorListScreen({super.key});

  @override
  AuthorListScreenState createState() => AuthorListScreenState();
}

class AuthorListScreenState extends State<AuthorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Author> _originalList = [];
  List<Author> _filteredList = [];

  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (mAuthorListInterstitialAds == '1') loadInterstitialAds();

    final authors = await getAuthor();
    if (!mounted) return;
    setState(() {
      _originalList = authors;
      _filteredList = authors;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (mAuthorListInterstitialAds == '1') {
      if (mAdShowAuthorListCount < int.parse(adsInterval)) {
        mAdShowAuthorListCount++;
      } else {
        mAdShowAuthorListCount = 0;
        showInterstitialAds();
      }
    }
    _searchController.dispose();
    super.dispose();
  }

  void _filterAuthors(String query) {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) {
      setState(() => _filteredList = _originalList);
      return;
    }

    final filtered = _originalList
        .where((author) => author.name?.toLowerCase().contains(lower) ?? false)
        .toList();

    setState(() => _filteredList = filtered);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _filterAuthors('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblAuthors,
        color: primaryColor,
        textColor: Colors.white,
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Axtarış çubuğu (ikonu tıkladıqda açılır)
          if (_isSearchVisible)
            AppTextField(
              controller: _searchController,
              textFieldType: TextFieldType.OTHER,
              autoFocus: true,
              decoration: inputDecoration(
                context,
                label: language.lblSearchAuthor,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _filterAuthors,
            ).paddingSymmetric(horizontal: 16, vertical: 8),

          // Müəlliflər siyahısı
          Expanded(
            child: FutureBuilder<List<Author>>(
              future: getAuthor(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return mProgress().center();
                }

                if (snap.hasError) {
                  return Text('Error: ${snap.error}').center().paddingAll(16);
                }

                if (_filteredList.isEmpty) {
                  return Text(language.lblNoAuthorsFound).center().paddingAll(16);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 24,     // AppBar ilə ilk müəllif arasında əlavə boşluq
                    bottom: 16,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: 16,
                    spacing: 10,
                    children: List.generate(
                      _filteredList.length,
                          (index) {
                        final Author data = _filteredList[index];
                        return AnimationConfiguration.staggeredGrid(
                          duration: const Duration(milliseconds: 750),
                          columnCount: 1,
                          position: index,
                          child: AuthorComponent(
                            data,
                            onTap: () {
                              AuthorDetailScreen(data).launch(context);
                            },
                          ),
                        );
                      },
                    ),
                  ).paddingOnly(left: 6),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: mAuthorBannerAds == '1' ? showBannerAds() : const SizedBox(),
    );
  }
}