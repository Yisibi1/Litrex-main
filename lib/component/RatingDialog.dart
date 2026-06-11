import 'package:flutter/material.dart';
import 'package:store_redirect/store_redirect.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/Commons.dart';

class RatingDialog extends StatefulWidget {
  final String playStoreUrl;

  const RatingDialog({super.key, required this.playStoreUrl});

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 5.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.cardColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 80, color: Colors.amber),
          16.height,
          Text(language.lblRateUsTitle, style: boldTextStyle(size: 22), textAlign: TextAlign.center),
          12.height,
          Text(language.lblRateUsMsg, style: secondaryTextStyle(size: 16), textAlign: TextAlign.center),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    rating = index + 1.0;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              );
            }),
          ),
          24.height,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(language.lblMaybeLater, style: boldTextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              16.width,
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await setValue('IS_APP_RATED', true);
                    if (rating >= 4.0) {
                      StoreRedirect.redirect(androidAppId: "com.litrex.ebook", iOSAppId: "6774904816");
                    } else {
                      toast("Teşekkürler!");
                    }
                  },
                  child: Text(language.lblRateNow, style: boldTextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
