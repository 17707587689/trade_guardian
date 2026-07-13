import 'dart:io';

import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';

import '../models/trade_plan.dart';
import '../models/execution_statistic.dart';
import '../repositories/trade_plan_repository.dart';
import '../widgets/trade_rule_confirm_dialog.dart';

import 'rules_manage_page.dart';
import 'trade_plan_manage_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TradePlanRepository _repository = TradePlanRepository();

  late Future<List<TradePlan>> _plansFuture;
  late Future<ExecutionStatistic> _weekStatistic;

  late Future<ExecutionStatistic> _monthStatistic;

  late Future<ExecutionStatistic> _quarterStatistic;
  @override
  void initState() {
    super.initState();

    _loadPlans();
    _loadStatistics();
  }

  void _loadPlans() {
    _plansFuture = _repository.getAllPlans();

    setState(() {});
  }

  void _loadStatistics() {
    _weekStatistic = _repository.getExecutionStatistic(const Duration(days: 7));

    _monthStatistic = _repository.getExecutionStatistic(
      const Duration(days: 30),
    );

    _quarterStatistic = _repository.getExecutionStatistic(
      const Duration(days: 90),
    );
  }

  Widget _buildClickableCountItem(
    String title,
    String value,
    TradePlanStatus status,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: () {
        _openPlanManage(status);
      },

      child: Padding(
        padding: const EdgeInsets.all(8),

        child: Column(
          children: [
            Text(
              value,

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionCard(
    AsyncSnapshot<ExecutionStatistic> week,
    AsyncSnapshot<ExecutionStatistic> month,
    AsyncSnapshot<ExecutionStatistic> quarter,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            const Text(
              '按计划执行',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                _buildStatisticItem('近7天', week.data?.display ?? '-'),

                _buildStatisticItem('近30天', month.data?.display ?? '-'),

                _buildStatisticItem('近90天', quarter.data?.display ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _openPlanManage(TradePlanStatus status) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TradePlanManagePage(initialStatus: status),
      ),
    );

    if (!mounted) return;

    _loadPlans();
  }

  Future<void> _openAllPlanManage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TradePlanManagePage()));

    if (!mounted) return;

    _loadPlans();
  }

  Future<void> _openEastMoneyApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const TradeRuleConfirmDialog(showEastMoneyButton: false);
      },
    );
    if (!mounted) return;
    if (confirmed != true) {
      return;
    }

    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前平台不支持打开东方财富')));
      return;
    }

    try {
      final intent = AndroidIntent(
        componentName: 'com.eastmoney.android.berlin.activity.MainActivity',
      );

      await intent.launch();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('无法打开东方财富，请确认已安装东方财富APP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TradeGuardian')),

      body: FutureBuilder<List<TradePlan>>(
        future: _plansFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snapshot.data ?? <TradePlan>[];
          final homePlans = plans
              .where(
                (p) =>
                    p.status == TradePlanStatus.pendingeffective ||
                    p.status == TradePlanStatus.effective ||
                    p.status == TradePlanStatus.executing,
              )
              .toList();
          return Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                  ),

                  child: const Column(
                    children: [
                      Icon(Icons.shield, size: 48, color: Colors.white),

                      SizedBox(height: 8),

                      Text(
                        '交易守护天使',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        '守护交易 · 杜绝冲动交易',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Card(
                  elevation: 2,

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        _buildClickableCountItem(
                          "执行中",

                          homePlans
                              .where(
                                (p) => p.status == TradePlanStatus.executing,
                              )
                              .length
                              .toString(),

                          TradePlanStatus.executing,
                        ),

                        _buildClickableCountItem(
                          "生效中",

                          homePlans
                              .where(
                                (p) => p.status == TradePlanStatus.effective,
                              )
                              .length
                              .toString(),

                          TradePlanStatus.effective,
                        ),

                        _buildClickableCountItem(
                          "待生效",

                          homePlans
                              .where(
                                (p) =>
                                    p.status ==
                                    TradePlanStatus.pendingeffective,
                              )
                              .length
                              .toString(),

                          TradePlanStatus.pendingeffective,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder(
                  future: _weekStatistic,

                  builder: (context, weekSnapshot) {
                    return FutureBuilder(
                      future: _monthStatistic,

                      builder: (context, monthSnapshot) {
                        return FutureBuilder(
                          future: _quarterStatistic,

                          builder: (context, quarterSnapshot) {
                            return _buildExecutionCard(
                              weekSnapshot,
                              monthSnapshot,
                              quarterSnapshot,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Spacer(),
                ElevatedButton(
                  onPressed: _openAllPlanManage,
                  child: const Text("管理交易计划"),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RulesManagePage(),
                      ),
                    );
                  },
                  child: const Text("管理交易原则"),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: _openEastMoneyApp,

                    icon: const Icon(Icons.trending_up),

                    label: const Text("东方财富", style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
