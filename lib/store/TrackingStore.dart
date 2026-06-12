import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/Extensions/shared_pref.dart';

class ReadingSession {
  final String id;
  final String bookName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;

  ReadingSession({
    required this.id,
    required this.bookName,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      bookName: json['bookName'] ?? 'Bilinməyən Kitab',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationSeconds: json['durationSeconds'] ?? 0,
    );
  }
}

class TrackingStore extends ChangeNotifier {
  List<ReadingSession> _sessions = [];

  List<ReadingSession> get sessions => _sessions;

  TrackingStore() {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    String? jsonStr = getStringAsync('USER_READING_SESSIONS');
    if (jsonStr.isNotEmpty) {
      try {
        List<dynamic> jsonList = jsonDecode(jsonStr);
        _sessions = jsonList.map((e) => ReadingSession.fromJson(e)).toList();
        notifyListeners();
      } catch (e) {
        print("Error loading reading sessions: $e");
      }
    }
  }

  Future<void> _saveSessions() async {
    String jsonStr = jsonEncode(_sessions.map((e) => e.toJson()).toList());
    await setValue('USER_READING_SESSIONS', jsonStr);
    notifyListeners();
  }

  void addSession(ReadingSession session) {
    _sessions.add(session);
    _saveSessions();
  }

  void clearSessions() {
    _sessions.clear();
    _saveSessions();
  }

  int getTodayTotalSeconds() {
    final now = DateTime.now();
    return _sessions.where((s) {
      return s.endTime.year == now.year &&
          s.endTime.month == now.month &&
          s.endTime.day == now.day;
    }).fold(0, (sum, item) => sum + item.durationSeconds);
  }

  List<ReadingSession> getTodaySessions() {
    final now = DateTime.now();
    return _sessions.where((s) {
      return s.endTime.year == now.year &&
          s.endTime.month == now.month &&
          s.endTime.day == now.day;
    }).toList();
  }
}

// Global instance
final trackingStore = TrackingStore();
