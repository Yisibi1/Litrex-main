import 'package:flutter/material.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/images.dart';
import '../model/DashboardResponse.dart';

class AuthorComponent extends StatefulWidget {
  static String tag = '/AuthorComponent';
  final Function? onTap;
  final bool? isSlider;
  final Author data;

  const AuthorComponent(this.data, {super.key, this.onTap, this.isSlider = false});

  @override
  AuthorComponentState createState() => AuthorComponentState();
}

class AuthorComponentState extends State<AuthorComponent> {
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
      },
      child: Container(
        width: widget.isSlider == true ? context.width() * 0.24 : (context.width() - 50) / 3,
        margin: EdgeInsets.only(right: widget.isSlider == true ? 8 : 0),
        child: Column(
          children: [
            widget.data.imageUrl != null && widget.data.imageUrl!.isNotEmpty
                ? CircleAvatar(backgroundImage: NetworkImage(widget.data.imageUrl!), radius: 55, backgroundColor: context.cardColor)
                : CircleAvatar(backgroundImage: AssetImage(ic_placeholder), radius: 55, backgroundColor: context.cardColor),
            4.height,
            Text(widget.data.name!, style: primaryTextStyle()),
          ],
        ),
      ),
    );
  }
}
