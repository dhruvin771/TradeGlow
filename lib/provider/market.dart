import 'package:flutter/material.dart';

import '../models/crypto_prices.dart';

class CryptoPriceList with ChangeNotifier {
  late List<CryptoPrice> _cryptoPrices = [];
  late List<CryptoPrice> _oldCryptoPrices = [];

  List<CryptoPrice> get cryptoPrices => _cryptoPrices.toList();

  List<CryptoPrice> get oldCryptoPrices => _oldCryptoPrices.toList();

  void addCryptoPrice(List<CryptoPrice> list) {
    cryptoPrices.clear();
    _cryptoPrices = list;
    notifyListeners();
  }

  void oldCryptoPrice(List<CryptoPrice> list) {
    oldCryptoPrices.clear();
    _oldCryptoPrices = list;
    notifyListeners();
  }
}
