import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradeglow/provider/market.dart';

import 'res/app_routes.dart';
import 'res/app_strings.dart';
import 'res/app_theme.dart';

Future<void> main() async {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => CryptoPriceList())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.splashScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
