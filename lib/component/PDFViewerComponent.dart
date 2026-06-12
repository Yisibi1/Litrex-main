import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../utils/appWidget.dart';
import '../utils/constant.dart';
import '../main.dart';
import 'AdMobComponent.dart';
import '../store/LibraryStore.dart';
import '../store/TrackingStore.dart';
import '../model/DashboardResponse.dart';
import '../screen/QuoteDesignerScreen.dart';

class PDFViewerComponent extends StatefulWidget {
  static String tag = '/PDFViewerComponent';
  final String url;
  final String title;
  final bool isAdsLoad;
  final Uint8List? fileBytes;
  final bool isUnlockedWithCoins;
  final Book? book; // Added for Library tracking

  const PDFViewerComponent({
    super.key,
    required this.url,
    required this.title,
    this.isAdsLoad = false,
    this.fileBytes,
    this.isUnlockedWithCoins = false,
    this.book,
  });

  @override
  PDFViewerComponentState createState() => PDFViewerComponentState();
}

class PDFViewerComponentState extends State<PDFViewerComponent> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfViewerController;
  OverlayEntry? _overlayEntry;
  int _lastAdShownPage = 0; // Son reklam gösterilən səhifə
  DateTime? _sessionStartTime;

  String _readingTheme = 'light';
  PdfScrollDirection _scrollDirection = PdfScrollDirection.vertical;
  bool _isFullScreen = false;

  Color get _appBarColor {
    if (_readingTheme == 'dark') return Color(0xFF1E1E1E);
    if (_readingTheme == 'sepia') return Color(0xFFFFFFEE);
    return primaryColor;
  }

  Color get _appBarTextColor {
    if (_readingTheme == 'sepia') return Colors.black;
    return Colors.white;
  }

  static const ColorFilter _darkFilter = ColorFilter.matrix(<double>[
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  static const ColorFilter _sepiaFilter = ColorFilter.matrix(<double>[
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0, 0, 0, 1, 0,
  ]);
  
  // Anti-Offline: internet yoxlama
  bool _isOffline = false;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    init();
  }

  Future<void> init() async {
    print("PDF Path=>${widget.url}");
    _pdfViewerController = PdfViewerController();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _readingTheme = prefs.getString('pdf_reading_theme') ?? 'light';
    String savedScroll = prefs.getString('pdf_scroll_direction') ?? 'vertical';
    _scrollDirection = savedScroll == 'horizontal' ? PdfScrollDirection.horizontal : PdfScrollDirection.vertical;
    
    setState(() {});

    // Jetonla açılıb interstitial reklam göstəriləcəksə, hazırla
    if (widget.isUnlockedWithCoins) {
      createInterstitialAd();
      _startConnectivityCheck();
    }

    /// 🔥 PDF yeniden açıldığında son kaldığın sayfaya otomatik gider
    String key = widget.fileBytes != null ? "local_${widget.title}" : widget.url;
    int? lastPage = prefs.getInt("last_page_$key"); 

    Future.delayed(Duration(seconds: 1), () {
      if (lastPage != null && lastPage > 1) {
        _pdfViewerController!.jumpToPage(lastPage);
        _lastAdShownPage = lastPage;
        print("📌 Son kaldığın sayfaya gidildi ➜ $lastPage");
      }
    });
  }

  /// 🛡️ Anti-Offline: Hər 5 saniyədə internet yoxla
  void _startConnectivityCheck() {
    _checkConnectivity(); // İlk yoxlama
    _connectivityTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (_isOffline && mounted) {
          setState(() => _isOffline = false);
        }
      }
    } catch (_) {
      if (!_isOffline && mounted) {
        setState(() => _isOffline = true);
      }
    }
  }

  /// Hər [pdfAdPageInterval] səhifədə Interstitial reklam göstər (yalnız jetonla açılan kitablarda)
  void _onPageChangedWithAds(int newPage) {
    if (!widget.isUnlockedWithCoins) return;
    
    int pagesSinceLastAd = (newPage - _lastAdShownPage).abs();
    int adInterval = getIntAsync(PDF_AD_PAGE_INTERVAL, defaultValue: 5);
    
    if (pagesSinceLastAd >= adInterval) {
      _lastAdShownPage = newPage;
      if (interstitialAd != null) {
        adShow();
        Future.delayed(Duration(seconds: 1), () {
          createInterstitialAd();
        });
        print("📺 Interstitial reklam gösterildi ➜ Sayfa $newPage (Interval: $adInterval)");
      }
    }
  }

  /// 🔥 Metin seçilince kopyalama menüsü
  void _showContextMenu(BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion!.center.dy - 55,
        left: details.globalSelectedRegion!.bottomLeft.dx,
        child: Row(
          children: [
            ElevatedButton(
                child: Text('Copy', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: details.selectedText.validate()));
                  _pdfViewerController!.clearSelection();
                }),
            8.width,
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: Text('Dizayn Et', style: TextStyle(fontSize: 16, color: Colors.white)),
                onPressed: () {
                  final text = details.selectedText.validate();
                  _pdfViewerController!.clearSelection();
                  QuoteDesignerScreen(quoteText: text, bookTitle: widget.title).launch(context);
                }),
          ],
        ),
      ),
    );
    overlayState.insert(_overlayEntry!);
  }

  void _updateLibraryProgress(int newPage) {
    if (widget.book != null) {
      int totalPages = _pdfViewerController?.pageCount ?? 0;
      libraryStore.updateProgress(widget.book!, newPage, totalPages);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (_sessionStartTime != null) {
      final endTime = DateTime.now();
      final diff = endTime.difference(_sessionStartTime!);
      if (diff.inSeconds >= 10) { // Saniyə limiti: 10 saniyədən az oxusa saymasın
        trackingStore.addSession(ReadingSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bookName: widget.title,
          startTime: _sessionStartTime!,
          endTime: endTime,
          durationSeconds: diff.inSeconds,
        ));
      }
    }
    _connectivityTimer?.cancel();
    _overlayEntry?.remove();
    _pdfViewerController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showReadingSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: radius(10)),
                    ),
                  ),
                  20.height,
                  Text(language.lblReadingMode, style: boldTextStyle(size: 16)),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeOption('light', 'Light', Colors.white, Colors.black, setBottomSheetState),
                      _buildThemeOption('sepia', 'Sepia', Color(0xFFF4ECD8), Colors.black, setBottomSheetState),
                      _buildThemeOption('dark', 'Dark', Color(0xFF1E1E1E), Colors.white, setBottomSheetState),
                    ],
                  ),
                  24.height,
                  Text(language.lblScrollDirection, style: boldTextStyle(size: 16)),
                  16.height,
                  Container(
                    decoration: BoxDecoration(
                      color: context.dividerColor.withOpacity(0.1),
                      borderRadius: radius(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              _scrollDirection = PdfScrollDirection.vertical;
                              setBottomSheetState((){});
                              setState((){});
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString('pdf_scroll_direction', 'vertical');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _scrollDirection == PdfScrollDirection.vertical ? primaryColor : Colors.transparent,
                                borderRadius: radius(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(language.lblVertical, style: boldTextStyle(color: _scrollDirection == PdfScrollDirection.vertical ? Colors.white : textPrimaryColorGlobal)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              _scrollDirection = PdfScrollDirection.horizontal;
                              setBottomSheetState((){});
                              setState((){});
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString('pdf_scroll_direction', 'horizontal');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _scrollDirection == PdfScrollDirection.horizontal ? primaryColor : Colors.transparent,
                                borderRadius: radius(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(language.lblHorizontal, style: boldTextStyle(color: _scrollDirection == PdfScrollDirection.horizontal ? Colors.white : textPrimaryColorGlobal)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  24.height,
                  Text(language.lblFullScreen, style: boldTextStyle(size: 16)),
                  16.height,
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _isFullScreen = true);
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: radius(12),
                        border: Border.all(color: primaryColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(language.lblFullScreen, style: boldTextStyle(color: primaryColor)),
                    ),
                  ),
                  20.height,
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildThemeOption(String themeKey, String name, Color bgColor, Color textColor, StateSetter setBottomSheetState) {
    bool isSelected = _readingTheme == themeKey;
    return InkWell(
      onTap: () async {
        _readingTheme = themeKey;
        setBottomSheetState((){});
        setState((){});
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('pdf_reading_theme', themeKey);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius(12),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3), width: isSelected ? 2 : 1),
        ),
        child: Text(name, style: boldTextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildFilteredViewer(Widget viewer) {
    if (_readingTheme == 'dark') {
      return Container(color: Colors.black, child: ColorFiltered(colorFilter: _darkFilter, child: viewer));
    } else if (_readingTheme == 'sepia') {
      return Container(color: Color(0xFFF4ECD8), child: ColorFiltered(colorFilter: _sepiaFilter, child: viewer));
    }
    return viewer;
  }

  /// 🛡️ Offline bloklama overlay-i
  Widget _buildOfflineBlocker() {
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B6B).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.wifi_off_rounded, color: Color(0xFFFF6B6B), size: 40),
              ),
              SizedBox(height: 24),
              Text(
                language.lblOfflineBlockTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                language.lblOfflineBlockMsg,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9155FD),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.diamond_rounded, color: Colors.white),
                  label: Text(language.lblGetPremiumNow, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context); // PDF-dən çıx
                  },
                ),
              ),
              SizedBox(height: 12),
              TextButton.icon(
                icon: Icon(Icons.refresh, color: Colors.white54, size: 18),
                label: Text("Yeniden dene", style: TextStyle(color: Colors.white54)),
                onPressed: () => _checkConnectivity(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen ? null : appBarWidget(
        widget.title,
        textSize: 18,
        color: primaryColor,
        textColor: Colors.white,
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showReadingSettingsBottomSheet();
            },
          )
        ],
      ),
      bottomNavigationBar: _isFullScreen ? null : (mWebBannerAds == '1' ? showBannerAds() : SizedBox()),

      body: Stack(
        children: [
          // PDF Viewer
          widget.fileBytes != null
            ? _buildFilteredViewer(SfPdfViewer.memory(
                widget.fileBytes!,
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                otherSearchTextHighlightColor: primaryColor,
                enableTextSelection: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                scrollDirection: _scrollDirection,
                canShowPaginationDialog: true,
                canShowScrollStatus: true,
                onPageChanged: (PdfPageChangedDetails details) async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt("last_page_local_${widget.title}", details.newPageNumber);
                  print("💾 Son sayfa kaydedildi: ${details.newPageNumber}");
                  _onPageChangedWithAds(details.newPageNumber);
                  _updateLibraryProgress(details.newPageNumber);
                },
                onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                  if (details.selectedText == null && _overlayEntry != null) {
                    _overlayEntry!.remove();
                    _overlayEntry = null;
                  } else if (details.selectedText != null && _overlayEntry == null) {
                    _showContextMenu(context, details);
                  }
                },
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  toast(details.description);
                },
              ))
            : _buildFilteredViewer(SfPdfViewer.network(
                widget.url.validate(),
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                otherSearchTextHighlightColor: primaryColor,
                enableTextSelection: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                scrollDirection: _scrollDirection,
                canShowPaginationDialog: true,
                canShowScrollStatus: true,
                onPageChanged: (PdfPageChangedDetails details) async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setInt("last_page_${widget.url}", details.newPageNumber);
                  print("💾 Son sayfa kaydedildi: ${details.newPageNumber}");
                  _onPageChangedWithAds(details.newPageNumber);
                  _updateLibraryProgress(details.newPageNumber);
                },
                onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                  if (details.selectedText == null && _overlayEntry != null) {
                    _overlayEntry!.remove();
                    _overlayEntry = null;
                  } else if (details.selectedText != null && _overlayEntry == null) {
                    _showContextMenu(context, details);
                  }
                },
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  toast(details.description);
                },
              )),

          // 🛡️ Anti-Offline Overlay (yalnız jetonla açılan kitablarda)
          if (widget.isUnlockedWithCoins && _isOffline)
            _buildOfflineBlocker(),
            
          if (_isFullScreen)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: _appBarColor.withOpacity(0.8),
                elevation: 0,
                child: Icon(Icons.fullscreen_exit, color: _appBarTextColor),
                onPressed: () {
                  setState(() => _isFullScreen = false);
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                },
              ),
            ),
        ],
      ),
    );
  }
}
