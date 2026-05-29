import 'package:flutter/material.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../main.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/constant.dart';
import '../utils/images.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.lblAboutUs, color: primaryColor, showBack: true, elevation: 0, textColor: Colors.white),
      bottomNavigationBar: SizedBox(
        height: 120,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    var whatsappUrl = "whatsapp://send?phone=${getStringAsync(WHATSAPP)}";
                    launchUrl(Uri.parse(whatsappUrl),mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 16),
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_whatsApp, height: 35, width: 35),
                  ),
                ).visible(!getStringAsync(WHATSAPP).isEmptyOrNull),
                InkWell(
                  onTap: () {
                    launchUrl(Uri.parse(getStringAsync(INSTAGRAM)),mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_insta, height: 35, width: 35),
                  ),
                ).visible(!getStringAsync(INSTAGRAM).isEmptyOrNull),
                InkWell(
                  onTap: () {
                    launchUrlString(getStringAsync(TWITTER),mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_twitter, height: 35, width: 35),
                  ),
                ).visible(!getStringAsync(TWITTER).isEmptyOrNull),
                InkWell(
                  onTap: () {
                    launchUrlString(getStringAsync(FACEBOOK),mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_facebook, height: 35, width: 35),
                  ),
                ).visible(!getStringAsync(FACEBOOK).isEmptyOrNull),
                InkWell(
                  onTap: () {
                    if (getStringAsync(CONTACT_PREF).isNotEmpty) {
                      launchUrlString(('tel://${getStringAsync(CONTACT_PREF).validate()}'),mode: LaunchMode.externalApplication);
                    } else {
                      toast(language.lblUrlEmpty);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.call,
                      color: appStore.isDarkModeOn ? Colors.white : primaryColor,
                      size: 36,
                    ),
                  ),
                ).visible(!getStringAsync(CONTACT_PREF).isEmptyOrNull)
              ],
            ),
            8.height,
            Text(getStringAsync(COPYRIGHT), style: secondaryTextStyle(letterSpacing: 1.2), maxLines: 1),
            8.height,
            // showBannerAds()
          ],
        ),
      ),
      body: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (_, snap) {
            if (snap.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(snap.data!.appName.validate(), style: boldTextStyle(size: 20, color: primaryColor)),
                  2.height,
                  Container(height: 2, width: 110, color: primaryColor),
                  16.height,
                  Text('V ${snap.data!.version.validate()}', style: secondaryTextStyle()),
                  2.height,
                  Text(getStringAsync(ABOUT_US_PREF), style: secondaryTextStyle(), textAlign: TextAlign.justify),
                ],
              ).paddingAll(24);
            }
            return SizedBox();
          }),
    );
  }
}
