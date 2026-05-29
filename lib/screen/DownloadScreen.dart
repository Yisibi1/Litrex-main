import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../main.dart';
import '../model/OfflineBookModel.dart';
import '../utils/OfflineReadingService.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../utils/images.dart';
import '../utils/appWidget.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Loader.dart';
import '../component/PDFViewerComponent.dart';
import '../model/DashboardResponse.dart';
import 'PremiumScreen.dart';
import '../component/NativeAdWidget.dart';

class DownloadScreen extends StatefulWidget {
  static String tag = '/DownloadScreen';

  const DownloadScreen({super.key});

  @override
  DownloadScreenState createState() => DownloadScreenState();
}

class DownloadScreenState extends State<DownloadScreen> {
  List<OfflineBook> downloadedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setState(() => isLoading = true);
    downloadedBooks = await OfflineReadingService().getDownloadedBooks();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language.lblDownloads, style: boldTextStyle(size: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: context.iconColor),
      ),
      body: isLoading 
          ? Loader().center() 
          : downloadedBooks.isEmpty 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Ionicons.cloud_download_outline, size: 80, color: textSecondaryColorGlobal),
                    16.height,
                    Text(language.lblNoDownloadedBooks, style: boldTextStyle()),
                    8.height,
                    Text(language.lblDownloadToReadOffline, style: secondaryTextStyle()),
                  ],
                ).center()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: downloadedBooks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == downloadedBooks.length) {
                      return NativeAdWidget();
                    }
                    final book = downloadedBooks[index];
                    return Column(
                      children: [
                        _buildBookItem(book),
                        16.height,
                      ],
                    );
                  },
                ),

    );
  }

  Widget _buildBookItem(OfflineBook book) {
    return Container(
      decoration: boxDecorationWithRoundedCornersWidget(
        backgroundColor: context.cardColor,
        borderRadius: radius(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Book Cover
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
            child: book.bookImage != null && book.bookImage!.isNotEmpty
                ? cachedImage(book.bookImage!, height: 100, width: 70, fit: BoxFit.cover)
                : Image.asset(ic_placeholder, height: 100, width: 70, fit: BoxFit.cover),
          ),
          
          12.width,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.bookName ?? "Unknown Title", style: boldTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis),
                4.height,
                Text(book.authorName ?? "Unknown Author", style: secondaryTextStyle(size: 14)),
                8.height,
                Row(
                  children: [
                    if (book.isPremium == '1')
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: radius(4),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Text("Premium", style: boldTextStyle(color: Colors.amber[700], size: 10)),
                      ),
                  ],
                )
              ],
            ),
          ),
          
          // Action Buttons
          Column(
            children: [
               IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(book),
              ),
              IconButton(
                icon: Icon(Ionicons.book_outline, color: primaryColor),
                onPressed: () => _openBook(book),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _confirmDelete(OfflineBook book) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(language.lblDeleteBookTitle, style: boldTextStyle()),
        content: Text(language.lblDeleteBookMsg, style: secondaryTextStyle()),
        actions: [
          TextButton(
            child: Text(language.lblCancel, style: primaryTextStyle()),
            onPressed: () => Navigator.pop(c),
          ),
          TextButton(
            child: Text(language.lblDelete, style: boldTextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(c);
              await OfflineReadingService().removeBook(book.id);
              init(); // Refresh list
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openBook(OfflineBook book) async {
    // Check Premium Access
    bool noAccess = book.isPremium == '1' && !authStore.isPremiumUser;
    if (noAccess && book.unlockExpiry != null) {
       if (DateTime.now().isBefore(DateTime.parse(book.unlockExpiry!))) {
          noAccess = false;
       }
    }

    if (noAccess) {
       PremiumScreen().launch(context);
       return;
    }

    // Decrypt and Open
    try {
      final bytes = await OfflineReadingService().getDecryptedBook(book.id, isPremiumUser: authStore.isPremiumUser);
      if (bytes != null) {
        PDFViewerComponent(
          title: book.bookName ?? language.lblUnknownTitle, 
          url: "", // Not used when bytes provided
          fileBytes: bytes,
          book: Book(id: book.id.toString(), name: book.bookName, authorName: book.authorName, logo: book.bookImage)
        ).launch(context);
      } else {
        toast(language.lblErrorOpeningBook);
      }
    } catch (e) {
      toast("${language.lblSomethingWentWrong}: $e");
    }
  }
}
