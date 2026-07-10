import 'package:flutter/material.dart';

import '../models/trade_plan.dart';
import '../repositories/trade_plan_repository.dart';
import 'rules_manage_page.dart';
import 'trade_plan_page.dart';
import 'trade_plan_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TradePlanRepository _repository = TradePlanRepository();

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

  Future<void> _openEditor([TradePlan? plan]) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => TradePlanPage(plan: plan)));

    if (result == true) {
      _loadPlans();
    }
  }

  Future<void> _deletePlan(int id) async {
    await _repository.deletePlan(id);
    _loadPlans();
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    '交易守护天使',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('守护交易，杜绝一切冲动交易', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: plans.isEmpty
                      ? const Center(child: Text('暂无交易计划'))
                      : ListView.separated(
                          itemCount: plans.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final p = plans[index];
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

                            return ListTile(
                              title: Text('${p.stockCode} ${p.stockName}'),
                              subtitle: Text(
                                '计划 $plannedLabel · 目标 ${p.targetPrice} · ${_statusLabel(p.status)} ${execLabel.isEmpty ? '' : '· $execLabel'}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: p.id == null
                                    ? null
                                    : () => _deletePlan(p.id!),
                              ),
                              onTap: () => _openEditor(p),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openEditor(),
                        child: const Text('新建交易计划'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RulesManagePage(),
                            ),
                          );
                        },
                        child: const Text('管理交易纪律'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TradePlanHistoryPage(),
                            ),
                          );
                        },
                        child: const Text('执行历史'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Container()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
