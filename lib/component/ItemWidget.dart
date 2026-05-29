import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/appWidget.dart';
import 'package:flutter/material.dart';
import '../utils/images.dart';
import '../main.dart';
import '../model/DashboardResponse.dart';
import '../utils/colors.dart';
import '../utils/Extensions/text_styles.dart';

class ItemWidget extends StatefulWidget {
  static String tag = '/ItemWidget';
  final Function? onTap;
  final bool? isFavourite;
  final bool? isGrid;
  final bool? isFeatured;
  final Book data;

  const ItemWidget(this.data, {super.key, this.onTap, this.isFavourite = false, this.isGrid = false, this.isFeatured = false});

  @override
  ItemWidgetState createState() => ItemWidgetState();
}

class ItemWidgetState extends State<ItemWidget> {
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

  Widget mData() {
    if (widget.isGrid == true) {
      var width = context.width() * 0.39;
      return SizedBox(
        width: width,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            widget.onTap!.call();
            setState(() {});
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  widget.data.logo != null && widget.data.logo!.isNotEmpty
                      ? cachedImage(widget.data.logo, fit: BoxFit.fill, width: width, height: 220).cornerRadiusWithClipRRect(defaultRadius).paddingOnly(left: 4)
                      : Image.asset(ic_placeholder, fit: BoxFit.fill, width: width, height: 220).cornerRadiusWithClipRRect(defaultRadius),
                  if (widget.data.isPremium == '1')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.diamond, color: Colors.white, size: 12),
                            4.width,
                            Text("Premium", style: boldTextStyle(color: Colors.white, size: 10)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              6.height,
              Text(parseHtmlStringWidget(widget.data.name!.trim()), textAlign: TextAlign.start, maxLines: 2, overflow: TextOverflow.ellipsis, style: primaryTextStyle()).paddingSymmetric(horizontal: 4),
              if (widget.data.addonSource != null && widget.data.addonSource!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, left: 4.0),
                  child: Text(
                    'Eklenti: ${widget.data.addonSource}',
                    style: boldTextStyle(color: primaryColor, size: 10),
                  ),
                ),
            ],
          ),
        ),
      );
    } else if (widget.isFeatured == true) {
      return SizedBox(
        width: 150,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            widget.onTap!.call();
            setState(() {});
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                   if (widget.data.logo != null && widget.data.logo!.isNotEmpty)
                    cachedImage(widget.data.logo, fit: BoxFit.fill, width: 150, height: 200).cornerRadiusWithClipRRect(defaultRadius).paddingOnly(left: 4, right: 4),
                   if (widget.data.isPremium == '1')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                         child: Icon(Icons.diamond, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
              6.height,
              Text(parseHtmlStringWidget(widget.data.name!.trim()), textAlign: TextAlign.start, maxLines: 2, overflow: TextOverflow.ellipsis, style: primaryTextStyle()).paddingSymmetric(horizontal: 4),
              if (widget.data.addonSource != null && widget.data.addonSource!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, left: 4.0),
                  child: Text(
                    'Eklenti: ${widget.data.addonSource}',
                    style: boldTextStyle(color: primaryColor, size: 10),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          widget.onTap!.call();
          setState(() {});
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                cachedImage(widget.data.logo, fit: BoxFit.fill, width: 105, height: 140).cornerRadiusWithClipRRect(defaultRadius).paddingOnly(left: 4, right: 4),
                 if (widget.data.isPremium == '1')
                    Positioned(
                      top: 0,
                      right: 4,
                      child: Container(
                         padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                         child: Icon(Icons.diamond, color: Colors.white, size: 12),
                      ),
                    ),
              ],
            ),
            6.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(parseHtmlStringWidget(widget.data.name!.toString().trim()), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.justify, style: boldTextStyle()).expand(),
                    8.width,
                    Observer(
                      builder: (context) {
                        return Icon(wishListStore.isItemInWishlist(widget.data.id!.toInt()) == false ? MaterialIcons.bookmark_outline : MaterialIcons.bookmark, size: 24).onTap(() {
                          Book mWishListModel = Book();
                          mWishListModel = widget.data;
                          wishListStore.addToWishList(mWishListModel);
                          setState(() {});
                        });
                      }
                    ),
                  ],
                ),
                Text(parseHtmlStringWidget(widget.data.description!.trim()), overflow: TextOverflow.ellipsis, textAlign: TextAlign.start, maxLines: 2, style: secondaryTextStyle()).paddingRight(16),
                if (widget.data.addonSource != null && widget.data.addonSource!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Eklenti: ${widget.data.addonSource}',
                      style: boldTextStyle(color: primaryColor, size: 12),
                    ),
                  ),
              ],
            ).expand()
          ],
        ).paddingOnly(top: 12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return mData();
  }
}
