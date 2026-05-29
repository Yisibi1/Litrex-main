import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import '../component/BookmarkComponent.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../main.dart';
import '../model/DashboardResponse.dart';
import '../network/RestApis.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/HorizontalList.dart';
import '../utils/appWidget.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import 'BookDetailScreen.dart';

class AuthorDetailScreen extends StatefulWidget {
  static String tag = '/AuthorDetailScreen';
  final Author data;

  const AuthorDetailScreen(this.data, {super.key});

  @override
  AuthorDetailScreenState createState() => AuthorDetailScreenState();
}

class AuthorDetailScreenState extends State<AuthorDetailScreen> {
  List<Book> mBookList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
    var request = {'author_id': widget.data.id};
    getAuthorBook(request).then((res) {

      mBookList = res;

      if (res.isNotEmpty) {

        mBookList = res.where((book) => book.authorId == widget.data.id.toString()).toList();

        print("Filtered to ${mBookList.length} books after client-side filtering");

      }

      setState(() {});

    }).catchError((error) {

      print("Error fetching author books: $error");

      mBookList = [];

      setState(() {});

    });

    FacebookAudienceNetwork.init(
      testingId: FACEBOOK_KEY,
      iOSAdvertiserTrackingEnabled: true,
    );

    if (mAuthorDetailInterstitialAds == '1') loadInterstitialAds();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (mAuthorDetailInterstitialAds == '1') {
      if (mAdShowAuthorDetailCount < int.parse(adsInterval)) {
        mAdShowAuthorDetailCount++;
      } else {
        mAdShowAuthorDetailCount = 0;
        showInterstitialAds();
      }
    }
    super.dispose();
  }

  Widget mIcon(String icon, Function onCall) {
    return GestureDetector(
      onTap: () {
        onCall.call();
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor,
        ),
        padding: EdgeInsets.all(8),
        child: Image.asset(icon, color: Colors.white, width: 20, height: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("",color: primaryColor, textColor: Colors.white,  elevation: 0, showBack: true),
      body: ListView(
        children: [
          Container(
            width: context.width(),
            decoration: boxDecorationWithRoundedCornersWidget(backgroundColor: primaryColor.withOpacity(0.2)),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                widget.data.imageUrl != null && widget.data.imageUrl!.isNotEmpty
                    ? CircleAvatar(backgroundImage: NetworkImage(widget.data.imageUrl!), radius: 50, backgroundColor: context.cardColor)
                    : CircleAvatar(backgroundImage: AssetImage(ic_placeholder), radius: 50, backgroundColor: context.cardColor),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.data.name.toString(), style: boldTextStyle(color: primaryColor, size: 18)),
                    4.height,
                    Text(widget.data.designation.toString(), style: secondaryTextStyle(), maxLines: 2),
                    8.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        mIcon(ic_facebook, () {
                          launch(widget.data.facebookUrl!);
                        }).visible(widget.data.facebookUrl!.isNotEmpty),
                        mIcon(ic_insta, () {
                          launch(widget.data.instagramUrl!);
                        }).visible(widget.data.instagramUrl!.isNotEmpty),
                        mIcon(ic_twitter, () {
                          launch(widget.data.twitterUrl!);
                        }).visible(widget.data.twitterUrl!.isNotEmpty),
                        mIcon(ic_youtube, () {
                          launch(widget.data.youtubeUrl!);
                        }).visible(widget.data.youtubeUrl!.isNotEmpty),
                        mIcon(ic_web, () {
                          launch(widget.data.websiteUrl!);
                        }).visible(widget.data.websiteUrl!.isNotEmpty),
                      ],
                    )
                  ],
                ).expand()
              ],
            ),
          ),
          Text(language.lblAbout, style: boldTextStyle(size: 20)).paddingOnly(left: 16),
          Text(widget.data.description.toString(), style: secondaryTextStyle()).paddingOnly(left: 16, right: 16, top: 8, bottom: 16),
          if (mBookList.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.lblBooksBy, style: boldTextStyle(size: 20)).paddingOnly(left: 16),
                8.height,
                HorizontalList(
                    itemCount: mBookList.length,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    itemBuilder: (BuildContext context1, int index) {
                      return BookmarkComponent(mBookList[index], isSlider: true, onTap: () async {
                        BookDetailScreen(data: mBookList[index]).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                      });
                    }),
              ],
            )
        ],
      ),
      bottomNavigationBar: mAuthorDetailBannerAds == '1' ? showBannerAds() : SizedBox(),
    );
  }
}
