import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/appWidget.dart';
import '../component/PDFViewerComponent.dart';
import '../main.dart';
import '../model/DashboardResponse.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import '../utils/OfflineReadingService.dart';
import 'WebViewScreen.dart';
import '../component/NativeAdWidget.dart';
import '../network/RestApis.dart';
import 'CoinPurchaseScreen.dart';
import 'PremiumScreen.dart';
import '../network/AuthApis.dart';
import '../utils/Extensions/shared_pref.dart';
class BookDetailScreen extends StatefulWidget {
  static String tag = '/BookDetailScreen';
  final Book data;

  const BookDetailScreen({super.key, required this.data});

  @override
  BookDetailScreenState createState() => BookDetailScreenState();
}

class BookDetailScreenState extends State<BookDetailScreen> {
  String? formatted;
  bool isDownloaded = false;
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    FacebookAudienceNetwork.init(
      testingId: FACEBOOK_KEY,
      iOSAdvertiserTrackingEnabled: true,
    );
    if (mWebInterstitialAds == '1') loadInterstitialAds();

    if (widget.data.id != null) {
      isDownloaded = await OfflineReadingService().isBookDownloaded(widget.data.id!);
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (mWebInterstitialAds == '1') {
      if (mAdShowBookDetailCount < int.parse(adsInterval)) {
        mAdShowBookDetailCount++;
      } else {
        mAdShowBookDetailCount = 0;
        showInterstitialAds();
      }
    }
    super.dispose();
  }

  /// Kitaba gerçekten erişim hakkı var mı kontrol et
  bool get _hasAccess {
    if (widget.data.isPremium != '1') return true;
    if (authStore.isPremiumUser) return true;
    if (widget.data.isUnlocked == true) {
      // Süre kontrolü
      final expiresAt = widget.data.unlockExpiresAt;
      if (expiresAt != null) {
        try {
          final expiry = DateTime.parse(expiresAt);
          if (DateTime.now().isBefore(expiry)) return true;
        } catch (_) {}
      }
    }
    return false;
  }

