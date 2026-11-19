import 'package:flutter/material.dart';
import '../pages/startup_page.dart';

class TradeGuardianApp extends StatelessWidget {
  const TradeGuardianApp({super.key});

  static const Color _primaryText = Color(0xFF1F2937);
  static const Color _bodyText = Color(0xFF475467);
  static const Color _secondaryText = Color(0xFF667085);
  static const Color _tertiaryText = Color(0xFF98A2B3);

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true);

    return MaterialApp(
      title: 'TradeGuardian',

      debugShowCheckedModeBanner: false,

      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          bodyColor: _bodyText,
          displayColor: _primaryText,
        ),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(
          bodyColor: _primaryText,
          displayColor: _primaryText,
        ),
        appBarTheme: baseTheme.appBarTheme.copyWith(
          foregroundColor: _primaryText,
          titleTextStyle: const TextStyle(
            color: _primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        dialogTheme: baseTheme.dialogTheme.copyWith(
          titleTextStyle: const TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          contentTextStyle: const TextStyle(color: _bodyText),
        ),
        inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
          labelStyle: const TextStyle(color: _secondaryText),
          hintStyle: const TextStyle(color: _tertiaryText),
        ),
      ),

      home: const StartupPage(),
    );
  }
}
