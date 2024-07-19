import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../candlestick/src/models/candle.dart';
import '../domain/services/api_caller.dart';
import '../utilities/price_formatter.dart';

class SymbolDetailScreen extends StatefulWidget {
  String symbol = "";

  SymbolDetailScreen(this.symbol, {super.key});

  @override
  State<SymbolDetailScreen> createState() => _SymbolDetailScreenState();
}

class _SymbolDetailScreenState extends State<SymbolDetailScreen>
    with WidgetsBindingObserver {
  String get symbol => widget.symbol;
  ApiCaller api = ApiCaller();
  bool loading = true;
  String priceChange = "";
  String priceChangePercent = "";
  String weightedAvgPrice = "";
  String lastPrice = "";
  String openPrice = "";
  String highPrice = "";
  String lowPrice = "";
  String volume = "";
  String quoteVolume = "";
  Timer? _timer;
  Color color = Colors.white;

  @override
  void initState() {
    fetchSymbolDetail();
    fetchCandleData();
    super.initState();
  }

  fetchSymbolDetail() async {
    final result = await api.getSymbolDetails(symbol);
    result.fold(
      (failure) {
        setState(() => loading = false);
        debugPrint('Something went wrong.');
      },
      (response) {
        if (!mounted) return;
        final data = response.data;
        setState(() {
          priceChange = data['priceChange'];
          priceChangePercent = data['priceChangePercent'];
          weightedAvgPrice = data['weightedAvgPrice'];
          lastPrice = data['lastPrice'];
          openPrice = data['openPrice'];
          highPrice = data['highPrice'];
          lowPrice = data['lowPrice'];
          volume = data['volume'];
          quoteVolume = data['quoteVolume'];
          loading = false;
          color = priceChangePercent.contains('-') ? Colors.red : Colors.green;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() => color = Colors.white);
        });
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
          fetchSymbolDetail();
        });
      },
    );
  }

  fetchCandleData() async {
    final result = await api.getCandleData(symbol, "1h");
    result.fold((failure) {
      setState(() => loading = false);
      debugPrint('Something went wrong.');
    }, (response) {
      final data = (jsonDecode(response.data) as List<dynamic>)
          .map((e) => Candle.fromJson(e))
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          symbol,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(color: Colors.white, width: w, height: 0.2),
          Expanded(
            child: loading
                ? const Center(
                    child: CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 12,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatPrice(double.parse(lastPrice)),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '≈\$${formatPrice(double.parse(lastPrice))}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$priceChangePercent%',
                                    style: TextStyle(
                                        color: priceChangePercent.contains("-")
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                highAndVolume('24h High', highPrice),
                                const SizedBox(height: 5),
                                highAndVolume('24h Low', lowPrice),
                              ],
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                highAndVolume('24h Volume', volume),
                                const SizedBox(height: 5),
                                highAndVolume('24h Quote Volume', quoteVolume),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget highAndVolume(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w100),
        ),
        const SizedBox(height: 1),
        Text(
          formatPrice(double.parse(value)),
          style: const TextStyle(
              color: Colors.white, fontSize: 8, fontWeight: FontWeight.w100),
        ),
      ],
    );
  }
}
