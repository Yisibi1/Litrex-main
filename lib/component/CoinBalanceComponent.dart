import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import '../screen/CoinPurchaseScreen.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/colors.dart';
import '../utils/Extensions/int_extensions.dart';

/// Header'daki jeton bakiyesi. Tıklanınca jeton satın alma / yönetim ekranına gider.
class CoinBalanceComponent extends StatelessWidget {
  const CoinBalanceComponent({super.key, this.onTapForTesting});

  /// Sadece testlerde kullanılır; verilirse tıklanınca bu çağrılır, CoinPurchaseScreen açılmaz.
  final VoidCallback? onTapForTesting;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => InkWell(
        onTap: onTapForTesting ?? () => CoinPurchaseScreen().launch(context),
        borderRadius: radius(20),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              Icon(Icons.monetization_on_rounded, size: 18, color: Color(0xFFF5A623)),
              6.width,
              Text(
                '${authStore.coins}',
                style: boldTextStyle(color: primaryColor, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
