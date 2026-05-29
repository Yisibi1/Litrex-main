import 'package:flutter/material.dart';
import '../screen/CoinPurchaseScreen.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/colors.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/Commons.dart';

ValueNotifier<int>? _currentStreakNotifier;

ValueNotifier<int> get currentStreakNotifier {
  _currentStreakNotifier ??= ValueNotifier(getIntAsync('CURRENT_STREAK', defaultValue: 0));
  return _currentStreakNotifier!;
}

class StreakBalanceComponent extends StatelessWidget {
  const StreakBalanceComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentStreakNotifier,
      builder: (context, streak, child) {
        return InkWell(
          onTap: () {
            if (streak <= 0) {
              toast("Kitap okuyarak serinizi başlatın!");
            } else {
              toast("🔥 Harika! $streak gündür arka arkaya okuyorsunuz.");
            }
          },
          borderRadius: radius(20),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: radius(20),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 0),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("🔥", style: TextStyle(fontSize: 16, color: streak > 0 ? null : Colors.grey)),
                6.width,
                Text(
                  '$streak',
                  style: boldTextStyle(color: streak > 0 ? Colors.deepOrange : Colors.grey, size: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
