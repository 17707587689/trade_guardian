import 'package:flutter/material.dart';

import '../repositories/daily_rule_check_repository.dart';
import '../repositories/trading_rule_repository.dart';
import '../widgets/trade_rule_confirm_dialog.dart';

import 'home_page.dart';
import 'rules_manage_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final DailyRuleCheckRepository _checkRepository = DailyRuleCheckRepository();

  final TradingRuleRepository _ruleRepository = TradingRuleRepository();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDailyCheckDialog();
    });
  }

  Future<void> _showDailyCheckDialog() async {
    // 1. 检查是否存在交易原则

    final rules = await _ruleRepository.getAllRules();

    if (!mounted) return;

    if (rules.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RulesManagePage()),
      );

      return;
    }

    // 2. 有交易原则，启动每日确认

    final confirmed = await showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (_) {
        return const TradeRuleConfirmDialog(
          showEastMoneyButton: false,

          cancelEnabled: false,
        );
      },
    );

    if (!mounted) return;

    if (confirmed != true) {
      return;
    }

    // 3. 保存今日确认记录

    await _checkRepository.confirmFor(DateTime.now());

    if (!mounted) return;

    // 4. 进入首页

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
