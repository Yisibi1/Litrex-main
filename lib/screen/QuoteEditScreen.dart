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

class QuoteEditScreen extends StatefulWidget {
  final QuoteModel quote;

  const QuoteEditScreen({Key? key, required this.quote}) : super(key: key);

  @override
  _QuoteEditScreenState createState() => _QuoteEditScreenState();
}

class _QuoteEditScreenState extends State<QuoteEditScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.quote.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveQuote() async {
    if (_textController.text.trim().isNotEmpty) {
      widget.quote.text = _textController.text.trim();
      await QuoteService.updateQuote(widget.quote);
      toast("Güncellendi");
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      toast("Alıntı metni boş olamaz");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Metni Düzenle",
        color: primaryColor,
        textColor: Colors.white,
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Alıntı Metni", style: boldTextStyle(size: 16)),
            12.height,
            Container(
              decoration: boxDecorationWithRoundedCornersWidget(
                backgroundColor: context.cardColor,
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                minLines: 10,
                style: primaryTextStyle(size: 16, height: 1.5),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: "Alıntı metni...",
                  hintStyle: secondaryTextStyle(),
                ),
              ),
            ),
            24.height,
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Kaydet", style: boldTextStyle(color: Colors.white, size: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
