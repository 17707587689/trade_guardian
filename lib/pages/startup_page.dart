import 'package:flutter/material.dart';

import '../repositories/daily_rule_check_repository.dart';
import 'daily_check_page.dart';
import 'home_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final DailyRuleCheckRepository _checkRepository = DailyRuleCheckRepository();

  late final Future<bool> _confirmedTodayFuture;

  @override
  void initState() {
    super.initState();
    _confirmedTodayFuture = _checkRepository.isConfirmedFor(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _confirmedTodayFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data ?? false) {
          return const HomePage();
        }

        return const DailyCheckPage();
      },
    );
  }
}
