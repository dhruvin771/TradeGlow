import 'package:intl/intl.dart';

String formatPrice(double price) {
  String formattedPrice;
  if (price >= 100) {
    formattedPrice = NumberFormat('#,##0.00').format(price);
  } else if (price >= 1) {
    formattedPrice = NumberFormat('#0.0000').format(price);
  } else {
    formattedPrice = NumberFormat('#0.00000000').format(price);
  }

  if (formattedPrice.contains('.')) {
    formattedPrice = formattedPrice.replaceAll(RegExp(r'0+$'), '');
    formattedPrice = formattedPrice.replaceAll(RegExp(r'\.$'), '');
  }

  return formattedPrice;
}
