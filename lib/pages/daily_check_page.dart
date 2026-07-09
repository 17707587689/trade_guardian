import 'package:flutter/material.dart';

import '../models/trading_rule.dart';
import '../repositories/daily_rule_check_repository.dart';
import '../repositories/trading_rule_repository.dart';
import 'home_page.dart';

class DailyCheckPage extends StatefulWidget {
  const DailyCheckPage({super.key});

  @override
  State<DailyCheckPage> createState() => _DailyCheckPageState();
}

class _DailyCheckPageState extends State<DailyCheckPage> {
  final TradingRuleRepository _ruleRepository = TradingRuleRepository();
  final DailyRuleCheckRepository _checkRepository = DailyRuleCheckRepository();

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

  Future<void> _confirmToday() async {
    await _checkRepository.confirmFor(DateTime.now());

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('每日纪律确认')),
      body: FutureBuilder<List<TradingRule>>(
        future: _rulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('加载交易纪律失败：${snapshot.error}'));
          }

          final rules = snapshot.data ?? <TradingRule>[];
          final requiredRules = rules.where((rule) => rule.required).toList();
          final canConfirm =
              requiredRules.isNotEmpty &&
              requiredRules.every((rule) => _confirmedRuleIds.contains(rule.id));

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '请先阅读并确认今天的交易纪律',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('只有全部确认后，才进入交易计划流程。'),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: rules.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final rule = rules[index];
                        final ruleId = rule.id;
                        final checked =
                            ruleId != null && _confirmedRuleIds.contains(ruleId);

                        return CheckboxListTile(
                          value: checked,
                          title: Text(rule.content),
                          controlAffinity: ListTileControlAffinity.leading,
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canConfirm ? _confirmToday : null,
                      child: const Text('确认今日纪律'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
