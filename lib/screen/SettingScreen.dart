import 'package:flutter/cupertino.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../screen/AuthorListScreen.dart';
import '../screen/ChooseTopicScreen.dart';
import '../screen/SelectThemeScreen.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../component/SettingItemWidget.dart';
import '../main.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/device_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import 'AboutUsScreen.dart';
import 'LanguageScreen.dart';
import 'WebViewScreen.dart';
import '../network/AuthApis.dart';
import 'auth/LoginScreen.dart';
import 'DynamicAddonScreen.dart';

class SettingScreen extends StatefulWidget {
  static String tag = '/SettingScreen';
  final Function onTap;

  const SettingScreen({super.key, required this.onTap});

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    FacebookAudienceNetwork.init(
        testingId: FACEBOOK_KEY, iOSAdvertiserTrackingEnabled: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget mLeadingWidget(var icon) {
    return Icon(icon, color: textPrimaryColorGlobal);
  }

  Widget mTailingIcon() {
    return Icon(
      Icons.chevron_right,
      color: textSecondaryColorGlobal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.lblSetting,
          color: primaryColor, textColor: Colors.white, showBack: false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddonWidget(context),
            Divider(height: 0),
            SettingItemWidget(
              title: language.lblAuthors,
              trailing: mTailingIcon(),
              subTitle: language.lblAuthorsDes,
              leading: mLeadingWidget(Feather.users),
              onTap: () async {
                AuthorListScreen().launch(context);
              },
            ),
            Divider(height: 0),
            SettingItemWidget(
              title: language.lblChooseTopic,
              trailing: mTailingIcon(),
              subTitle: language.lblChooseTopicTitle,
              leading: mLeadingWidget(
                  MaterialCommunityIcons.checkbox_marked_outline),
              onTap: () async {
                ChooseTopicScreen().launch(context);
              },
            ),
            Divider(height: 0),
            SettingItemWidget(
              title: language.lblSelectTheme,
              subTitle: language.lblChooseTheme,
              onTap: () async {
                bool res = await SelectThemeScreen().launch(context,
                    pageRouteAnimation: PageRouteAnimation.Slide);
                if (res == true) setState(() {});
                widget.onTap.call();
              },
              trailing: mTailingIcon(),
              leading: mLeadingWidget(MaterialCommunityIcons.theme_light_dark),
            ),
            Divider(height: 0),
            SettingItemWidget(
              title: language.lblLanguage,
              subTitle: language.lblLanguageDesc,
              leading: Icon(Ionicons.language_outline),
              trailing: mTailingIcon(),
              onTap: () async {
                bool res = await LanguageScreen().launch(context);
                if (res == true) setState(() {});
              },
            ),
            Divider(height: 0),
            SettingItemWidget(
              title: language.lblPushNotification,
              subTitle: language.lblDisableNotification,
              leading: mLeadingWidget(Ionicons.md_notifications_outline),
              onTap: () async {},
              trailing: Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  activeTrackColor: primaryColor,
                  value: appStore.isNotificationOn,
                  onChanged: (v) {
                    appStore.setNotification(v);
                    setState(() {});
                  },
                ).withHeight(10),
              ),
            ),
            16.height,
            Divider(thickness: 3).paddingOnly(left: 16, right: 16),
            16.height,
            Row(
              children: [
                Container(color: primaryColor, width: 4, height: 16),
                6.width,
                Text(language.lblOthers,
                    style: boldTextStyle(color: primaryColor, size: 14)),
              ],
            ).paddingOnly(left: 16, right: 16, bottom: 4),
            SettingItemWidget(
              title: language.lblRateUs,
              trailing: mTailingIcon(),
              onTap: () {
                if (isApple) {
                  launch('https://apps.apple.com/us/app/litrex-e-kitap-oku/id6774904816');
                } else {
                  PackageInfo.fromPlatform().then((value) {
                    String package = '';
                    if (isAndroid) package = value.packageName;
                    launch('${storeBaseURL()}$package');
                  });
                }
              },
            ),
            SettingItemWidget(
              title: language.lblPrivacyPolicy,
              trailing: mTailingIcon(),
              onTap: () {
                if (getStringAsync(PRIVACY_POLICY_PREF).isNotEmpty) {
                  WebViewScreen(
                          title: language.lblPrivacyPolicy,
                          mInitialUrl: getStringAsync(PRIVACY_POLICY_PREF))
                      .launch(context);
                } else {
                  toast(language.lblUrlEmpty);
                }
              },
            ).visible(!getStringAsync(PRIVACY_POLICY_PREF).isEmptyOrNull),
            SettingItemWidget(
              title: language.lblTermsCondition,
              trailing: mTailingIcon(),
              onTap: () async {
                if (getStringAsync(TERMS_AND_CONDITION_PREF).isNotEmpty) {
                  WebViewScreen(
                          title: language.lblTermsCondition,
                          mInitialUrl: getStringAsync(TERMS_AND_CONDITION_PREF))
                      .launch(context);
                } else {
                  toast(language.lblUrlEmpty);
                }
              },
            ).visible(!getStringAsync(TERMS_AND_CONDITION_PREF).isEmptyOrNull),
            SettingItemWidget(
              title: language.lblAboutUs,
              trailing: mTailingIcon(),
              onTap: () {
                AboutUsScreen().launch(context,
                    pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              },
            ),

            // Hesap Yönetimi (Sadece giriş yapılmışsa)
            if (authStore.isLoggedIn) ...[
              16.height,
              Divider(thickness: 3).paddingOnly(left: 16, right: 16),
              16.height,
              Row(
                children: [
                  Container(color: Colors.red, width: 4, height: 16),
                  6.width,
                  Text(language.lblDeleteAccount,
                      style: boldTextStyle(color: Colors.red, size: 14)),
                ],
              ).paddingOnly(left: 16, right: 16, bottom: 4),
              SettingItemWidget(
                title: language.lblDeleteAccount,
                subTitle: language.lblDeleteAccountWarning,
                leading: Icon(Ionicons.trash_outline, color: Colors.red),
                titleTextStyle: boldTextStyle(color: Colors.red),
                onTap: () {
                  // ProfileScreen'deki diyalogu buraya da taşıyabiliriz veya oraya yönlendirebiliriz.
                  // Şimdilik doğrudan silme akışını başlatalım (ProfileScreen'deki ile aynı)
                  _showDeleteAccountDialog(context);
                },
              ),
            ],
            16.height,
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: radius(16)),
        title: Text(language.lblDeleteAccount,
            style: boldTextStyle(size: 18, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.lblDeleteAccountWarning,
                style: primaryTextStyle(size: 14)),
            16.height,
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: language.lblPassword,
                hintText: language.lblEnterPasswordToConfirm,
                border: OutlineInputBorder(borderRadius: radius(12)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.lblCancel,
                style: primaryTextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                toast(language.lblPleaseEnterPassword);
                return;
              }

              Navigator.pop(context);

              try {
                final response =
                    await deleteAccount(password: passwordController.text);

                if (response['success'] == true) {
                  await authStore.logout();
                  toast(language.lblAccountDeleted);
                  LoginScreen().launch(context, isNewTask: true);
                } else {
                  toast(response['message'] ?? language.lblSomethingWentWrong);
                }
              } catch (e) {
                toast(e.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: radius(10)),
            ),
            child: Text(language.lblDelete,
                style: boldTextStyle(color: Colors.white, size: 14)),
          ),
        ],
      ),
    );
  }

  List<String> _getAddonUrls() {
    List<String> list = getStringListAsync('addon_urls') ?? [];
    String legacyUrl = getStringAsync('addon_url');
    if (legacyUrl.isNotEmpty && !list.contains(legacyUrl)) {
      list.add(legacyUrl);
      setValue('addon_urls', list);
      setValue('addon_url', '');
    }
    return list;
  }

  Widget _buildAddonWidget(BuildContext context) {
    List<String> urls = _getAddonUrls();
    bool isConnected = urls.isNotEmpty;

    return InkWell(
      onTap: () {
        _showAddonManagerDialog(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isConnected
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: radius(10),
              ),
              child: Icon(
                isConnected
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                color: isConnected ? Colors.green : Colors.grey,
                size: 22,
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.lblAddons, style: boldTextStyle(size: 15)),
                  4.height,
                  Text(
                    isConnected
                        ? "${urls.length} ${language.lblAddonConnected}"
                        : language.lblAddonConnectHarici,
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green : Colors.grey.shade300,
                borderRadius: radius(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.check_circle : Icons.link_off,
                    color: Colors.white,
                    size: 14,
                  ),
                  4.width,
                  Text(
                    isConnected
                        ? language.lblAddonConnectedStatus
                        : language.lblAddonDisconnectedStatus,
                    style: boldTextStyle(color: Colors.white, size: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddonManagerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            List<String> urls = _getAddonUrls();
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: radius(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.lblAddonManager,
                      style: boldTextStyle(size: 18)),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.green, size: 28),
                    onPressed: () {
                      _showAddonInputDialog(context, () {
                        setStateDialog(() {});
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: urls.isEmpty
                    ? Text(language.lblNoAddonsYet, style: secondaryTextStyle())
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: urls.length,
                        separatorBuilder: (_, __) => Divider(),
                        itemBuilder: (context, index) {
                          String url = urls[index];
                          String displayUrl = url.length > 35
                              ? url.substring(0, 32) + "..."
                              : url;
                          return Row(
                            children: [
                              Icon(Icons.link, color: primaryColor, size: 20),
                              8.width,
                              Expanded(
                                child: Text(displayUrl,
                                    style: primaryTextStyle(size: 14)),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () async {
                                  urls.remove(url);
                                  await setValue('addon_urls', urls);
                                  setStateDialog(() {});
                                  setState(() {});
                                  toast(language.lblAddonDeleted);
                                },
                              ),
                            ],
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => finish(context),
                  child: Text(language.lblClose,
                      style: boldTextStyle(color: primaryColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddonInputDialog(BuildContext context, VoidCallback onSave) {
    TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: radius(16)),
          title: Text(language.lblAddNewAddon, style: boldTextStyle(size: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(language.lblEnterManifestUrl, style: secondaryTextStyle()),
              16.height,
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: language.lblAddonHint,
                  border: OutlineInputBorder(borderRadius: radius(12)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => finish(context),
              child: Text(language.lblCancel,
                  style: primaryTextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (urlController.text.isNotEmpty) {
                  List<String> urls = _getAddonUrls();
                  String newUrl = urlController.text.trim();
                  if (urls.length >= 5) {
                    toast(language.lblMaxAddonsLimit);
                    return;
                  }
                  if (!urls.contains(newUrl)) {
                    urls.add(newUrl);
                    await setValue('addon_urls', urls);
                    onSave();
                    finish(context);
                    toast(language.lblAddonAddedSuccess);
                  } else {
                    toast(language.lblUrlAlreadyExists);
                  }
                } else {
                  toast(language.lblUrlCannotBeEmpty);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: radius(10)),
              ),
              child: Text(language.lblSave,
                  style: boldTextStyle(color: Colors.white, size: 14)),
            ),
          ],
        );
      },
    );
  }
}
