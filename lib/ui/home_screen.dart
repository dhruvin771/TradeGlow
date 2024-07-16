import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:tradeglow/animation/page_change_animation.dart';
import 'package:tradeglow/domain/services/api_caller.dart';
import 'package:tradeglow/ui/symbol_detail_screen.dart';

import '../models/crypto_prices.dart';
import '../utilities/price_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  ApiCaller api = ApiCaller();
  late List<CryptoPrice> futureCryptoPrices = [];
  late List<CryptoPrice> previousCryptoPrices = [];
  bool loading = true;
  bool status = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => status = false);
      fetchCryptoPrices();
    } else if (state == AppLifecycleState.paused) {
      setState(() => status = true);
    }
  }

  void fetchCryptoPrices() async {
    final result = await api.getSymbols();
    result.fold(
      (failure) => {debugPrint('Something went wrong.')},
      (response) {
        if (status) return;
        if (!mounted) return;
        if (!loading || previousCryptoPrices.isEmpty) {
          previousCryptoPrices = futureCryptoPrices;
          setState(() {});
        }
        futureCryptoPrices = CryptoPrice.fromJsonList(response.data);
        loading = false;
        setState(() {});
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
          fetchCryptoPrices();
        });
      },
    );
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
        title: const Text(
          'Market',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(8.0),
            onPressed: () {
              showExitDialog(context);
            },
            icon: const Icon(Icons.exit_to_app),
            color: Colors.white,
          )
        ],
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
                  : SmoothListView.builder(
                      itemCount: futureCryptoPrices.length,
                      itemBuilder: (context, index) {
                        Color color = previousCryptoPrices.isEmpty ||
                                (double.parse(
                                        previousCryptoPrices[index].price) ==
                                    double.parse(
                                        futureCryptoPrices[index].price))
                            ? Colors.grey
                            : (double.parse(previousCryptoPrices[index].price) <
                                    double.parse(
                                        futureCryptoPrices[index].price))
                                ? Colors.green
                                : Colors.red;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (futureCryptoPrices[index].symbol.isEmpty)
                                  return;
                                Navigator.push(
                                    context,
                                    PageChangeAnimation(SymbolDetailScreen(
                                        futureCryptoPrices[index].symbol)));
                              },
                              child: Container(
                                color: Colors.white.withOpacity(0.001),
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Text(
                                      futureCryptoPrices[index].symbol,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '\$${formatPrice(double.parse(futureCryptoPrices[index].price.toString()))}',
                                      style: TextStyle(color: color),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                color: Colors.white, width: w, height: 0.2),
                          ],
                        );
                      },
                      duration: const Duration(milliseconds: 200)))
        ],
      ),
    );
  }

  void showExitDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                'Exit',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
