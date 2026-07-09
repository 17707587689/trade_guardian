import 'package:flutter/material.dart';

import '../models/trading_rule.dart';
import '../repositories/daily_rule_check_repository.dart';
import '../repositories/trading_rule_repository.dart';
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

  Future<void> _showDailyCheckDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _DailyCheckDialog(),
    );

    if (!mounted) return;

    await _checkRepository.confirmFor(DateTime.now());

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDailyCheckDialog();
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _DailyCheckDialog extends StatefulWidget {
  const _DailyCheckDialog();

  @override
  State<_DailyCheckDialog> createState() => _DailyCheckDialogState();
}

class _DailyCheckDialogState extends State<_DailyCheckDialog> {
  final TradingRuleRepository _ruleRepository = TradingRuleRepository();

  late Future<List<TradingRule>> _rulesFuture;
  final Set<int> _confirmedRuleIds = <int>{};

  @override
  void initState() {
    super.initState();
    _rulesFuture = _loadRules();
  }

  Future<List<TradingRule>> _loadRules() async {
    await _ruleRepository.ensureDefaultRules();
    return _ruleRepository.getAllRules();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TradingRule>>(
      future: _rulesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AlertDialog(
            title: Text('加载交易纪律...'),
            content: SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('加载失败'),
            content: Text('${snapshot.error}'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('关闭'),
              ),
            ],
          );
        }

        final rules = snapshot.data ?? <TradingRule>[];
        final requiredRules = rules.where((rule) => rule.required).toList();
        final allConfirmed =
            requiredRules.isNotEmpty &&
            requiredRules.every((rule) => _confirmedRuleIds.contains(rule.id));

        return AlertDialog(
          title: const Text('请确认今日交易纪律'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                final ruleId = rule.id;
                final checked =
                    ruleId != null && _confirmedRuleIds.contains(ruleId);

                return CheckboxListTile(
                  value: checked,
                  title: Text(rule.content),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: ruleId == null
                      ? null
                      : (value) {
                          setState(() {
                            if (value ?? false) {
                              _confirmedRuleIds.add(ruleId);
                            } else {
                              _confirmedRuleIds.remove(ruleId);
                            }
                          });
                        },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: allConfirmed ? null : null,
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: allConfirmed
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }
}
