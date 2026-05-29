import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../utils/Extensions/Constants.dart';
import '../../utils/Extensions/Widget_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../main.dart';
import '../utils/Extensions/text_styles.dart';

class NoInternetComponent extends StatelessWidget {
  const NoInternetComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Feather.wifi_off, size: 100,color: textSecondaryColorGlobal),
        24.height,
        Text(language.lblNoInternet, style: primaryTextStyle(color: textSecondaryColorGlobal)),
      ],
    ).center();
  }
}
