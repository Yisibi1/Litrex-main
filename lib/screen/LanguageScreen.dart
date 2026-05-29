import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../model/LanguageDataModel.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import '../main.dart';
import '../utils/colors.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
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
      appBar: appBarWidget(language.lblLanguage, showBack: true,color: primaryColor,textColor: Colors.white),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Wrap(
          runSpacing: 16,
          children: List.generate(localeLanguageList.length, (index) {
            LanguageDataModel data = localeLanguageList[index];
            return Container(
              width: context.width(),
              decoration: boxDecorationDefaultWidget(
                  color: getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE) == data.languageCode.validate() ? primaryColor : context.scaffoldBackgroundColor,
                  border: Border.all(color: context.dividerColor)),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Image.asset(data.flag.validate(), width: 34),
                  16.width,
                  Text(data.name.validate(),
                          style: boldTextStyle(color: getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE) == data.languageCode.validate() ? Colors.white : textPrimaryColorGlobal))
                      .expand(),
                  getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE) == data.languageCode.validate()
                      ? Icon(
                          Ionicons.checkbox_outline,
                          color: getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE) == data.languageCode.validate() ? Colors.white : textPrimaryColorGlobal,
                        )
                      : SizedBox(),
                ],
              ),
            ).onTap(
              () async {
                setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
                selectedLanguageDataModel = data;
                appStore.setLanguage(data.languageCode!, context: context);
                finish(context, true);
                setState(() {});
              },
              borderRadius: radius(defaultRadius),
            );
          }),
        ),
      ),
    );
  }
}
