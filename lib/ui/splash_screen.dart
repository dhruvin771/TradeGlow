import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../configs/size_config.dart';
import '../res/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimeout() => Timer(const Duration(seconds: 1), handleTimeout);

  void handleTimeout() => changeScreen();

  Future<void> changeScreen() async {
    Navigator.of(context).pushReplacementNamed(AppRoutes.marketScreen);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig().init(context);
    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Container(
          color: Colors.black,
          child: Center(
              child: Image.asset("assets/images/logo.png",
                  width: SizeConfig.widthOf(40), fit: BoxFit.fitWidth)),
        ));
  }
}
