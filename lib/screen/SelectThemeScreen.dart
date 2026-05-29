import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';

class SelectThemeScreen extends StatefulWidget {
  const SelectThemeScreen({super.key});

  @override
  _SelectThemeScreenState createState() => _SelectThemeScreenState();
}

class _SelectThemeScreenState extends State<SelectThemeScreen> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  String getName(ThemeModes themeModes) {
    switch (themeModes) {
      case ThemeModes.Light:
        return language.lblLightMode;
      case ThemeModes.Dark:
        return language.lblDarkMode;
      case ThemeModes.SystemDefault:
        return language.lblSystemDefault;
    }
  }

  Widget getIcons(BuildContext context, ThemeModes themeModes, int index) {
    switch (themeModes) {
      case ThemeModes.Light:
        return Icon(MaterialCommunityIcons.lightbulb_on_outline, color: currentIndex != index ? context.iconColor : Colors.white);
      case ThemeModes.Dark:
        return Icon(MaterialIcons.nights_stay, color: currentIndex != index ? context.iconColor : Colors.white);
      case ThemeModes.SystemDefault:
        return Icon(MaterialCommunityIcons.theme_light_dark, color: currentIndex != index ? context.iconColor : Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(language.lblSelectTheme, color: primaryColor, showBack: true, elevation: 0, textColor: Colors.white),
        body: Wrap(
          runSpacing: 16,
          children: List.generate(
            ThemeModes.values.length,
            (index) {
              return Container(
                decoration: boxDecorationDefaultWidget(color: currentIndex == index ? primaryColor : context.scaffoldBackgroundColor, border: Border.all(color: context.dividerColor)),
                width: context.width(),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(getName(ThemeModes.values[index]), style: boldTextStyle(color: currentIndex == index ? Colors.white : textPrimaryColorGlobal)).expand(),
                    getIcons(context, ThemeModes.values[index], index),
                  ],
                ),
              ).onTap(() async {
                currentIndex = index;
                if (currentIndex == appThemeMode.themeModeSystem) {
                  appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
                } else if (currentIndex == appThemeMode.themeModeLight) {
                  appStore.setDarkMode(false);
                } else if (currentIndex == appThemeMode.themeModeDark) {
                  appStore.setDarkMode(true);
                }
                setValue(THEME_MODE_INDEX, index);
                setState(() {});
                finish(context, true);
              }, borderRadius: radius(defaultRadius));
            },
          ),
        ).paddingSymmetric(horizontal: 16, vertical: 16));
  }
}

enum ThemeModes { SystemDefault, Light, Dark }
