import 'dart:convert';
import '../model/QuoteModel.dart';
import '../utils/Extensions/shared_pref.dart';

class QuoteService {
  static const String QUOTE_LIST_KEY = 'LITREX_QUOTE_LIST';

  static Future<List<QuoteModel>> getQuotes() async {
    String data = getStringAsync(QUOTE_LIST_KEY);
    if (data.isNotEmpty) {
      try {
        Iterable l = jsonDecode(data);
        return List<QuoteModel>.from(l.map((model) => QuoteModel.fromJson(model)));
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<void> addQuote(QuoteModel quote) async {
    List<QuoteModel> quotes = await getQuotes();
    // Generate unique ID
    quote.id = DateTime.now().millisecondsSinceEpoch;
    // Add to beginning
    quotes.insert(0, quote);
    await setValue(QUOTE_LIST_KEY, jsonEncode(quotes.map((e) => e.toJson()).toList()));
  }

  static Future<void> removeQuote(int id) async {
    List<QuoteModel> quotes = await getQuotes();
    quotes.removeWhere((element) => element.id == id);
    await setValue(QUOTE_LIST_KEY, jsonEncode(quotes.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearQuotes() async {
    await setValue(QUOTE_LIST_KEY, '');
  }

  static Future<void> updateQuote(QuoteModel updatedQuote) async {
    List<QuoteModel> quotes = await getQuotes();
    int index = quotes.indexWhere((element) => element.id == updatedQuote.id);
    if (index != -1) {
      quotes[index] = updatedQuote;
      await setValue(QUOTE_LIST_KEY, jsonEncode(quotes.map((e) => e.toJson()).toList()));
    }
  }
}
