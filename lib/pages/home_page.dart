import 'dart:io';

import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';

import '../models/trade_plan.dart';
import '../models/execution_statistic.dart';
import '../repositories/trade_plan_repository.dart';
import '../widgets/trade_rule_confirm_dialog.dart';

import 'data_manage_page.dart';
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

  String _formatSuccessRate(ExecutionStatistic? statistic) {
    if (statistic == null) {
      return '-';
    }

    if (statistic.total == 0) {
      return '0%(0/0)';
    }

    final rate = (statistic.matched / statistic.total * 100).round();

    return '$rate%(${statistic.matched}/${statistic.total})';
  }

  Widget _buildClickableCountItem(
    String title,
    String value,
    TradePlanStatus status,
    Color color,
    IconData icon,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _openPlanManage(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(color: color.withAlpha(180), fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  '执行成功率',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatisticItem('近7天', _formatSuccessRate(week.data)),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildStatisticItem('近30天', _formatSuccessRate(month.data)),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildStatisticItem('近90天', _formatSuccessRate(quarter.data)),
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
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _openAllPlanManage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TradePlanManagePage()));

    if (!mounted) return;

    _loadPlans();
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

    // 使用 MAIN action + LAUNCHER category 打开应用（支持未运行的应用）
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: 'com.eastmoney.android.berlin',
      );

      await intent.launch();
    } catch (_) {
      debugPrint('使用 MAIN/LAUNCHER 打开东方财富失败，尝试 action_view');

      // 降级方案：使用 action_view（应用已在后台时有效）
      try {
        final fallbackIntent = AndroidIntent(
          action: 'action_view',
          package: 'com.eastmoney.android.berlin',
        );
        await fallbackIntent.launch();
      } catch (e2) {
        debugPrint('打开东方财富失败: $e2');

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('无法打开东方财富: $e2')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          'TradeGuardian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DataManagePage()),
              );
            },
          ),
        ],
      ),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部渐变横幅
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF43e97b).withAlpha(100),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.shield,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '交易守护天使',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '守护交易 · 杜绝冲动交易',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 状态统计卡片
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _buildClickableCountItem(
                          "执行中",
                          homePlans
                              .where(
                                (p) => p.status == TradePlanStatus.executing,
                              )
                              .length
                              .toString(),
                          TradePlanStatus.executing,
                          const Color(0xFFFF6B6B),
                          Icons.play_circle_filled,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildClickableCountItem(
                          "生效中",
                          homePlans
                              .where(
                                (p) => p.status == TradePlanStatus.effective,
                              )
                              .length
                              .toString(),
                          TradePlanStatus.effective,
                          const Color(0xFF4ECDC4),
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildClickableCountItem(
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
                          const Color(0xFFFFA94D),
                          Icons.schedule,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 执行成功率卡片
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

                const SizedBox(height: 20),

                // 管理交易计划按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openAllPlanManage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF667eea).withAlpha(120),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "管理交易计划",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 管理交易原则按钮
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RulesManagePage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: const Color(0xFF764ba2),
                      side: const BorderSide(
                        color: Color(0xFF764ba2),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rule, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "管理交易原则",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 东方财富按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFE74C3C),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFFE74C3C).withAlpha(120),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _openEastMoneyApp,
                    icon: const Icon(Icons.trending_up),
                    label: const Text(
                      "东方财富",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
