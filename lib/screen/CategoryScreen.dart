import '../component/CategoryItemWidget.dart';
import '../network/RestApis.dart';
import '../screen/ViewAllScreen.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/appWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../main.dart';
import '../model/DashboardResponse.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/colors.dart';

class CategoryScreen extends StatefulWidget {
  static String tag = '/CategoryScreen';
  final bool isCategory;

  const CategoryScreen({super.key, this.isCategory = false});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {
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
    return Scaffold(
      appBar: appBarWidget(language.lblCategory, color: primaryColor, textColor: Colors.white, showBack: widget.isCategory ? true : false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<Category>>(
            future: getCategories(),
            builder: (_, snap) {
              if (snap.hasData) {
                return snap.data!.isNotEmpty
                    ? SingleChildScrollView(
                        padding: EdgeInsets.all(12),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runSpacing: 12,
                          spacing: 16,
                          children: List.generate(
                            snap.data!.length,
                            (index) {
                              Category data = snap.data![index];
                              return AnimationConfiguration.staggeredGrid(
                                duration: Duration(milliseconds: 750),
                                columnCount: 2,
                                position: index,
                                child: CategoryItemWidget(data, onTap: () {
                                  ViewAllScreen(title: data.name, categoryId: data.id.toInt(), isCategory: true).launch(context);
                                }),
                              );
                            },
                          ),
                        ),
                      )
                    : noDataWidget(context);
              }
              return snapWidgetHelper(snap, loadingWidget: mProgress());
            },
          ).expand()
        ],
      ),
    );
  }
}
