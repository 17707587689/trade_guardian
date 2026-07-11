import 'package:flutter/material.dart';

import '../repositories/daily_rule_check_repository.dart';
import '../widgets/trading_rule_confirmation_dialog.dart';
import 'home_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final DailyRuleCheckRepository _checkRepository = DailyRuleCheckRepository();

  @override
  void initState() {
    super.initState();
    // Always show the daily check dialog on each app startup/login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDailyCheckDialog();
    });
  }

  Future<void> _showDailyCheckDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const TradingRuleConfirmationDialog(cancelEnabled: false),
    );

    if (!mounted) return;

    if (confirmed != true) {
      return;
    }

    await _checkRepository.confirmFor(DateTime.now());

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading scaffold while the dialog is shown; after confirmation
    // the dialog will navigate to HomePage.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
