class QuoteModel {
  int? id;
  String? text;
  String? bookTitle;
  int? colorIndex;
  String? date;

  QuoteModel({this.id, this.text, this.bookTitle, this.colorIndex, this.date});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'],
      text: json['text'],
      bookTitle: json['bookTitle'],
      colorIndex: json['colorIndex'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['text'] = text;
    data['bookTitle'] = bookTitle;
    data['colorIndex'] = colorIndex;
    data['date'] = date;
    return data;
  }
}
