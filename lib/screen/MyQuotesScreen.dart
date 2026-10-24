import 'package:flutter/material.dart';
import '../main.dart';
import '../model/QuoteModel.dart';
import '../store/QuoteService.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/appWidget.dart';
import '../utils/colors.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/Commons.dart';
import 'QuoteDesignerScreen.dart';
import 'QuoteEditScreen.dart';

class MyQuotesScreen extends StatefulWidget {
  static String tag = '/MyQuotesScreen';

  @override
  _MyQuotesScreenState createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  List<QuoteModel> quotes = [];
  bool isLoading = true;
  String? selectedBook;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final list = await QuoteService.getQuotes();
    setState(() {
      quotes = list;
      isLoading = false;
    });
  }

  Future<void> _deleteQuote(int id) async {
    await QuoteService.removeQuote(id);
    _loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(language.lblMyQuotes, color: primaryColor, textColor: Colors.white, showBack: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : quotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_quote_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                      16.height,
                      Text(language.lblNoQuotesFound, style: secondaryTextStyle(size: 16)),
                    ],
                  ),
                )
              : _buildQuotesContent(),
    );
  }

  Widget _buildQuotesContent() {
    // Extract unique book titles
    final bookTitles = quotes.map((q) => q.bookTitle ?? '').where((t) => t.isNotEmpty).toSet().toList();
    
    // Filter quotes
    final filteredQuotes = selectedBook == null 
        ? quotes 
        : quotes.where((q) => q.bookTitle == selectedBook).toList();

    return Column(
      children: [
        if (bookTitles.isNotEmpty)
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChip(language.lblAllQuotes, selectedBook == null, () {
                  setState(() => selectedBook = null);
                }),
                ...bookTitles.map((title) => _buildChip(title, selectedBook == title, () {
                  setState(() => selectedBook = title);
                })).toList(),
              ],
            ),
          ),
        Expanded(
          child: filteredQuotes.isEmpty
              ? Center(child: Text(language.lblNoQuoteForThisBook, style: secondaryTextStyle()))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredQuotes.length,
                  itemBuilder: (context, index) {
                    final quote = filteredQuotes[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: boxDecorationWithRoundedCornersWidget(
                        backgroundColor: context.cardColor,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.format_quote_rounded, color: primaryColor, size: 30),
                                    8.width,
                                    Expanded(
                                      child: Text(
                                        quote.text ?? '',
                                        style: boldTextStyle(size: 16, height: 1.5),
                                        maxLines: 8,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                16.height,
                                Divider(color: Colors.grey.withOpacity(0.2)),
                                8.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(quote.bookTitle ?? '', style: secondaryTextStyle(color: primaryColor)),
                                          4.height,
                                          Text(quote.date ?? '', style: secondaryTextStyle(size: 12)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined, color: Colors.blue),
                                          onPressed: () async {
                                            bool? result = await QuoteEditScreen(quote: quote).launch(context);
                                            if (result == true) {
                                              _loadQuotes();
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(language.lblDeleteQuoteConfirmTitle, style: boldTextStyle(size: 18)),
                                                content: Text(language.lblDeleteQuoteConfirmMsg, style: primaryTextStyle()),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: Text(language.lblCancel ?? 'İptal', style: primaryTextStyle(color: Colors.grey)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteQuote(quote.id!);
                                                    },
                                                    child: Text("Sil", style: boldTextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.color_lens_outlined, color: primaryColor),
                                          onPressed: () {
                                            QuoteDesignerScreen(
                                              quoteText: quote.text ?? '',
                                              bookTitle: quote.bookTitle ?? '',
                                              isNew: false,
                                              initialColorIndex: quote.colorIndex,
                                            ).launch(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: radius(20),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: boldTextStyle(
              size: 14,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
}
