import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../model/DashboardResponse.dart';
import '../utils/Extensions/shared_pref.dart';

enum LibraryStatus { reading, completed, want_to_read }

class LibraryBook {
  final Book book;
  LibraryStatus status;
  int currentPage;
  int totalPages;
  DateTime lastReadDate;

  LibraryBook({
    required this.book,
    required this.status,
    required this.currentPage,
    required this.totalPages,
    required this.lastReadDate,
  });

  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'book': book.toJson(),
      'status': status.name,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'lastReadDate': lastReadDate.toIso8601String(),
    };
  }

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    return LibraryBook(
      book: Book.fromJson(json['book']),
      status: LibraryStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => LibraryStatus.reading),
      currentPage: json['currentPage'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      lastReadDate: json['lastReadDate'] != null ? DateTime.parse(json['lastReadDate']) : DateTime.now(),
    );
  }
}

class LibraryStore extends ChangeNotifier {
  List<LibraryBook> _books = [];

  List<LibraryBook> get books => _books;

  List<LibraryBook> get readingBooks => _books.where((b) => b.status == LibraryStatus.reading).toList();
  List<LibraryBook> get completedBooks => _books.where((b) => b.status == LibraryStatus.completed).toList();
  List<LibraryBook> get wantToReadBooks => _books.where((b) => b.status == LibraryStatus.want_to_read).toList();

  LibraryBook? get latestReadingBook {
    if (readingBooks.isEmpty) return null;
    return readingBooks.reduce((a, b) => a.lastReadDate.isAfter(b.lastReadDate) ? a : b);
  }

  LibraryStore() {
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    String? jsonStr = getStringAsync('USER_LIBRARY_DATA');
    if (jsonStr.isNotEmpty) {
      try {
        List<dynamic> jsonList = jsonDecode(jsonStr);
        _books = jsonList.map((e) => LibraryBook.fromJson(e)).toList();
        notifyListeners();
      } catch (e) {
        print("Error loading library: $e");
      }
    }
  }

  Future<void> _saveLibrary() async {
    String jsonStr = jsonEncode(_books.map((e) => e.toJson()).toList());
    await setValue('USER_LIBRARY_DATA', jsonStr);
    notifyListeners();
  }

  void addBook(Book book, LibraryStatus status) {
    int index = _books.indexWhere((b) => b.book.id == book.id);
    if (index >= 0) {
      _books[index].status = status;
      _books[index].lastReadDate = DateTime.now();
    } else {
      _books.add(LibraryBook(
        book: book,
        status: status,
        currentPage: 0,
        totalPages: 0,
        lastReadDate: DateTime.now(),
      ));
    }
    _saveLibrary();
  }

  void updateProgress(Book book, int currentPage, int totalPages) {
    int index = _books.indexWhere((b) => b.book.id == book.id);
    if (index >= 0) {
      _books[index].currentPage = currentPage;
      if (totalPages > 0) _books[index].totalPages = totalPages;
      _books[index].lastReadDate = DateTime.now();
      
      if (currentPage >= totalPages && totalPages > 0) {
        _books[index].status = LibraryStatus.completed;
      } else {
        _books[index].status = LibraryStatus.reading;
      }
    } else {
      _books.add(LibraryBook(
        book: book,
        status: currentPage >= totalPages && totalPages > 0 ? LibraryStatus.completed : LibraryStatus.reading,
        currentPage: currentPage,
        totalPages: totalPages,
        lastReadDate: DateTime.now(),
      ));
    }
    _saveLibrary();
  }

  void removeBook(String bookId) {
    _books.removeWhere((b) => b.book.id == bookId);
    _saveLibrary();
  }

  bool isInLibrary(String bookId) {
    return _books.any((b) => b.book.id == bookId);
  }

  LibraryStatus? getBookStatus(String bookId) {
    try {
      return _books.firstWhere((b) => b.book.id == bookId).status;
    } catch (e) {
      return null;
    }
  }
}

// Global instance
final libraryStore = LibraryStore();
