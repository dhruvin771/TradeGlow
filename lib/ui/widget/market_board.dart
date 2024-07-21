import 'package:flutter/material.dart';

import '../../core/view_model.dart';
import '../../widget/candlesticks/src/main.dart';

class MarketBoard extends StatelessWidget {
  const MarketBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 452,
        width: double.infinity,
        color: Colors.black,
        child: const SizedBox(height: 450, child: ChartView()));
  }
}

class ChartView extends StatelessWidget {
  const ChartView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ViewModel.instance,
      builder: (BuildContext context, Widget? child) {
        final candles = ViewModel.instance.candles;
        return Candlesticks(
            key: Key(
                '${ViewModel.instance.currentTicker?.symbol}${ViewModel.instance.currentInterval}'),
            candles: candles,
            onLoadMoreCandles: ViewModel.instance.fetchMoreCandles);
      },
    );
  }
}
