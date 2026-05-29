import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';      // <<< SON SAYFA KAYDI İÇİN

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
import '../model/DashboardResponse.dart';

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
  
  // Anti-Offline: internet yoxlama
  bool _isOffline = false;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    print("PDF Path=>${widget.url}");
    _pdfViewerController = PdfViewerController();

    // Jetonla açılıb interstitial reklam göstəriləcəksə, hazırla
    if (widget.isUnlockedWithCoins) {
      createInterstitialAd();
      _startConnectivityCheck();
    }

    /// 🔥 PDF yeniden açıldığında son kaldığın sayfaya otomatik gider
    String key = widget.fileBytes != null ? "local_${widget.title}" : widget.url;
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
        child: ElevatedButton(
            child: Text('Copy', style: TextStyle(fontSize: 16)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: details.selectedText.validate()));
              _pdfViewerController!.clearSelection();
            }),
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
    _connectivityTimer?.cancel();
    super.dispose();
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
      appBar: appBarWidget(widget.title, textSize: 18, color: primaryColor, textColor: Colors.white, showBack: true),
      bottomNavigationBar: mWebBannerAds == '1' ? showBannerAds() : SizedBox(),

      body: Stack(
        children: [
          // PDF Viewer
          widget.fileBytes != null
            ? SfPdfViewer.memory(
                widget.fileBytes!,
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                otherSearchTextHighlightColor: primaryColor,
                enableTextSelection: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                scrollDirection: PdfScrollDirection.vertical,
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
              )
            : SfPdfViewer.network(
                widget.url.validate(),
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                otherSearchTextHighlightColor: primaryColor,
                enableTextSelection: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                scrollDirection: PdfScrollDirection.vertical,
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
              ),

          // 🛡️ Anti-Offline Overlay (yalnız jetonla açılan kitablarda)
          if (widget.isUnlockedWithCoins && _isOffline)
            _buildOfflineBlocker(),
        ],
      ),
    );
  }
}
