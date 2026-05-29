import 'package:flutter/material.dart';
import '../model/DashboardResponse.dart';
import '../store/LibraryStore.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../screen/BookDetailScreen.dart';

class ContinueReadingWidget extends StatefulWidget {
  const ContinueReadingWidget({super.key});

  @override
  _ContinueReadingWidgetState createState() => _ContinueReadingWidgetState();
}

class _ContinueReadingWidgetState extends State<ContinueReadingWidget> {
  @override
  void initState() {
    super.initState();
    libraryStore.addListener(_onLibraryChanged);
  }

  @override
  void dispose() {
    libraryStore.removeListener(_onLibraryChanged);
    super.dispose();
  }

  void _onLibraryChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    LibraryBook? recentBook = libraryStore.latestReadingBook;
    
    if (recentBook == null) {
      return SizedBox();
    }

    Book book = recentBook.book;
    double progress = recentBook.progress;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: boxDecorationWithRoundedCornersWidget(
        backgroundColor: context.cardColor,
        borderRadius: radius(12),
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          BookDetailScreen(data: book).launch(context);
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.logo != null && book.logo!.isNotEmpty
                  ? Image.network(book.logo!, height: 80, width: 60, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[800], height: 80, width: 60))
                  : Container(color: Colors.grey[800], height: 80, width: 60),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Devam Et", style: secondaryTextStyle(size: 12, color: primaryColor)),
                      Text("${(progress * 100).toInt()}%", style: boldTextStyle(size: 12, color: primaryColor)),
                    ],
                  ),
                  4.height,
                  Text(book.name ?? "Kitap", style: boldTextStyle(size: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  4.height,
                  Text(book.authorName ?? "Yazar", style: secondaryTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  12.height,
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
