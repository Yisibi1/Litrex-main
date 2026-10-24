import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/colors.dart';
import '../main.dart'; // language dəyişənləri və appTheme üçün lazım ola bilər

import '../utils/constant.dart';
import '../utils/Extensions/shared_pref.dart';

class AddonBannerWidget extends StatelessWidget {
  const AddonBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String bannerImage = getStringAsync(ADDON_BANNER_IMAGE);
    String bannerUrl = getStringAsync(ADDON_BANNER_URL);

    // Əgər admin paneldən daxil edilməyibsə default dəyərlər:
    if (bannerImage.isEmpty) {
      bannerImage = 'https://i.ibb.co/3s7s6sK/litrex-addon-banner.png';
    }
    if (bannerUrl.isEmpty) {
      bannerUrl = 'https://olibrary.space/';
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: boxDecorationWithRoundedCornersWidget(
        borderRadius: radius(12),
        backgroundColor: Colors.transparent,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(bannerUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Image.network(
          bannerImage,
          width: double.infinity,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Şəkil yüklənməsə belə möhtəşəm görünüş
            return Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade600, Colors.deepOrange.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(Icons.menu_book, size: 100, color: Colors.white.withOpacity(0.15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.stars_rounded, color: Colors.white, size: 48),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Yeni Addon Sistemini Kəşf Et!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              SizedBox(height: 4),
                              Text("10,000+ pulsuz kitab üçün dərhal quraşdırın.", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text("Keçid Et", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 11)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
