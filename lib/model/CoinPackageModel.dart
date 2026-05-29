/// Admin panelden eklenen jeton paketi.
/// SKU ile Google Play'den fiyat çekilir; coin_amount backend'den gelir.
class CoinPackage {
  int? id;
  String? sku;
  int? coinAmount;
  String? title;
  int? sortOrder;
  String? currency;
  String? displayPrice;

  CoinPackage({
    this.id,
    this.sku,
    this.coinAmount,
    this.title,
    this.sortOrder,
    this.currency,
    this.displayPrice,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      sku: json['sku']?.toString(),
      coinAmount: json['coin_amount'] is String
          ? int.tryParse(json['coin_amount'])
          : json['coin_amount'],
      title: json['title']?.toString(),
      sortOrder: json['sort_order'] is String
          ? int.tryParse(json['sort_order'])
          : json['sort_order'],
      currency: json['currency']?.toString(),
      displayPrice: json['display_price']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'coin_amount': coinAmount,
      'title': title,
      'sort_order': sortOrder,
      'currency': currency,
      'display_price': displayPrice,
    };
  }
}
