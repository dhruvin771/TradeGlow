class AppEndpoints {
  static String domainUrl = "https://api.binance.com/api/v3/";
  static String establishConnectionUrl = "wss://stream.binance.com:9443/ws";
  static String symbols = "ticker/price";

  static String symbolDetail(String symbol) => "ticker/24hr?symbol=$symbol";

  static String candlesUrl(
          {required String symbol, required String interval, int? endTime}) =>
      "klines?symbol=$symbol&interval=$interval${endTime != null ? "&endTime=$endTime" : ""}";

  static String orderBooksUrl({required String symbol, required int limit}) =>
      "depth?symbol=$symbol&limit=$limit";

  static String exchangeInfoUrl(String symbol) => "exchangeInfo?symbol=$symbol";
}
