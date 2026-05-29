import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../language/AppLocalizations.dart';
import '../language/BaseLanguage.dart';
import '../main.dart';
import '../model/LanguageDataModel.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/device_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/constant.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isDarkModeOn = false;

  @observable
  bool isNotificationOn = false;

  @observable
  bool isLoading = false;

  @observable
  String selectedLanguage = "";

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkModeOn = aIsDarkMode;

    if (isDarkModeOn) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = Colors.white70;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;
    }
    await setValue(isDarkModeOnPref, isDarkModeOn);
  }

  // ⭐ NEW UPDATED CODE (Kevin-in göndərdiyi)
  @action
  void setNotification(bool val) {
    isNotificationOn = val;
    setValue(IS_NOTIFICATION_ON, val);

    if (isMobile) {
      if (val) {
        OneSignal.User.pushSubscription.optIn();
      } else {
        OneSignal.User.pushSubscription.optOut();
      }
    }
  }

  @action
  void setLoading(bool val) => isLoading = val;

  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    selectedLanguageDataModel = getSelectedLanguageModel(defaultLanguage: aCode);
    selectedLanguage = getSelectedLanguageModel(defaultLanguage: defaultValues.defaultLanguage)!.languageCode!;

    if (context != null) language = BaseLanguage.of(context)!;
    language = await AppLocalizations().load(Locale(selectedLanguage));
  }
}
