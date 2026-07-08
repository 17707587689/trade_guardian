import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class TradeGuardianApp extends StatelessWidget {
  const TradeGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeGuardian',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),

      home: const HomePage(),
    );
  }
}
