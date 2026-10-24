import 'package:flutter/material.dart';
import '../screen/CoinPurchaseScreen.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/colors.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/Commons.dart';
import '../screen/StreakDetailScreen.dart';

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
            StreakDetailScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
          },
          borderRadius: radius(20),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: radius(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded, size: 16, color: streak > 0 ? Color(0xFFFFB74D) : Colors.white70),
                4.width,
                Text(
                  '$streak',
                  style: boldTextStyle(color: Colors.white, size: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
