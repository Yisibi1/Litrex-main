import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/OfflineBookModel.dart';
import '../model/DashboardResponse.dart';
import '../utils/Extensions/string_extensions.dart';

class OfflineReadingService {
  static final OfflineReadingService _instance = OfflineReadingService._internal();

  factory OfflineReadingService() {
    return _instance;
  }

  OfflineReadingService._internal();

  final _storage = FlutterSecureStorage();
  final _dio = Dio();
  static const _keyStorageKey = 'offline_book_key';
  static const _booksPrefsKey = 'offline_books_list';

  // Initialize/Get Encryption Key
  Future<encrypt.Key> _getOrGenerateKey() async {
    String? keyString = await _storage.read(key: _keyStorageKey);
    if (keyString == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _keyStorageKey, value: base64UrlEncode(key.bytes));
      return key;
    } else {
      return encrypt.Key(base64Url.decode(keyString));
    }
  }

  // Get list of downloaded books
  Future<List<OfflineBook>> getDownloadedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? booksJson = prefs.getString(_booksPrefsKey);
    if (booksJson == null) return [];
    
    List<dynamic> list = jsonDecode(booksJson);
    return list.map((e) => OfflineBook.fromJson(e)).toList();
  }

  // Check if book is downloaded
  Future<bool> isBookDownloaded(String bookId) async {
    final books = await getDownloadedBooks();
    return books.any((b) => b.id == bookId);
  }

  // Download and Encrypt Book
  Future<void> downloadBook(Book bookData, String fileUrl, {Function(int, int)? onReceiveProgress}) async {
    final bookId = bookData.id!;
    try {
      // 1. Download file
      final response = await _dio.get(
        fileUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      );

      final List<int> fileBytes = response.data;

      // 2. Encrypt
      final key = await _getOrGenerateKey();
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

      // 3. Save to App Docs Dir
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/book_$bookId.enc';
      final file = File(filePath);
      
      // Store IV + Encrypted Data
      // We prepend the IV to the file content for easy retrieval
      final combined = iv.bytes + encrypted.bytes;
      await file.writeAsBytes(combined);

      // 4. Update Local Record
      final books = await getDownloadedBooks();
      books.removeWhere((b) => b.id == bookId); // Remove if exists (re-download)
      
      books.add(OfflineBook(
        id: bookId,
        filePath: filePath,
        downloadDate: DateTime.now().toIso8601String(),
        bookName: bookData.name.validate(value: "Book"),
        authorName: bookData.authorName.validate(value: "Unknown Author"),
        bookImage: bookData.logo.validate(),
        isPremium: bookData.isPremium,
        fileType: bookData.type,
        unlockExpiry: bookData.unlockExpiresAt,
      ));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_booksPrefsKey, jsonEncode(books.map((b) => b.toJson()).toList()));

    } catch (e) {
      print('Download Failed: $e');
      rethrow;
    }
  }

  // Decrypt Book for Reading
  Future<Uint8List?> getDecryptedBook(String bookId, {bool isPremiumUser = false}) async {
    try {
      final books = await getDownloadedBooks();
      final book = books.firstWhere((b) => b.id == bookId, orElse: () => OfflineBook(id: '', filePath: '', downloadDate: ''));

      if (book.id.isEmpty) return null;

      final file = File(book.filePath);
      if (!await file.exists()) return null;

      // 24 saatlik erişim kontrolü
      if (!isPremiumUser && book.isPremium == '1') {
        if (book.unlockExpiry != null) {
          final expiry = DateTime.parse(book.unlockExpiry!);
          if (DateTime.now().isAfter(expiry)) {
            print("Access expired for book: $bookId");
            return null;
          }
        } else {
           // Eğer Premium kitabın expiry bilgisi yoksa ve kullanıcı premium değilse (ve jetonla açmamışsa)
           print("No access for premium book: $bookId");
           return null;
        }
      }

      final fileBytes = await file.readAsBytes();
      
      // Extract IV (first 16 bytes)
      final ivBytes = fileBytes.sublist(0, 16);
      final encryptedBytes = fileBytes.sublist(16);

      final key = await _getOrGenerateKey();
      final iv = encrypt.IV(ivBytes);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
      return Uint8List.fromList(decrypted);

    } catch (e) {
      print('Decryption Failed: $e');
      return null;
    }
  }

  // Remove Download
  Future<void> removeBook(String bookId) async {
    final books = await getDownloadedBooks();
    final bookIndex = books.indexWhere((b) => b.id == bookId);
    
    if (bookIndex != -1) {
      final book = books[bookIndex];
      final file = File(book.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      books.removeAt(bookIndex);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_booksPrefsKey, jsonEncode(books.map((b) => b.toJson()).toList()));
    }
  }

  // Clear All Downloads
  Future<void> clearAllBooks() async {
    final books = await getDownloadedBooks();
    for (final book in books) {
      final file = File(book.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_booksPrefsKey);
  }
}
