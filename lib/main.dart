import 'package:flutter/material.dart';
import 'package:wherethebusahrebuild/pages/HomePage.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(null),
      theme: ThemeData(fontFamily: 'FiraCode'),
    );
  }
}
