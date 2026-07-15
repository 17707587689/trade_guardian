import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      return '0/0';
    }

    return '${statistic.matched}/${statistic.total}';
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          children: [
            Icon(
              status == TradePlanStatus.executing
                  ? Icons.play_circle_filled
                  : status == TradePlanStatus.effective
                  ? Icons.check_circle
                  : Icons.schedule,
              color: const Color(0xFF7C8DB5),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatisticItem('近7天执行率', _formatSuccessRate(week.data)),
          Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
          _buildStatisticItem('近30天执行率', _formatSuccessRate(month.data)),
          Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
          _buildStatisticItem('近90天执行率', _formatSuccessRate(quarter.data)),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
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

    const platform = MethodChannel('com.example.trade_guardian/app_launcher');

    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前平台不支持打开东方财富')));
      return;
    }

    try {
      final result = await platform.invokeMethod<bool>('launchApp', {
        'package': 'com.eastmoney.android.berlin',
      });
      if (result != true) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('无法打开东方财富，请检查是否已安装')));
      }
    } catch (e) {
      debugPrint('打开东方财富失败: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('无法打开东方财富: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'TradeGuardian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF333333),
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部横幅
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 26,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF7C8DB5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C8DB5).withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.shield,
                          size: 42,
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
                                fontSize: 26,
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

                const SizedBox(height: 14),

                // 状态统计卡片
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 6,
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
                        ),
                      ),
                      const SizedBox(width: 6),
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
                        ),
                      ),
                      const SizedBox(width: 6),
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
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 执行统计卡片
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

                const SizedBox(height: 14),

                // 管理交易计划按钮（缩小版）
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openAllPlanManage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF7C8DB5),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF7C8DB5).withAlpha(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "管理交易计划",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 管理交易原则按钮（缩小版）
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: const Color(0xFF7C8DB5),
                      side: const BorderSide(
                        color: Color(0xFF7C8DB5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rule, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "管理交易原则",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 登陆交易软件按钮（缩小版）
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF7C8DB5),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF7C8DB5).withAlpha(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _openEastMoneyApp,
                    icon: const Icon(Icons.trending_up, size: 18),
                    label: const Text(
                      "登陆交易软件",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 管理后台数据按钮（缩小版）
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DataManagePage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: const Color(0xFF7C8DB5),
                      side: const BorderSide(
                        color: Color(0xFF7C8DB5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.storage, size: 18),
                    label: const Text(
                      "管理后台数据",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