  /// Premium erişim modalını göster
  void _showPremiumAccessModal() {
    final coinPrice = widget.data.coinPrice ?? 20;
    final bookName = widget.data.name.validate();
    final bool hasEnoughCoins = authStore.coins >= coinPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            bool isUnlocking = false;

            return Container(
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn ? Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Lock icon + title
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF9155FD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF9155FD).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(Icons.lock_rounded, color: Colors.white, size: 34),
                        ),
                        16.height,
                        Text(
                          "Premium İçerik",
                          style: boldTextStyle(size: 22, color: appStore.isDarkModeOn ? Colors.white : Color(0xFF1A1A2E)),
                        ),
                        8.height,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            "\"$bookName\" kitabına erişmek için aşağıdaki seçeneklerden birini tercih edin.",
                            style: secondaryTextStyle(size: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Divider(height: 1, color: Colors.grey.withOpacity(0.15)),

                  // === OPTION 1: Coin Unlock ===
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasEnoughCoins
                          ? Color(0xFFF5A623).withOpacity(0.08)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasEnoughCoins
                            ? Color(0xFFF5A623).withOpacity(0.5)
                            : Colors.grey.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Coin icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFFF5A623).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(Icons.monetization_on_rounded, size: 26, color: Color(0xFFF5A623)),
                          ),
                        ),
                        12.width,
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Jeton ile Aç",
                                style: boldTextStyle(size: 15, color: appStore.isDarkModeOn ? Colors.white : Color(0xFF1A1A2E)),
                              ),
                              4.height,
                              Row(
                                children: [
                                  Text(
                                    "$coinPrice Jeton",
                                    style: boldTextStyle(size: 13, color: Color(0xFFF5A623)),
                                  ),
                                  Text(
                                    "  •  24 Saat Erişim",
                                    style: secondaryTextStyle(size: 12),
                                  ),
                                ],
                              ),
                              4.height,
                              Observer(builder: (_) {
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Bakiye: ",
                                        style: secondaryTextStyle(size: 11),
                                      ),
                                      TextSpan(
                                        text: "${authStore.coins} Jeton",
                                        style: boldTextStyle(
                                          size: 11,
                                          color: authStore.coins >= coinPrice
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        12.width,
                        // Button (jeton harcandığında iade edilmez — onay iste)
                        StatefulBuilder(builder: (_, setState2) {
                          return GestureDetector(
                            onTap: hasEnoughCoins && !isUnlocking
                                ? () async {
                                    final confirmed = await showDialog<bool>(
                                      context: ctx,
                                      builder: (c) => AlertDialog(
                                        title: Text("Jeton harcama"),
                                        content: Text(
                                          "Bu kitap için $coinPrice jeton harcanacak. Harcanan jetonlar iade edilmez. Devam etmek istiyor musunuz?",
                                          style: secondaryTextStyle(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(c, false),
                                            child: Text("İptal"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(c, true),
                                            child: Text("Evet, harca"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed != true || !mounted) return;
                                    setModalState(() => isUnlocking = true);
                                    try {
                                      final res = await unlockBookWithCoins(widget.data.id!);
                                      if (res['success'] == true) {
                                        setState(() {
                                          widget.data.isUnlocked = true;
                                          widget.data.unlockExpiresAt = res['expires_at'];
                                          
                                          int newCoins = res['new_balance'] is int
                                              ? res['new_balance'] as int
                                              : int.tryParse(res['new_balance'].toString()) ?? authStore.coins;
                                              
                                          authStore.coins = newCoins;
                                          setValue('COINS', newCoins);
                                          if (authStore.currentUser != null) {
                                            authStore.currentUser!.coins = newCoins;
                                          }
                                        });
                                        Navigator.pop(ctx);
                                        toast(res['message'] ?? "Kitap başarıyla açıldı!");
                                        _openBook();
                                      } else {
                                        toast(res['message'] ?? "Bir hata oluştu.");
                                      }
                                    } catch (e) {
                                      toast(e.toString());
                                    } finally {
                                      setModalState(() => isUnlocking = false);
                                    }
                                  }
                                : null,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: hasEnoughCoins
                                    ? LinearGradient(colors: [Color(0xFFF5A623), Color(0xFFFF8C00)])
                                    : null,
                                color: hasEnoughCoins ? null : Colors.grey.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: isUnlocking
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      hasEnoughCoins ? "Aç" : "Yetersiz",
                                      style: boldTextStyle(
                                        size: 13,
                                        color: hasEnoughCoins ? Colors.white : Colors.grey,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Yetersiz jeton: reklam veya jeton satın al
                  if (!hasEnoughCoins)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: Colors.orange),
                              6.width,
                              Expanded(
                                child: Text(
                                  "Yetersiz jeton. Reklam izleyerek kazanabilir veya jeton satın alabilirsiniz.",
                                  style: secondaryTextStyle(size: 11, color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                          10.height,
                          InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              CoinPurchaseScreen().launch(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFFF5A623).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFF5A623).withOpacity(0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_circle_outline, size: 18, color: Color(0xFFF5A623)),
                                  8.width,
                                  Text(
                                    "Jeton satın al",
                                    style: boldTextStyle(size: 13, color: Color(0xFFF5A623)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // === OR divider ===
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.withOpacity(0.25))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("veya", style: secondaryTextStyle(size: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.withOpacity(0.25))),
                      ],
                    ),
                  ),

                  // === OPTION 2: Premium ===
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      PremiumScreen().launch(context);
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6C63FF).withOpacity(0.08), Color(0xFF9155FD).withOpacity(0.08)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF9155FD).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF9155FD)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.diamond_rounded, color: Colors.white, size: 24),
                          ),
                          12.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Premium'a Geç",
                                  style: boldTextStyle(size: 15, color: appStore.isDarkModeOn ? Colors.white : Color(0xFF1A1A2E)),
                                ),
                                4.height,
                                Text(
                                  "Tüm kitaplara sınırsız erişim",
                                  style: secondaryTextStyle(size: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF9155FD)),
                        ],
                      ),
                    ),
                  ),

                  // Safe area bottom padding
                  SizedBox(height: MediaQuery.of(ctx).padding.bottom + 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Kitabı aç (modal olmadan direkt okuma)
  Future<void> _openBook() async {
    // Jetonla açılmış mı? (Premium değil ve isUnlocked ile açılmışsa)
    final bool _coinUnlocked = widget.data.isPremium == '1' && !authStore.isPremiumUser && widget.data.isUnlocked == true;

    if (widget.data.type == "file" || widget.data.type == "pdf") {
      final file = widget.data.file ?? "";
      if (file.isEmpty) {
        toast(language.lblTryAgain);
        return;
      }
      if (!file.contains(".pdf")) {
        WebViewScreen(title: widget.data.name.validate(), mInitialUrl: file).launch(context);
      } else {
        if (isDownloaded) {
          final bytes = await OfflineReadingService().getDecryptedBook(widget.data.id!, isPremiumUser: authStore.isPremiumUser);
          if (bytes != null) {
            PDFViewerComponent(title: widget.data.name.validate(), url: "", fileBytes: bytes, isUnlockedWithCoins: _coinUnlocked, book: widget.data).launch(context);
            return;
          }
        }
        PDFViewerComponent(title: widget.data.name.validate(), url: file, isUnlockedWithCoins: _coinUnlocked, book: widget.data).launch(context);
      }
    } else {
      final url = widget.data.url ?? "";
      if (url.isEmpty) {
        toast(language.lblTryAgain);
        return;
      }
      if (!url.contains(".pdf")) {
        WebViewScreen(title: widget.data.name.validate(), mInitialUrl: url).launch(context);
      } else {
        if (isDownloaded) {
          final bytes = await OfflineReadingService().getDecryptedBook(widget.data.id!, isPremiumUser: authStore.isPremiumUser);
          if (bytes != null) {
            PDFViewerComponent(title: widget.data.name.validate(), url: "", fileBytes: bytes, isUnlockedWithCoins: _coinUnlocked, book: widget.data).launch(context);
            return;
          }
        }
        PDFViewerComponent(title: widget.data.name.validate(), url: url, isUnlockedWithCoins: _coinUnlocked, book: widget.data).launch(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: context.statusBarHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: context.width(),
                  color: primaryColor.withOpacity(0.2),
                ),
                Positioned(
                  top: 2,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: textPrimaryColorGlobal),
                    onPressed: () => finish(context),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  right: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(parseHtmlString(widget.data.name.validate()), style: boldTextStyle(size: 18), maxLines: 4, overflow: TextOverflow.ellipsis),
                          8.height,
                          Text("${language.lblBy} ${widget.data.authorName.validate()}", style: secondaryTextStyle()),
                          if (widget.data.addonSource != null && widget.data.addonSource!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                6.height,
                                Text("Eklenti: ${widget.data.addonSource}", style: boldTextStyle(size: 12, color: primaryColor)),
                              ],
                            ),
                        ],
                      ).paddingOnly(bottom: 16, right: 16).expand(),
                      widget.data.logo != null
                          ? cachedImage(widget.data.logo.validate(), height: 210, width: 150, fit: BoxFit.fill).cornerRadiusWithClipRRect(defaultRadius)
                          : Image.asset(ic_placeholder, height: 150, width: 120, fit: BoxFit.fill).cornerRadiusWithClipRRect(defaultRadius),
                    ],
                  ),
                ),
              ],
            ),
            35.height,
            // Premium badge
            if (widget.data.isPremium == '1')
              Container(
                margin: EdgeInsets.only(left: 16, bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF9155FD)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond_rounded, size: 14, color: Colors.white),
                    4.width,
                    Text("Premium", style: boldTextStyle(size: 11, color: Colors.white)),
                  ],
                ),
              ),
            Text(language.lblDescription, style: boldTextStyle()).paddingOnly(left: 16, bottom: 8),
            Text(parseHtmlString(widget.data.description.validate()), style: secondaryTextStyle(size: 16)).paddingOnly(left: 16, right: 16, bottom: 16),
            NativeAdWidget(),
            24.height,
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: context.width(),
        decoration: boxDecorationWithRoundedCornersWidget(
          backgroundColor: primaryColor,
          borderRadius: radius(defaultRadius),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Book mWishListModel = Book();
                mWishListModel = widget.data;
                wishListStore.addToWishList(mWishListModel);
                setState(() {});
              },
              icon: Icon(
                wishListStore.isItemInWishlist(widget.data.id!.toInt()) == false
                    ? MaterialIcons.bookmark_outline
                    : MaterialIcons.bookmark,
                size: 24,
                color: Colors.white,
              ),
            ),
            Container(width: 2, height: 50, color: Colors.white),
            // Download Button — yalnız Premium istifadəçilərə açıq (jetonla açılan kitablar endirilə bilməz)
            if (widget.data.type == "file" || widget.data.type == "pdf")
              IconButton(
                onPressed: () async {
                  // Premium kitab + Premium olmayan istifadəçi = download bloku
                  if (!authStore.isPremiumUser && widget.data.isPremium == '1') {
                    toast(language.lblDownloadPremiumOnly);
                    return;
                  }

                  if (isDownloaded) {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(language.lblRemoveDownloadTitle, style: boldTextStyle()),
                        content: Text(language.lblRemoveDownloadMsg, style: secondaryTextStyle()),
                        actions: [
                          TextButton(
                            child: Text(language.lblCancel, style: primaryTextStyle()),
                            onPressed: () => Navigator.pop(c),
                          ),
                          TextButton(
                            child: Text(language.lblYes, style: primaryTextStyle(color: primaryColor)),
                            onPressed: () async {
                              Navigator.pop(c);
                              await OfflineReadingService().removeBook(widget.data.id!);
                              isDownloaded = false;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  } else if (!isDownloading) {
                    setState(() => isDownloading = true);
                    try {
                      await OfflineReadingService().downloadBook(
                        widget.data,
                        widget.data.file ?? widget.data.url ?? "",
                        onReceiveProgress: (rec, total) {
                          setState(() => downloadProgress = rec / total);
                        },
                      );
                      isDownloaded = true;
                      toast(language.lblDownloadComplete);
                    } catch (e) {
                      toast("${language.lblDownloadFailed}: $e");
                    } finally {
                      setState(() {
                        isDownloading = false;
                        downloadProgress = 0.0;
                      });
                    }
                  }
                },
                icon: isDownloading
                    ? CircularProgressIndicator(value: downloadProgress, color: Colors.white, strokeWidth: 2)
                    : Icon(isDownloaded ? Icons.offline_pin : Icons.download, color: Colors.white),
              ),
            if (widget.data.type == "file" || widget.data.type == "pdf")
              Container(width: 2, height: 50, color: Colors.white),
            Container(width: 2, height: 50, color: Colors.white),
            // READ BUTTON
            GestureDetector(
              onTap: () async {
                // Anlık kullanıcı güncellemesi (coin ve premium durumu)
                if (authStore.isLoggedIn) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) => Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: appStore.isDarkModeOn ? Color(0xFF1A1A2E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    ),
                  );
                  
                  try {
                    final updatedUser = await getProfile();
                    await authStore.setUser(updatedUser);
                    if (authStore.currentUser?.id != null) {
                      final accessRes = await checkBookAccess(widget.data.id.toString(), authStore.currentUser!.id.toString());
                      if (accessRes['success'] == true) {
                        var unlocked = accessRes['is_unlocked'];
                        widget.data.isUnlocked = (unlocked == 1 || unlocked == '1' || unlocked == true || unlocked == 'true');
                        widget.data.unlockExpiresAt = accessRes['expires_at'];
                      }
                    }
                  } catch (e) {
                    print(e);
                  } finally {
                    Navigator.pop(context); // Yükleme popup'ını kapat
                  }
                }

                // Premium kitap ve erişim yoksa modal aç
                if (widget.data.isPremium == '1' && !_hasAccess) {
                  _showPremiumAccessModal();
                  return;
                }
                // Erişim varsa direkt aç
                await _openBook();
              },
              child: Observer(
                builder: (_) => Text(
                  _hasAccess ? language.lblReadBook : "Kitabı Aç",
                  style: boldTextStyle(size: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ).expand(),
          ],
        ),
      ).paddingAll(24),
    );
  }
}
