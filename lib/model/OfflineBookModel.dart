class OfflineBook {
  final String id;
  final String filePath; // Local encrypted file path
  final String downloadDate;
  final String? bookName;
  final String? authorName;
  final String? bookImage;
  final String? isPremium;
  final String? fileType; // 'pdf' or 'epub' (if supported) or 'file'
  final String? unlockExpiry;

  OfflineBook({
    required this.id,
    required this.filePath,
    required this.downloadDate,
    this.bookName,
    this.authorName,
    this.bookImage,
    this.isPremium,
    this.fileType,
    this.unlockExpiry,
  });

  factory OfflineBook.fromJson(Map<String, dynamic> json) {
    return OfflineBook(
      id: json['id'],
      filePath: json['file_path'],
      downloadDate: json['download_date'],
      bookName: json['book_name'],
      authorName: json['author_name'],
      bookImage: json['book_image'],
      isPremium: json['is_premium'],
      fileType: json['file_type'],
      unlockExpiry: json['unlock_expiry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_path': filePath,
      'download_date': downloadDate,
      'book_name': bookName,
      'author_name': authorName,
      'book_image': bookImage,
      'is_premium': isPremium,
      'file_type': fileType,
      'unlock_expiry': unlockExpiry,
    };
  }
}
