import 'dart:ui';
import '../../screen/ChooseTopicScreen.dart';
import '../utils/Extensions/context_extensions.dart';
import '../main.dart';
import '../screen/GetStaredScreen.dart';
import '../screen/auth/LoginScreen.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import 'package:flutter/material.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/OfflineReadingService.dart';
import '../network/AuthApis.dart';
import 'DashboardScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 2.seconds.delay;
    
    // AdMob initialize (Tətbiq tam açıldıqdan sonra arxaplanda işə düşür)
    MobileAds.instance.initialize();
    
    // Auth durumunu yükle
    await authStore.loadUserFromPrefs();
    
    bool seen = (getBoolAsync('isFirstTime'));
    
    if (seen) {
      if (authStore.isLoggedIn) {
        // Yerel ban kontrolü (Hızlı kontrol)
        if (authStore.currentUser?.status == 'banned') {
          await authStore.logout();
          toast(language.lblAccountSuspended);
          LoginScreen().launch(context, isNewTask: true);
          return;
        }

        // Cihaz ve Sunucu bazlı kontrol
        try {
          String? deviceId = await getDeviceId();
          if (deviceId != null) {
            final resetResponse = await checkDeviceReset(deviceId: deviceId).timeout(
              Duration(seconds: 5),
              onTimeout: () => <String, dynamic>{'status': 'ok'},
            );
            log("API Response (checkDeviceReset): $resetResponse");
            
            // Ban kontrolü (Sunucudan gelen güncel durum)
            if (resetResponse['user_status'] == 'banned' || resetResponse['status'] == 'banned' || (resetResponse['user'] != null && resetResponse['user']['status'] == 'banned')) {
              log("User is banned based on API response.");
              await authStore.logout();
              toast(language.lblAccountSuspended);
              LoginScreen().launch(context, isNewTask: true);
              return;
            }

            // Sıfırlama kontrolü
            if (resetResponse['status'] == 'reset') {
              // Uygulamayı sıfırla
              await OfflineReadingService().clearAllBooks();
              await authStore.logout();
              
              toast(language.lblDeviceResetByAdmin ?? "Cihazınız yönetici tarafından sıfırlandı.");
              
              LoginScreen().launch(context, isNewTask: true);
              return;
            }
          }
        } catch (e) {
          log("Reset check error: $e");
        }

        // Kontrol sonrası oturum kapanmış olabilir (409 Conflict vb.)
        if (!authStore.isLoggedIn) {
          LoginScreen().launch(context, isNewTask: true);
          return;
        }

        // Giriş yapılmış, Dashboard'a git
        if (getStringListAsync(chooseTopicList) != null) {
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          ChooseTopicScreen(isVisibleBack: false).launch(context, isNewTask: true);
        }
      } else {
        // Giriş yapılmamış, Login'e git
        LoginScreen().launch(context, isNewTask: true);
      }
    } else {
      // İlk kez açılıyor, onboarding göster
      await setValue('isFirstTime', true);
      GetStaredScreen().launch(context, isNewTask: true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (getIntAsync(THEME_MODE_INDEX) == appThemeMode.themeModeSystem) {
      log(getIntAsync(THEME_MODE_INDEX));
      appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
    }
    window.onPlatformBrightnessChanged = () async {
      log(getIntAsync(THEME_MODE_INDEX));
      if (getIntAsync(THEME_MODE_INDEX) == appThemeMode.themeModeSystem) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.light);
      }
    };
    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(child: Image.asset(ic_logo, fit: BoxFit.fill, color: Colors.white, width: 100, height: 100)),
          16.height,
          Text(AppName, style: boldTextStyle(size: 26, color: Colors.white)),
        ],
      ).center(),
    );
  }
}
