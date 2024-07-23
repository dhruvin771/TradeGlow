import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../core/data_models/ticker.dart';
import '../core/view_model.dart';
import '../domain/services/api_caller.dart';
import '../models/crypto_prices.dart';
import '../provider/market.dart';
import '../utilities/price_formatter.dart';
import 'widget/market_board.dart';

class ChartScreen extends StatefulWidget {
  String symbol = "";

  ChartScreen(this.symbol, {super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String baseAsset = "";
  String quoteAsset = "";
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
  Color color = Colors.white;
  Timer? _timer;

  String symbol = "";
  String currentTime = "";

  final intervals = [
    '1m',
    '3m',
    '5m',
    '15m',
    '30m',
    '1h',
    '2h',
    '4h',
    '6h',
    '8h',
    '12h',
    '1d',
    '3d',
    '1w',
    '1M'
  ];

  @override
  void initState() {
    setState(() => symbol = widget.symbol);
    fetchSymbolDetail();
    fetchExchangeInfo();
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
        String oldPriceChangePercent = priceChangePercent;
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
          color = priceChangePercent.contains(oldPriceChangePercent)
              ? Colors.white
              : priceChangePercent.contains('-')
                  ? Colors.red
                  : Colors.green;
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

  fetchExchangeInfo() async {
    final result = await api.getExchangeInfo(symbol);
    result.fold((failure) {
      debugPrint('Something went wrong.');
    }, (response) {
      setState(() {
        quoteAsset = response.data['symbols'][0]['quoteAsset'];
        baseAsset = response.data['symbols'][0]['baseAsset'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (baseAsset.isNotEmpty && quoteAsset.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    WoltModalSheet.show<void>(
                      context: context,
                      pageListBuilder: (modalSheetContext) {
                        final textTheme = Theme.of(context).textTheme;
                        return [
                          marketList(modalSheetContext, textTheme),
                        ];
                      },
                      modalTypeBuilder: (context) {
                        return WoltModalType.bottomSheet();
                      },
                      onModalDismissedWithBarrierTap: () {
                        debugPrint('Closed modal sheet with barrier tap');
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  child: Container(
                    color: Colors.white.withOpacity(0.001),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 32,
                          width: 44,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.orange,
                                  child: Text(baseAsset,
                                      style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white))),
                              Positioned(
                                  right: 1.5,
                                  child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.green,
                                      child: Text(quoteAsset,
                                          style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white))))
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$baseAsset/$quoteAsset',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.expand_circle_down_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 50)
              ]
            ],
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(color: Colors.white, width: w, height: 0.2),
            if (loading)
              const Expanded(
                child: Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 12,
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white.withOpacity(.03),
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
                                            color:
                                                priceChangePercent.contains("-")
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
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    highAndVolume('24h Volume', volume),
                                    const SizedBox(height: 5),
                                    highAndVolume(
                                        '24h Quote Volume', quoteVolume),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(color: Colors.white, width: w, height: 0.2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Row(
                          children: [
                            const Text(
                              'Time',
                              style: TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                WoltModalSheet.show<void>(
                                  context: context,
                                  pageListBuilder: (modalSheetContext) {
                                    final textTheme =
                                        Theme.of(context).textTheme;
                                    return [
                                      timeList(modalSheetContext, textTheme),
                                    ];
                                  },
                                  modalTypeBuilder: (context) {
                                    return WoltModalType.bottomSheet();
                                  },
                                  onModalDismissedWithBarrierTap: () {
                                    debugPrint(
                                        'Closed modal sheet with barrier tap');
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 12, top: 2, bottom: 2, right: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  children: [
                                    Text(
                                      currentTime.isEmpty
                                          ? ViewModel.instance.currentInterval
                                          : currentTime,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Icon(
                                      size: 16,
                                      Icons.keyboard_arrow_down_sharp,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(color: Colors.white, width: w, height: 0.2),
                      const MarketBoard(),
                      Container(color: Colors.white, width: w, height: 0.2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Row(
                          children: [
                            const Text(
                              'Orders',
                              style: TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                WoltModalSheet.show<void>(
                                  context: context,
                                  pageListBuilder: (modalSheetContext) {
                                    final textTheme =
                                        Theme.of(context).textTheme;
                                    return [
                                      timeList(modalSheetContext, textTheme),
                                    ];
                                  },
                                  modalTypeBuilder: (context) {
                                    return WoltModalType.bottomSheet();
                                  },
                                  onModalDismissedWithBarrierTap: () {
                                    debugPrint(
                                        'Closed modal sheet with barrier tap');
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 12, top: 2, bottom: 2, right: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  children: [
                                    Text(
                                      currentTime.isEmpty
                                          ? ViewModel.instance.currentInterval
                                          : currentTime,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Icon(
                                      size: 16,
                                      Icons.keyboard_arrow_down_sharp,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(color: Colors.white, width: w, height: 0.2),
                    ],
                  ),
                ),
              )
          ],
        ));
  }

  SliverWoltModalSheetPage marketList(
      BuildContext modalSheetContext, TextTheme textTheme) {
    List<CryptoPrice> price =
        Provider.of<CryptoPriceList>(context).cryptoPrices;
    List<CryptoPrice> oldPrice =
        Provider.of<CryptoPriceList>(context).oldCryptoPrices;
    return SliverWoltModalSheetPage(
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(15),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      mainContentSliversBuilder: (context) => [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              Color color = oldPrice.isEmpty ||
                      (double.parse(oldPrice[index].price) ==
                          double.parse(price[index].price))
                  ? Colors.grey
                  : (double.parse(oldPrice[index].price) <
                          double.parse(price[index].price))
                      ? Colors.green
                      : Colors.red;
              return GestureDetector(
                onTap: () {
                  setState(() => symbol = price[index].symbol);
                  fetchSymbolDetail();
                  fetchExchangeInfo();
                  ViewModel.instance
                      .updateData(Ticker.fromMap(price[index].toJson()));
                  Navigator.pop(modalSheetContext);
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border.symmetric(
                          horizontal:
                              BorderSide(color: Colors.blueGrey, width: 0.3))),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        price[index].symbol,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        '\$${formatPrice(double.parse(price[index].price.toString()))}',
                        style: TextStyle(color: color),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: price.length,
          ),
        )
      ],
    );
  }

  SliverWoltModalSheetPage timeList(
      BuildContext modalSheetContext, TextTheme textTheme) {
    return SliverWoltModalSheetPage(
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(15),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      mainContentSliversBuilder: (context) => [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              return GestureDetector(
                onTap: () {
                  setState(() => currentTime = intervals[index]);
                  ViewModel.instance.setInterval(intervals[index]);
                  Navigator.pop(modalSheetContext);
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border.symmetric(
                          horizontal:
                              BorderSide(color: Colors.blueGrey, width: 0.3))),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        intervals[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: intervals.length,
          ),
        )
      ],
    );
  }

  Widget highAndVolume(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
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
