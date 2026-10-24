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
              Icon(Icons.monetization_on_rounded, size: 16, color: Color(0xFFFFD54F)),
              4.width,
              Text(
                '${authStore.coins}',
                style: boldTextStyle(color: Colors.white, size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
