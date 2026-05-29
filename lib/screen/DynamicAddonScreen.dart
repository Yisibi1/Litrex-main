import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/DashboardResponse.dart';
import '../network/NetworkUtils.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/text_styles.dart';
import '../component/ItemWidget.dart';
import 'BookDetailScreen.dart';
import '../utils/appWidget.dart';

import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/decorations.dart';

class DynamicAddonScreen extends StatefulWidget {
  @override
  _DynamicAddonScreenState createState() => _DynamicAddonScreenState();
}

class _DynamicAddonScreenState extends State<DynamicAddonScreen> {
  bool isLoading = true;
  String addonName = "Dinamik Baza";
  String errorMessage = "";
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    loadAddon();
  }

  Future<void> loadAddon() async {
    String addonUrl = getStringAsync('addon_url');
    if (addonUrl.isEmpty) {
      setState(() {
        errorMessage = "Addon URL tapılmadı.";
        isLoading = false;
      });
      return;
    }

    try {
      var manifestRes = await httpGetWithAddonHeaders(addonUrl);
      if (manifestRes.statusCode == 200) {
        var manifestData = jsonDecode(manifestRes.body);
        setState(() {
          addonName = manifestData['name'] ?? "Dinamik Baza";
        });
        
        String dashboardUrl = manifestData['endpoints']['dashboard'];
        
        var dashRes = await httpGetWithAddonHeaders(dashboardUrl);
        if (dashRes.statusCode == 200) {
          var dashData = jsonDecode(dashRes.body);
          if (dashData['latest_book'] != null) {
            var list = dashData['latest_book'] as List;
            setState(() {
              books = list.map((e) => Book.fromJson(e)).toList();
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              errorMessage = "Kitab tapılmadı.";
            });
          }
        } else {
           setState(() {
            isLoading = false;
            errorMessage = "API xətası: ${dashRes.statusCode}";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Manifest xətası: ${manifestRes.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Bağlantı xətası: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        addonName,
        color: primaryColor,
        textColor: Colors.white,
        showBack: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: primaryTextStyle()))
              : GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    Book book = books[index];
                    return ItemWidget(
                      book,
                      isGrid: true,
                      onTap: () {
                        BookDetailScreen(data: book).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                      },
                    );
                  },
                ),
    );
  }
}
