import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/appWidget.dart';
import 'package:flutter/material.dart';
import '../model/DashboardResponse.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/images.dart';

class CategoryItemWidget extends StatefulWidget {
  static String tag = '/CategoryItemWidget';
  final Category data;
  final Function? onTap;

  const CategoryItemWidget(this.data, {super.key, this.onTap});

  @override
  CategoryItemWidgetState createState() => CategoryItemWidgetState();
}

class CategoryItemWidgetState extends State<CategoryItemWidget> {
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
        onTap: () {
          widget.onTap!.call();
          setState(() {});
        },
        child: Container(
          decoration: boxDecorationDefaultWidget(
            borderRadius: radius(defaultRadius),
            color: context.scaffoldBackgroundColor,
          ),
          width: (context.width() - 56) / 3,
          child: Column(
            children: [
              widget.data.logo != null && widget.data.logo!.isNotEmpty
                  ? cachedImage(widget.data.logo!.validate(), height: 120, width: (context.width() - 56) / 3, fit: BoxFit.fill)
                      .cornerRadiusWithClipRRectOnly(topLeft: defaultRadius.toInt(), topRight: defaultRadius.toInt())
                  : Image.asset(ic_placeholder, height: 85, width: (context.width() - 56) / 3, fit: BoxFit.fill).paddingOnly(top: 25),
              8.height,
              Text(widget.data.name.validate().capitalizeFirstLetter(), style: boldTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)
                  .paddingOnly(left: 2, right: 2)
                  .center(),
              8.height,
            ],
          ),
        ));
  }
}
