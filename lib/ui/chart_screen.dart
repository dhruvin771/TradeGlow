import 'dart:async';
import 'dart:math' as math;

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
import '../res/app_colors.dart';
import '../utilities/price_formatter.dart';
import '../widget/candlesticks/src/theme/color_palette.dart';
import 'market_board.dart';

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
  int currentLimit = 0;

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
  final limits = [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

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
                                      orderLimitList(
                                          modalSheetContext, textTheme),
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
                                      currentLimit == 0
                                          ? ViewModel.instance.currentLimit
                                              .toString()
                                          : currentLimit.toString(),
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
                      ListenableBuilder(
                        listenable: ViewModel.instance,
                        builder: (BuildContext context, Widget? child) {
                          final currentLimit = ViewModel.instance.currentLimit;
                          final orderBook = ViewModel.instance.orderBook;
                          final symbolsPairs = ViewModel.instance.symbols;
                          double? highestBid;
                          double? lowestAsk;
                          double? diffHigLow;
                          if (orderBook != null) {
                            highestBid = orderBook.bids.isNotEmpty
                                ? orderBook.bids
                                    .reduce((value, v) =>
                                        value.first > v.first ? value : v)
                                    .first
                                : 0;
                            lowestAsk = orderBook.asks.isNotEmpty
                                ? orderBook.asks
                                    .reduce((value, v) =>
                                        value.first > v.first ? v : value)
                                    .first
                                : 0;
                            diffHigLow = highestBid - lowestAsk;
                          }
                          return Column(
                            children: [
                              if (orderBook != null) ...[
                                if (orderBook.asks.isEmpty) ...[Container()],
                                if (symbolsPairs != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        column('Price',
                                            subTitle: symbolsPairs.baseAsset,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start),
                                        column('Amounts',
                                            subTitle: symbolsPairs.quoteAsset,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center),
                                        column('Total',
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end),
                                      ],
                                    ),
                                  ),
                                Container(
                                    color: Colors.white, width: w, height: 0.2),
                                ListView(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    Column(
                                      children: List.generate(
                                          orderBook.asks.length > currentLimit
                                              ? currentLimit
                                              : orderBook.asks.length,
                                          (index) => OrderView(
                                              order: orderBook.asks[index],
                                              cumulativeQuantity:
                                                  _cumulativeQuantity(orderBook
                                                      .asks
                                                      .sublist(0, index)),
                                              color: AppColors.orange)),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                        color: Colors.white,
                                        width: w,
                                        height: 0.2),
                                    if (orderBook.asks.isNotEmpty &&
                                        orderBook.bids.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$lowestAsk',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.green),
                                            ),
                                            Icon(
                                              diffHigLow! > 0
                                                  ? Icons
                                                      .keyboard_double_arrow_up_outlined
                                                  : Icons
                                                      .keyboard_double_arrow_down_outlined,
                                              color: diffHigLow > 0
                                                  ? AppColors.green
                                                  : null,
                                            ),
                                            Text(
                                              '$highestBid',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                    Container(
                                        color: Colors.white,
                                        width: w,
                                        height: 0.2),
                                    Column(
                                      children: List.generate(
                                          orderBook.bids.length > currentLimit
                                              ? currentLimit
                                              : orderBook.bids.length,
                                          (index) => OrderView(
                                              order: orderBook.bids[index],
                                              cumulativeQuantity:
                                                  _cumulativeQuantity(orderBook
                                                      .bids
                                                      .sublist(0, index)),
                                              color: AppColors.green)),
                                    )
                                  ],
                                )
                              ] else ...[
                                const SizedBox(
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            color: DarkColorPalette.gold)))
                              ]
                            ],
                          );
                        },
                      )
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

  SliverWoltModalSheetPage orderLimitList(
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
                  setState(() => currentLimit = limits[index]);
                  ViewModel.instance.setLimit(limits[index]);
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
                        limits[index].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: limits.length,
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

  Widget column(String title,
          {String? subTitle, required CrossAxisAlignment crossAxisAlignment}) =>
      Expanded(
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall!.color),
            ),
            if (subTitle != null) ...[
              Text(
                '($subTitle)',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall!.color),
              )
            ]
          ],
        ),
      );

  double _cumulativeQuantity(List<List<double>> data) {
    return data.fold(0, (previousValue, d) => previousValue += d.last);
  }
}

class OrderView extends StatelessWidget {
  final List<double> order;
  final Color color;
  final double cumulativeQuantity;

  const OrderView(
      {required this.order,
      required this.color,
      required this.cumulativeQuantity,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: LinearProgressIndicator(
                value: _calculateProgressValue(cumulativeQuantity, order.last),
                minHeight: 28,
                backgroundColor: Colors.transparent,
                color: color.withOpacity(.15),
                borderRadius: BorderRadius.circular(8)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${order.first}',
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${order.last}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${order.first * order.last}',
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  double _calculateProgressValue(
      double cumulativeQuantity, double totalQuantity) {
    // Ensure totalQuantity is not zero to avoid division by zero
    if (totalQuantity == 0) {
      return 0.0;
    }
    // Calculate progress value
    double progressValue = cumulativeQuantity / totalQuantity;
    // Ensure the progress value is between 0.0 and 1.0
    return progressValue.clamp(0.0, 1.0);
  }
}
