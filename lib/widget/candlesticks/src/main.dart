import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tradeglow/widget/candlesticks/candlesticks.dart';
import 'package:tradeglow/widget/candlesticks/src/widgets/mobile_chart.dart';
import 'package:tradeglow/widget/candlesticks/src/widgets/toolbar.dart';

/// StatefulWidget that holds Chart's State (index of
/// current position and candles width).
class Candlesticks extends StatefulWidget {
  /// The arrangement of the array should be such that
  ///  the newest item is in position 0
  final List<Candle> candles;

  /// this callback calls when the last candle gets visible
  final Future<void> Function()? onLoadMoreCandles;

  /// list of buttons you what to add on top tool bar
  final List<ToolBarAction> actions;

  const Candlesticks({
    Key? key,
    required this.candles,
    this.onLoadMoreCandles,
    this.actions = const [],
  }) : super(key: key);

  @override
  _CandlesticksState createState() => _CandlesticksState();
}

class _CandlesticksState extends State<Candlesticks> {
  /// index of the newest candle to be displayed
  /// changes when user scrolls along the chart
  int index = -10;
  double lastX = 0;
  int lastIndex = -10;

  /// candleWidth controls the width of the single candles.
  ///  range: [2...10]
  double candleWidth = 6;

  /// true when widget.onLoadMoreCandles is fetching new candles.
  bool isCallingLoadMore = false;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    return Column(
      children: [
        if (widget.candles.isEmpty) ...[
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).gold,
              ),
            ),
          )
        ] else ...[
          ToolBar(
            onZoomInPressed: () {
              setState(() {
                candleWidth += 2;
                candleWidth = min(candleWidth, 16);
              });
            },
            onZoomOutPressed: () {
              setState(() {
                candleWidth -= 2;
                candleWidth = max(candleWidth, 4);
              });
            },
            children: widget.actions,
          ),
          Container(color: Colors.white, width: w, height: 0.2),
          Expanded(
            child: TweenAnimationBuilder(
              tween: Tween(begin: 6.toDouble(), end: candleWidth),
              duration: const Duration(milliseconds: 120),
              builder: (_, double width, __) {
                return MobileChart(
                  onScaleUpdate: (double scale) {
                    scale = max(0.90, scale);
                    scale = min(1.1, scale);
                    setState(() {
                      candleWidth *= scale;
                      candleWidth = min(candleWidth, 16);
                      candleWidth = max(candleWidth, 4);
                    });
                  },
                  onPanEnd: () {
                    lastIndex = index;
                  },
                  onHorizontalDragUpdate: (double x) {
                    setState(() {
                      x = x - lastX;
                      index = lastIndex + x ~/ candleWidth;
                      index = max(index, -10);
                      index = min(index, widget.candles.length - 1);
                    });
                  },
                  onPanDown: (double value) {
                    lastX = value;
                    lastIndex = index;
                  },
                  onReachEnd: () {
                    if (isCallingLoadMore == false &&
                        widget.onLoadMoreCandles != null) {
                      isCallingLoadMore = true;
                      widget.onLoadMoreCandles!().then((_) {
                        isCallingLoadMore = false;
                      });
                    }
                  },
                  candleWidth: width,
                  candles: widget.candles,
                  index: index,
                );
              },
            ),
          ),
        ]
      ],
    );
  }
}
