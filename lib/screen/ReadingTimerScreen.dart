import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/colors.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/shared_pref.dart';
import '../main.dart';
import '../store/TrackingStore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReadingTimerScreen extends StatefulWidget {
  @override
  _ReadingTimerScreenState createState() => _ReadingTimerScreenState();
}

class _ReadingTimerScreenState extends State<ReadingTimerScreen> {
  TextEditingController _bookNameController = TextEditingController();
  
  bool _isRunning = false;
  int _seconds = 0;
  Timer? _timer;
  DateTime? _startTime;

  @override
  void dispose() {
    _timer?.cancel();
    _bookNameController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_bookNameController.text.trim().isEmpty) {
      toast("Lütfen kitabın adını yazın");
      return;
    }

    setState(() {
      _isRunning = true;
      _startTime ??= DateTime.now();
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
    if (_seconds >= 10 && _startTime != null) {
      trackingStore.addSession(ReadingSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookName: _bookNameController.text.trim(),
        startTime: _startTime!,
        endTime: DateTime.now(),
        durationSeconds: _seconds,
      ));
      
      // Mərhələ 3: Oyunlaşdırma - Hər 10 dəqiqəyə 5 Coin
      if (_seconds >= 600) { // 600 saniyə = 10 dəqiqə
        int earnedCoins = (_seconds ~/ 600) * 5; // Hər 10 dəqiqəyə 5 coin
        authStore.coins += earnedCoins;
        setValue('COINS', authStore.coins);
        toast("Tebrikler! Okuduğunuz için $earnedCoins Jeton (Coin) kazandınız! 🎉");
      } else {
        toast("Okuma süresi kaydedildi!");
      }
      
    } else if (_seconds < 10 && _startTime != null) {
      toast("10 saniyeden az olan okumalar kaydedilmez");
    }
    
    setState(() {
      _isRunning = false;
      _seconds = 0;
      _startTime = null;
      _bookNameController.clear();
    });
  }


  Future<void> _fetchBookDetails(String isbn) async {
    try {
      final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] != null && data['totalItems'] > 0) {
          final volumeInfo = data['items'][0]['volumeInfo'];
          String title = volumeInfo['title'] ?? 'Bilinmeyen Kitap';
          String author = '';
          if (volumeInfo['authors'] != null && volumeInfo['authors'].isNotEmpty) {
            author = " - " + volumeInfo['authors'][0];
          }
          
          setState(() {
            _bookNameController.text = title + author;
          });
          toast("Kitap bulundu!");
        } else {
          toast("Bu barkodla kitap bulunamadı. Lütfen adını manuel yazın.");
        }
      }
    } catch (e) {
      toast("Hata oluştu: $e");
    }
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Fiziksel Kitap Oku", color: primaryColor, textColor: Colors.white, showBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            24.height,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: boxDecorationWithRoundedCornersWidget(
                backgroundColor: context.cardColor,
                borderRadius: radius(12),
                border: Border.all(color: context.dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bookNameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Okuduğunuz fiziksel kitabın adı",
                        hintStyle: secondaryTextStyle(),
                        icon: Icon(Icons.book, color: unSelectIconColor),
                      ),
                      enabled: !_isRunning && _seconds == 0,
                    ),
                  ),
                ],
              ),
            ),
            40.height,
            
            // Stopwatch UI
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardColor,
                border: Border.all(color: _isRunning ? Colors.green : primaryColor, width: 8),
                boxShadow: [
                  BoxShadow(
                    color: (_isRunning ? Colors.green : primaryColor).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ]
              ),
              child: Center(
                child: Text(
                  _formatTime(_seconds),
                  style: boldTextStyle(size: 48, color: _isRunning ? Colors.green : context.iconColor),
                ),
              ),
            ),
            
            50.height,
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning && _seconds == 0)
                  _buildButton(Icons.play_arrow, "Başlat", Colors.green, _startTimer),
                
                if (_isRunning)
                  _buildButton(Icons.pause, "Duraklat", Colors.orange, _pauseTimer),
                  
                if (!_isRunning && _seconds > 0)
                  _buildButton(Icons.play_arrow, "Devam et", Colors.green, _startTimer),
                  
                if (_seconds > 0) ...[
                  20.width,
                  _buildButton(Icons.stop, "Bitir", Colors.red, _stopTimer),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius(30),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: boxDecorationWithRoundedCornersWidget(
          backgroundColor: color,
          borderRadius: radius(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            8.width,
            Text(text, style: boldTextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
