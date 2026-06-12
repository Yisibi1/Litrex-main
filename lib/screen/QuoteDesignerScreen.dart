import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/int_extensions.dart';

class QuoteDesignerScreen extends StatefulWidget {
  final String quoteText;
  final String bookTitle;

  const QuoteDesignerScreen({Key? key, required this.quoteText, required this.bookTitle}) : super(key: key);

  @override
  _QuoteDesignerScreenState createState() => _QuoteDesignerScreenState();
}

class _QuoteDesignerScreenState extends State<QuoteDesignerScreen> {
  final GlobalKey _globalKey = GlobalKey();
  int _selectedGradientIndex = 0;
  bool _isExporting = false;

  final List<List<Color>> _gradients = [
    [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)], // Sunset
    [Color(0xFF1CB5E0), Color(0xFF000851)], // Deep Blue
    [Color(0xFF11998E), Color(0xFF38EF7D)], // Neon Green
    [Color(0xFF2C3E50), Color(0xFF000000)], // Dark
    [Color(0xFFFDC830), Color(0xFFF37335)], // Orange
    [Color(0xFFff9a9e), Color(0xFFfecfef)], // Pastel Pink
  ];

  Future<void> _shareQuote() async {
    setState(() {
      _isExporting = true;
    });
    
    try {
      // 1. RepaintBoundary'dən şəkli çıxar
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // Əgər boundary hələ tam render olunmayıbsa, bir az gözləmək lazımdır, amma bizdə onsuz da UI var.
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 2. Müvəqqəti fayla yaz
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/litrex_quote_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await imagePath.writeAsBytes(pngBytes);

      // 3. Şəkli paylaş
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: '"${widget.quoteText}"\n\n— ${widget.bookTitle}\n\nLitrex ilə oxu: [Tətbiq Linki]',
      );
    } catch (e) {
      print("Error sharing quote: $e");
      toast("Paylaşarkən xəta baş verdi");
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Sitat Dizayneri", color: primaryColor, textColor: Colors.white, showBack: true),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    width: context.width() * 0.9,
                    constraints: BoxConstraints(minHeight: context.width() * 1.1),
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _gradients[_selectedGradientIndex],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: _isExporting ? BorderRadius.zero : BorderRadius.circular(16),
                      boxShadow: _isExporting ? [] : [
                        BoxShadow(color: Colors.black26, blurRadius: 15, spreadRadius: 5)
                      ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.format_quote_rounded, color: Colors.white.withOpacity(0.5), size: 60),
                        16.height,
                        Text(
                          widget.quoteText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.quoteText.length > 100 ? 20 : 26,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'serif',
                            height: 1.5,
                          ),
                        ),
                        32.height,
                        Container(
                          width: 50,
                          height: 2,
                          color: Colors.white54,
                        ),
                        16.height,
                        Text(
                          widget.bookTitle.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        // Litrex Watermark
                        40.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("LITREX", style: boldTextStyle(color: Colors.white54, size: 12, letterSpacing: 1.5)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Controls
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Arxa Plan Seçin", style: boldTextStyle(size: 16)),
                16.height,
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _gradients.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGradientIndex = index;
                          });
                        },
                        child: Container(
                          width: 60,
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _gradients[index],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: _selectedGradientIndex == index ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ]
                          ),
                          child: _selectedGradientIndex == index
                              ? Icon(Icons.check, color: Colors.white, size: 24)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                24.height,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _shareQuote,
                    icon: _isExporting 
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Icon(Icons.share, color: Colors.white),
                    label: Text(_isExporting ? "Hazırlanır..." : "Şəkil Kimi Paylaş", style: boldTextStyle(color: Colors.white, size: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                16.height,
              ],
            ),
          )
        ],
      ),
    );
  }
}
