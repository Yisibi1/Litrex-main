import 'package:flutter/material.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../main.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';

class ThemeSelectionDialog extends StatefulWidget {
  static String tag = '/ThemeSelectionDialog';

  const ThemeSelectionDialog({super.key});

  @override
  ThemeSelectionDialogState createState() => ThemeSelectionDialogState();
}

class ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    List<String?> themeModeList = ["Light", "Dark", "System Default"];
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(language.lblSelectTheme, style: boldTextStyle(size: 20)).paddingLeft(16),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 16, top: 24),
              itemCount: themeModeList.length,
              itemBuilder: (BuildContext context, int index) {
                return RadioListTile(
                  dense: true,
                  value: index,
                  activeColor:
                      currentIndex == index ? Colors.white : primaryColor,
                  groupValue: currentIndex,
                  title: Text(themeModeList[index]!, style: primaryTextStyle()),
                  onChanged: (dynamic val) {
                    currentIndex = val;
                    if (val == ThemeModeSystem) {
                      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
                    } else if (val == ThemeModeLight) {
                      appStore.setDarkMode(false);
                    } else if (val == ThemeModeDark) {
                      appStore.setDarkMode(true);
                    }
                    setValue(THEME_MODE_INDEX, val);
                    Navigator.pop(context, true);
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
