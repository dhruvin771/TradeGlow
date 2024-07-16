import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tradeglow/domain/services/api_caller.dart';

import '../models/crypto_prices.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiCaller api = ApiCaller();
  late List<CryptoPrice> futureCryptoPrices;
  bool loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void fetchCryptoPrices() async {
    final result = await api.getSymbols();
    result.fold(
      (failure) => {debugPrint('Something went wrong.')},
      (response) {
        futureCryptoPrices = CryptoPrice.fromJsonList(response.data);
        loading = false;
        setState(() {});

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          fetchCryptoPrices();
        });
      },
    );
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
                  : ListView.builder(
                      itemCount: futureCryptoPrices.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Text(
                                    futureCryptoPrices[index].symbol,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Spacer(),
                                  Text(
                                    futureCryptoPrices[index].price,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                color: Colors.white, width: w, height: 0.2),
                          ],
                        );
                      }))
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
