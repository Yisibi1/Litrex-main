import 'package:flutter/material.dart';
import '../model/LanguageDataModel.dart';
import 'BaseLanguage.dart';
import 'LanguageAr.dart';
import 'LanguageEn.dart';
import 'LanguageHi.dart';
import 'LauguageTr.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'tr':
        return LanguageTr();
      case 'hi':
        return LanguageHi();
      case 'ar':
        return LanguageAr();
      case 'en':
        return LanguageEn();
      default:
        return LanguageEn();
    }
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
