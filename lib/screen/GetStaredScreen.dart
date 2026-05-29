import 'package:flutter/material.dart';
import '../screen/auth/LoginScreen.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../main.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/constant.dart';
import 'WebViewScreen.dart';
import '../utils/colors.dart';
import '../utils/images.dart';

class GetStaredScreen extends StatefulWidget {
  static String tag = '/GetStaredScreen';

  const GetStaredScreen({super.key});

  @override
  GetStaredScreenState createState() => GetStaredScreenState();
}

class GetStaredScreenState extends State<GetStaredScreen> {
  List<Widget> pages = [];
  var selectedIndex = 0;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    pages = [
      Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(ic_walk1, height: context.height() * 0.4, fit: BoxFit.contain).paddingAll(24),
            20.height,
            Text(language.lblWalk1, style: boldTextStyle(size: 24)).paddingOnly(top: 16, left: 16),
            Text(language.lblWalk1Desc, textAlign: TextAlign.center, style: secondaryTextStyle(size: 16)).paddingOnly(right: 24, left: 16, top: 8)
          ],
        ),
      ),
      Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(ic_walk2, height: context.height() * 0.4, fit: BoxFit.contain).paddingAll(24),
            20.height,
            Text(language.lblWalk2, style: boldTextStyle(size: 24)).paddingOnly(top: 16, left: 16),
            Text(language.lblWalk2Desc, textAlign: TextAlign.center, style: secondaryTextStyle(size: 16)).paddingOnly(right: 24, left: 16, top: 8)
          ],
        ),
      ),
      Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(ic_walk3, height: context.height() * 0.4, fit: BoxFit.contain).paddingAll(24),
            20.height,
            Text(language.lblWalk3, style: boldTextStyle(size: 24)).paddingOnly(top: 16, left: 16),
            Text(language.lblWalk3Desc, textAlign: TextAlign.center, style: secondaryTextStyle(size: 16)).paddingOnly(right: 24, left: 16, top: 8)
          ],
        ),
      )
    ];
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    appStore.setNotification(true);
    // Login ekranına git
    LoginScreen().launch(context, isNewTask: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
              controller: _pageController,
              onPageChanged: (index) {
                selectedIndex = index;
                setState(() {});
              },
              children: pages),
          AnimatedPositioned(duration: Duration(seconds: 1), bottom: 70, left: 0, right: 0, child: dotIndicator(pages, selectedIndex)),
          Positioned(
              bottom: 20,
              right: 20,
              child: AnimatedCrossFade(
                  firstChild: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: radius(8),
                    ),
                    child: Text(language.lblGetStarted, style: boldTextStyle(color: Colors.white)),
                  ).onTap(_onGetStarted),
                  secondChild: SizedBox(),
                  duration: Duration(milliseconds: 300),
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                  crossFadeState: selectedIndex == (pages.length - 1) ? CrossFadeState.showFirst : CrossFadeState.showSecond)),
          if (selectedIndex == (pages.length - 1))
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  if (getStringAsync(PRIVACY_POLICY_PREF).isNotEmpty) {
                    WebViewScreen(title: language.lblPrivacyPolicy, mInitialUrl: getStringAsync(PRIVACY_POLICY_PREF)).launch(context);
                  } else {
                    toast(language.lblUrlEmpty);
                  }
                },
                child: Text(
                  language.lblPrivacyPolicy,
                  textAlign: TextAlign.center,
                  style: secondaryTextStyle(size: 11, decoration: TextDecoration.underline),
                ),
              ),
            ),
          Positioned(
              right: 8,
              top: context.statusBarHeight + 8,
              child: AnimatedContainer(duration: Duration(seconds: 1), padding: EdgeInsets.fromLTRB(16, 8, 16, 8), child: Text(language.lblSkip, style: boldTextStyle(color: primaryColor))).onTap(_onGetStarted))
        ],
      ),
    );
  }
}
