class CryptoPrice {
  final String symbol;
  final String price;

  CryptoPrice({required this.symbol, required this.price});

  factory CryptoPrice.fromJson(Map<String, dynamic> json) {
    return CryptoPrice(
      symbol: json['symbol'],
      price: json['price'],
    );
  }

  static List<CryptoPrice> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CryptoPrice.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
    };
  }
}
