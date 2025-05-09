import 'package:etf_oglasi/core/navigation/routes.dart';
import 'package:etf_oglasi/core/ui/theme/theme_constants.dart';
import 'package:etf_oglasi/core/util/service_locator.dart';
import 'package:etf_oglasi/features/home/presentation/screen/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  setUpLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: const HomeScreen(),
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
