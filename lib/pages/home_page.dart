import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/trade_plan.dart';
import '../repositories/trade_plan_repository.dart';
import '../widgets/trade_rule_confirm_dialog.dart';

import 'rules_manage_page.dart';
import 'trade_plan_page.dart';
import 'trade_plan_manage_page.dart';
import 'trade_plan_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TradePlanRepository _repository = TradePlanRepository();

  late Future<List<TradePlan>> _plansFuture;

  @override
  void initState() {
    super.initState();

    _loadPlans();
  }

  void _loadPlans() {
    _plansFuture = _repository.getAllPlans();

    setState(() {});
  }

  String _statusLabel(TradePlanStatus s) {
    switch (s) {
      case TradePlanStatus.draft:
        return '草稿';

      case TradePlanStatus.pendingeffective:
        return '待生效';

      case TradePlanStatus.effective:
        return '生效中';

      case TradePlanStatus.executing:
        return '执行中';

      case TradePlanStatus.completed:
        return '已完成';

      case TradePlanStatus.cancelled:
        return '已取消';
    }
  }

  Color _statusColor(TradePlanStatus status) {
    switch (status) {
      case TradePlanStatus.pendingeffective:
        return Colors.orange;

      case TradePlanStatus.effective:
        return Colors.blue;

      case TradePlanStatus.executing:
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  Widget _buildCountItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _openPlanManage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TradePlanManagePage()));

    _loadPlans();
  }

  Future<void> _openEditor([TradePlan? plan]) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => TradePlanPage(plan: plan)));

    if (result == true) {
      _loadPlans();
    }
  }

  Future<void> _openEastMoneyApp() async {
    final confirmed = await showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (_) {
        return const TradeRuleConfirmDialog();
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前平台不支持直接打开东方财富应用。')));

      return;
    }

    final androidIntent = Uri.parse(
      'intent://#Intent;package=com.eastmoney.android.berlin;end',
    );

    final launched = await launchUrl(
      androidIntent,

      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('打开东方财富失败，请确认已安装该应用。')));
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
                        _buildCountItem("关注计划", homePlans.length.toString()),

                        _buildCountItem(
                          "待生效",
                          homePlans
                              .where(
                                (p) =>
                                    p.status ==
                                    TradePlanStatus.pendingeffective,
                              )
                              .length
                              .toString(),
                        ),

                        _buildCountItem(
                          "执行中",
                          homePlans
                              .where(
                                (p) => p.status == TradePlanStatus.executing,
                              )
                              .length
                              .toString(),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: homePlans.isEmpty
                      ? const Center(child: Text('暂无交易计划'))
                      : ListView.separated(
                          itemCount: homePlans.length,

                          separatorBuilder: (_, _) => const Divider(),

                          itemBuilder: (context, index) {
                            final p = homePlans[index];

                            final plannedLabel = p.plannedBuyDate != null
                                ? p.plannedBuyDate!.toLocal().toString().split(
                                    ' ',
                                  )[0]
                                : p.createdAt.toLocal().toString().split(
                                    ' ',
                                  )[0];

                            final execLabel = p.executedAt != null
                                ? '已执行 ${p.executedAt!.toLocal().toString().split(' ')[0]}'
                                : '';

                            return Card(
                              elevation: 3,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),

                                title: Text(
                                  '${p.stockCode} ${p.stockName}',

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,

                                    fontSize: 18,
                                  ),
                                ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),

                                  child: Text(
                                    '制定日期：${p.createdAt.toLocal().toString().split(" ")[0]}',
                                  ),
                                ),

                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      p.status,
                                    ).withOpacity(0.15),

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    _statusLabel(p.status),

                                    style: TextStyle(
                                      color: _statusColor(p.status),

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                onTap: () => _openEditor(p),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _openPlanManage,
                  child: const Text("维护交易计划"),
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
