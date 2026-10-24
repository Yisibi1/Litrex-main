import 'package:flutter/material.dart';
import 'package:mighty_ebook/utils/Extensions/string_extensions.dart';
import '../model/DashboardResponse.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/appWidget.dart';

class HomeSliderComponent extends StatefulWidget {
  static String tag = '/HomeSliderComponent';

  final AppSlider mSliderList;

  const HomeSliderComponent(this.mSliderList, {super.key});

  @override
  HomeSliderComponentState createState() => HomeSliderComponentState();
}

class HomeSliderComponentState extends State<HomeSliderComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.mSliderList.url != null && widget.mSliderList.url!.isNotEmpty) {
          final uri = Uri.parse(widget.mSliderList.url!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedImage(widget.mSliderList.imageUrl.toString(), height: double.infinity, fit: BoxFit.fill, width: context.width()).cornerRadiusWithClipRRect(defaultRadius),
          Container(
            decoration: boxDecorationWithRoundedCornersWidget(borderRadius: radius(defaultRadius), gradient: LinearGradient(colors: [Colors.transparent, Colors.black87], begin: Alignment.center, end: Alignment.bottomCenter)),
            width: context.width(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Text(widget.mSliderList.title!, style: primaryTextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 2).paddingAll(16),
          )
        ],
      ),
    ).paddingAll(16);
  }
}
