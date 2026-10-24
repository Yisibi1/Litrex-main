import 'dart:async';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../network/AuthApis.dart';
import '../model/DashboardResponse.dart';
import '../store/LibraryStore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sync_pdf;
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../component/PDFViewerComponent.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../screen/BookmarkScreen.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/device_extensions.dart';
import '../utils/colors.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../component/AdMobComponent.dart';
import '../network/RestApis.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'CategoryScreen.dart';
import 'HomeScreen.dart';
import 'auth/ProfileScreen.dart';
import 'WebViewScreen.dart';
import '../main.dart';
import 'PremiumScreen.dart';
import 'CoinPurchaseScreen.dart';
import 'StatisticsScreen.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/constant.dart';
import '../utils/Extensions/shared_pref.dart';


class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final tab = [
    HomeScreen(),
    CategoryScreen(),
    // StatisticsScreen(), // Hiding for now until Virtual Library is ready
    BookmarkScreen(),
    ProfileScreen(),
  ];

  Timer? _sessionTimer;
  StreamSubscription? _intentSubscription;
  
  // Reklam limiti state
  bool _adLimitReached = false;
  DateTime? _nextResetTime;
  Timer? _countdownTimer;
  String _countdownText = "";
  ValueNotifier<String> _countdownNotifier = ValueNotifier<String>("");
  bool _isCheckingLimit = false; // API sorğusu gedərkən duplicate klik qoruması

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (isMobile) {
      OneSignal.Notifications.addClickListener((notification) {
        if (notification.notification.launchUrl != null && !notification.notification.launchUrl!.isEmptyOrNull) {
          if (!notification.notification.launchUrl!.contains(".pdf")) {
            WebViewScreen(title: notification.notification.title.validate(),mInitialUrl: notification.notification.launchUrl).launch(context);
          } else {
            PDFViewerComponent(title: notification.notification.title.validate(),url: notification.notification.launchUrl!).launch(context);
          }
        }
      });
    }

    createRewardedAd();
    _startSessionCheck();
    _restoreLimitState(); // SharedPreferences-dən limit vəziyyətini bərpa et
    
    // Kənardan paylaşılan PDF-ləri dinlə (App qapalıykən)
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty && mounted) {
        _openSharedFile(value.first);
      }
    });

    // Kənardan paylaşılan PDF-ləri dinlə (App açıqkən/arxaplandaykən)
    _intentSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty && mounted) {
        _openSharedFile(value.first);
      }
    });
  }

  void _openSharedFile(SharedMediaFile sharedFile) async {
    String path = sharedFile.path;
    if (path.isNotEmpty) {
      // Bəzi cihazlarda path 'file://' ilə başlaya bilər
      if (path.startsWith('file://')) {
        path = path.replaceFirst('file://', '');
      }
      
      // Boşluqlar '%20' kimi kodlanmış ola bilər, ona görə decode edirik
      path = Uri.decodeFull(path);
      
      try {
        File file = File(path);
        
        String fileName = path.split('/').last;

        if (fileName.toLowerCase().endsWith('.json')) {
          _showLocalAddonPromptDialog(path, fileName);
          return;
        }
        
        String _cleanFileName(String name) {
          String text = name.replaceAll('.pdf', '').replaceAll('-', ' ').replaceAll('_', ' ');
          text = text.replaceAll(RegExp(r'pdf indir|pdf|epub|mobi|indir', caseSensitive: false), '').trim();
          if (text.isEmpty) return "Bilinmeyen Kitap";
          return text.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
        }

        String extractedTitle = _cleanFileName(fileName);
        String extractedAuthor = "Bilinmeyen Yazar";
        
        // Extract Metadata using Syncfusion PDF (yalnız 10 MB-dan kiçik fayllar üçün OOM-un qarşısını almaq üçün)
        try {
          if (file.existsSync() && file.lengthSync() < 10 * 1024 * 1024) {
            var bytes = await file.readAsBytes();
            final syncDoc = sync_pdf.PdfDocument(inputBytes: bytes);
            if (syncDoc.documentInformation.title.isNotEmpty) {
               extractedTitle = syncDoc.documentInformation.title;
            }
            if (syncDoc.documentInformation.author.isNotEmpty) {
               extractedAuthor = syncDoc.documentInformation.author;
            }
            syncDoc.dispose();
          }
        } catch (e) {
          print("Metadata extraction error: $e");
        }
        
        String logoPath = "";
        try {
          final tempDir = await getTemporaryDirectory();
          logoPath = "${tempDir.path}/thumb_${path.hashCode}.png";
          File thumbFile = File(logoPath);
          if (!thumbFile.existsSync()) {
            final document = await pdfx.PdfDocument.openFile(path);
            final page = await document.getPage(1);
            final pageImage = await page.render(width: page.width / 2, height: page.height / 2, format: pdfx.PdfPageImageFormat.png);
            if (pageImage != null) {
              await thumbFile.writeAsBytes(pageImage.bytes);
            }
            await page.close();
            await document.close();
          }
        } catch (e) {
          print("Thumb generation error: $e");
        }
        
        // Virtual Kitab yarat (Son Oxunanlar üçün)
        Book virtualBook = Book(
          id: "local_${path.hashCode}",
          name: extractedTitle,
          url: path,
          logo: logoPath,
          authorName: extractedAuthor, 
          addonSource: "external_file"
        );
        
        // Kitabxanaya "Son Oxunan" olaraq əlavə et
        libraryStore.addBook(virtualBook, LibraryStatus.reading);
        
        // PDF Ekranını Aç (fileBytes null ötürülür ki, SfPdfViewer.file işləsin, RAM dolmasın)
        PDFViewerComponent(
          title: fileName,
          url: path, 
          fileBytes: null,
          book: virtualBook,
        ).launch(context);
        
      } catch (e) {
        toast("${language.lblErrorOpeningBook}\nXəta: $e");
      }
    }
  }

  /// SharedPreferences-dən limit vəziyyətini bərpa et (app restart-da taymer itməsin)
  Future<void> _restoreLimitState() async {
    final resetStr = getStringAsync('ad_limit_next_reset');
    if (resetStr.isNotEmpty) {
      final resetTime = DateTime.tryParse(resetStr);
      if (resetTime != null && resetTime.isAfter(DateTime.now())) {
        setState(() {
          _adLimitReached = true;
          _nextResetTime = resetTime;
        });
        _startCountdown();
      } else {
        // Vaxtı keçib, limiti sıfırla
        await setValue('ad_limit_next_reset', '');
      }
    }
  }

  /// Limit vəziyyətini yadda saxla
  Future<void> _saveLimitState(String nextReset) async {
    await setValue('ad_limit_next_reset', nextReset);
  }
  
  void _startSessionCheck() {
    _checkSession();
    _sessionTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _checkSession();
    });
  }

  void _checkSession() {
    if (authStore.isLoggedIn) {
      getProfile().then((value) {
        authStore.setUser(value);
      }).catchError((e) {
        print("Session check error: $e");
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdownText();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateCountdownText();
    });
  }

  void _updateCountdownText() {
    if (_nextResetTime == null) return;
    final now = DateTime.now();
    final diff = _nextResetTime!.difference(now);
    if (diff.isNegative) {
      setState(() {
        _adLimitReached = false;
        _nextResetTime = null;
        _countdownText = "";
      });
      _countdownNotifier.value = "";
      _countdownTimer?.cancel();
      setValue('ad_limit_next_reset', ''); // SharedPreferences-dən sil
      return;
    }
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    setState(() {
      _countdownText = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    });
    _countdownNotifier.value = _countdownText;
  }

  /// 🔑 DÜZGÜN AXIN: Ön-yoxla → Reklam göstər → Sonra jeton ver
  Future<void> _handleAdButtonTap() async {
    if (_isCheckingLimit) return;
    setState(() => _isCheckingLimit = true);

    try {
      // 1. Əvvəl serverə sor — YALNIZ limit yoxla (jeton vermə!)
      final preCheck = await checkAdLimit();

      if (preCheck['limit_reached'] == true) {
        // ❌ Limit dolub — reklam göstərmə, taymer göstər
        _setLimitReached(preCheck);
        _showLimitDialog();
        return;
      }

      if (preCheck['success'] == true) {
        if (preCheck['can_watch'] == true) {
          // ✅ Limit yoxdur (Yeni Server axını) — reklamı göstər
          bool shown = showRewardedAd(onUserEarnedReward: () {
            rewardAd().then((value) {
              if (value['success'] == true) {
                _handleSuccessfulReward(value);
              } else if (value['limit_reached'] == true) {
                _setLimitReached(value);
                _showLimitDialog();
              } else {
                toast(value['message'] ?? language.lblSomethingWentWrong);
              }
            }).catchError((e) => toast(e.toString()));
          });
          if (!shown) toast(language.lblAdLoadingWait);
        } else {
          // ⚠️ Server KÖHNƏDİR (check_only başa düşmür və dərhal jeton verir)
          toast("Server faylı (reward-ad.php) yenilənməyib! Xahiş edirik cPanel-də faylı güncəlləyin.");
          _handleSuccessfulReward(preCheck); // Jetonu onsuz da verib
        }
      } else {
        toast(preCheck['message'] ?? "Bilinməyən xəta baş verdi");
      }
    } catch (e) {
      toast("Xəta: ${e.toString()}");
    } finally {
      setState(() => _isCheckingLimit = false);
    }
  }

  void _handleSuccessfulReward(Map<String, dynamic> value) {
    toast(value['message']);
    if (value['new_balance'] != null) {
      int newCoins = value['new_balance'] is int
          ? value['new_balance'] as int
          : int.tryParse(value['new_balance'].toString()) ?? authStore.coins;

      authStore.coins = newCoins;
      setValue('COINS', newCoins);
      if (authStore.currentUser != null) {
        authStore.currentUser!.coins = newCoins;
      }
    }
  }

  void _setLimitReached(Map<String, dynamic> value) {
    setState(() {
      _adLimitReached = true;
      if (value['next_reset'] != null) {
        _nextResetTime = DateTime.tryParse(value['next_reset'].toString());
        _saveLimitState(value['next_reset'].toString());
        _startCountdown();
      }
    });
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: _countdownNotifier,
        builder: (context, dialogCountdown, child) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E2E), // Solid modern dark
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Color(0xFF9155FD).withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Color(0xFF9155FD).withOpacity(0.15), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B6B).withOpacity(0.2), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(color: Color(0xFFFF6B6B).withOpacity(0.5)),
                    ),
                    child: Icon(Icons.timer_off_rounded, color: Color(0xFFFF6B6B), size: 48),
                  ),
                  SizedBox(height: 24),

                  // Title
                  Text(
                    language.lblDailyAdLimitReached,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  SizedBox(height: 12),

                  // Subtitle
                  Text(
                    language.lblDailyAdLimitMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                  ),
                  SizedBox(height: 30),

                  // Premium Timer Box
                  if (dialogCountdown.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFF151521),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF9155FD).withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                            Text(
                              language.lblTimeUntilReset,
                              style: TextStyle(color: Color(0xFF9155FD).withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_empty_rounded, color: Color(0xFF9155FD), size: 24),
                              SizedBox(width: 8),
                              Text(
                                dialogCountdown,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(color: Color(0xFF9155FD), blurRadius: 15),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 32),

                  // Main Action (Instagram Gradient)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: Color(0xFFE94057).withOpacity(0.4), blurRadius: 15, offset: Offset(0, 5)),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        PremiumScreen().launch(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Text(
                            language.lblGetPremiumNow.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Secondary Actions
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFFFFB74D).withOpacity(0.5), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Color(0xFFFFB74D).withOpacity(0.05),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              CoinPurchaseScreen().launch(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("💰 ", style: TextStyle(fontSize: 18)),
                                Text(language.lblBuyCoins, style: TextStyle(color: Color(0xFFFFB74D), fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.white.withOpacity(0.05),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              language.lblCancel,
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
  
  @override
  void dispose() {
    _intentSubscription?.cancel();
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Widget mLine() {
    return Container(
      height: 3,
      margin: EdgeInsets.only(top: 6),
      width: 20,
      decoration: boxDecorationWithShadowWidget(boxShape: BoxShape.rectangle, backgroundColor: primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tab[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: context.scaffoldBackgroundColor,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        selectedLabelStyle: primaryTextStyle(),
        currentIndex: _currentIndex,
        unselectedItemColor: unSelectIconColor,
        selectedItemColor: primaryColor,
        onTap: (index) {
          _currentIndex = index;
          setState(() {});
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Ionicons.md_book_outline, size: 20), activeIcon: Column(children: [Icon(Ionicons.book, size: 22), mLine()]), label: ""),
          BottomNavigationBarItem(icon: Icon(Ionicons.md_grid_outline, size: 20), activeIcon: Column(children: [Icon(Ionicons.md_grid, size: 22), mLine()]), label: ""),
          // BottomNavigationBarItem(icon: Icon(Ionicons.stats_chart_outline, size: 20), activeIcon: Column(children: [Icon(Ionicons.stats_chart, size: 22), mLine()]), label: ""), // Hidden for now
          BottomNavigationBarItem(icon: Icon(Ionicons.library_outline, size: 20), activeIcon: Column(children: [Icon(Ionicons.library, size: 22), mLine()]), label: ""),
          BottomNavigationBarItem(icon: Icon(Ionicons.person_outline, size: 20), activeIcon: Column(children: [Icon(Ionicons.person, size: 22), mLine()]), label: ""),
        ],
      ),
      bottomSheet: Observer(
        builder: (_) {
          if (authStore.isPremiumUser || _currentIndex != 0) return Offstage();
          
          // Limit dolubsa — taymer göstər (PREMIUM DİZAYN)
          if (_adLimitReached) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: Color(0xFFE94057).withOpacity(0.4), blurRadius: 8, offset: Offset(0, -2))
                ]
              ),
              width: context.width(),
              height: 44,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showLimitDialog,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.lock_clock, color: Colors.white, size: 20),
                        8.width,
                        Text(
                          language.lblLimitReached,
                          style: boldTextStyle(color: Colors.white, size: 12),
                        ),
                        Expanded(
                          child: Text(
                            _countdownText,
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 1.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                          ),
                          child: Text(language.lblGoToPremium, style: TextStyle(color: Color(0xFFE94057), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            color: Color(0xFF9155FD),
            width: context.width(),
            height: 36,
            child: InkWell(
              onTap: _isCheckingLimit ? null : _handleAdButtonTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _isCheckingLimit
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Icon(Icons.play_circle_fill, color: Colors.white, size: 24),
                    12.width,
                    Text(
                      _isCheckingLimit 
                          ? language.lblChecking 
                          : "${language.lblWatchVideoToEarn}${getIntAsync(AD_REWARD_COINS, defaultValue: 1)}${language.lblCoins}",
                      style: boldTextStyle(color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLocalAddonPromptDialog(String localPath, String addonName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(language.lblAddNewAddon, style: boldTextStyle(size: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bu eklentiyi (Addon) eklemek istiyor musunuz?", style: secondaryTextStyle()),
            12.height,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                addonName,
                style: primaryTextStyle(size: 13, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.lblCancel, style: primaryTextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              List<String> urls = getStringListAsync('addon_urls') ?? [];
              String addonUrl = "file://$localPath";

              if (urls.contains(addonUrl)) {
                toast(language.lblUrlAlreadyExists);
                return;
              }

              if (urls.length >= 5) {
                toast(language.lblMaxAddonsLimit);
                return;
              }

              urls.add(addonUrl);
              await setValue('addon_urls', urls);
              toast(language.lblAddonAddedSuccess);
              
              // Refresh app by restarting Dashboard
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(language.lblYes, style: boldTextStyle(color: Colors.white, size: 14)),
          ),
        ],
      ),
    );
  }
}
