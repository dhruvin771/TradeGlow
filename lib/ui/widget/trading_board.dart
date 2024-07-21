import 'package:flutter/material.dart';

import 'custom_tab.dart';

class TradingBoard extends StatelessWidget {
  const TradingBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.symmetric(
              horizontal: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ))),
      child: const DefaultTabController(
          length: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: CustomTab(tabs: [
                  Tab(text: 'Open Orders'),
                  Tab(text: 'Positions'),
                  Tab(text: 'Order History'),
                  Tab(text: 'Trade History')
                ], isScrollable: true),
              ),
              SizedBox(
                height: 290,
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    EmptyWidget(title: 'No Open Orders'),
                    EmptyWidget(),
                    EmptyWidget(),
                    EmptyWidget(),
                  ],
                ),
              )
            ],
          )),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String title;
  const EmptyWidget({this.title = "Nothing to show here!", super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Id pulvinar nullam sit imperdiet pulvinar.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 2,
                color: Theme.of(context).textTheme.bodySmall!.color),
          )
        ],
      ),
    );
  }
}
