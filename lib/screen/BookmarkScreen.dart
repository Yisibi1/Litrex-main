import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../component/NoInternetComponent.dart';
import '../main.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/appWidget.dart';
import '../component/BookmarkComponent.dart';
import '../component/DialogComponent.dart';
import '../model/DashboardResponse.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/colors.dart';
import 'BookDetailScreen.dart';
import '../store/LibraryStore.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BookmarkScreen extends StatefulWidget {
  static String tag = '/FavouriteScreen';

  const BookmarkScreen({super.key});

  @override
  BookmarkScreenState createState() => BookmarkScreenState();
}

class BookmarkScreenState extends State<BookmarkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget slideLeftBackground() {
    return Container(
      decoration: boxDecorationWithRoundedCornersWidget(backgroundColor: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), bottomLeft: Radius.circular(defaultRadius))),
      margin: EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white),
            Text(" Sil", style: primaryTextStyle(size: 16, color: Colors.white), textAlign: TextAlign.right),
            20.width,
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<LibraryBook> books) {
    if (books.isEmpty) return noDataWidget(context);

    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: books.length,
      padding: EdgeInsets.only(left: 12, right: 16, top: 16, bottom: 8),
      itemBuilder: (_, i) {
        return Dismissible(
          key: Key(books[i].book.id.toString()),
          secondaryBackground: slideLeftBackground(),
          background: SizedBox(),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return showDialogBox(context, "Bu kitabı kütüphaneden silmek istediğinize emin misiniz?", onCancelCall: () {
              finish(context);
            }, onCall: () {
              libraryStore.removeBook(books[i].book.id.toString());
              finish(context, true);
            }).then((value) => value as bool?);
          },
          child: AnimationConfiguration.staggeredGrid(
            position: i,
            columnCount: 1,
            child: SlideAnimation(
              horizontalOffset: 50.0,
              verticalOffset: 20.0,
              child: FadeInAnimation(
                child: BookmarkComponent(
                  books[i].book,
                  onTap: () async {
                    BookDetailScreen(data: books[i].book).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWishList(List<Book> books) {
    if (books.isEmpty) return noDataWidget(context);

    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: books.length,
      padding: EdgeInsets.only(left: 12, right: 16, top: 16, bottom: 8),
      itemBuilder: (_, i) {
        return Dismissible(
          key: Key(books[i].id.toString()),
          secondaryBackground: slideLeftBackground(),
          background: SizedBox(),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return showDialogBox(context, "Bu kitabı kütüphaneden silmek istediğinize emin misiniz?", onCancelCall: () {
              finish(context);
            }, onCall: () {
              wishListStore.addToWishList(books[i]);
              finish(context, true);
            }).then((value) => value as bool?);
          },
          child: AnimationConfiguration.staggeredGrid(
            position: i,
            columnCount: 1,
            child: SlideAnimation(
              horizontalOffset: 50.0,
              verticalOffset: 20.0,
              child: FadeInAnimation(
                child: BookmarkComponent(
                  books[i],
                  onTap: () async {
                    BookDetailScreen(data: books[i]).launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatistics() {
    int totalBooks = libraryStore.completedBooks.length;
    int totalPages = libraryStore.books.fold(0, (sum, item) => sum + item.currentPage);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCornersWidget(
        backgroundColor: context.cardColor,
        borderRadius: radius(12),
        border: Border.all(color: primaryColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(Ionicons.book, color: primaryColor, size: 28),
              8.height,
              Text("$totalBooks", style: boldTextStyle(size: 20)),
              Text("Tamamlanan", style: secondaryTextStyle(size: 14)),
            ],
          ),
          Container(height: 50, width: 1, color: context.dividerColor),
          Column(
            children: [
              Icon(Ionicons.document_text, color: Colors.blue, size: 28),
              8.height,
              Text("$totalPages", style: boldTextStyle(size: 20)),
              Text("Sayfa", style: secondaryTextStyle(size: 14)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kütüphanem", style: boldTextStyle(size: 20, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: "Okunuyor"),
            Tab(text: "Okunacaklar"),
            Tab(text: "Bitenler"),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: libraryStore,
        builder: (context, child) {
          return Column(
            children: [
              _buildStatistics(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(libraryStore.readingBooks),
                    Observer(
                      builder: (context) {
                        return _buildWishList(wishListStore.wishList);
                      }
                    ),
                    _buildList(libraryStore.completedBooks),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
