import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/trade_plan.dart';
import '../repositories/trade_plan_repository.dart';

class TradePlanHistoryPage extends StatefulWidget {
  const TradePlanHistoryPage({super.key});

  @override
  State<TradePlanHistoryPage> createState() => _TradePlanHistoryPageState();
}

class _TradePlanHistoryPageState extends State<TradePlanHistoryPage> {
  final TradePlanRepository _repository = TradePlanRepository();

  late Future<List<TradePlan>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = _repository.getAllPlans().then(
      (list) => list.where((p) => p.executedAt != null).toList(),
    );
    setState(() {});
  }

  Future<void> _exportCsv(List<TradePlan> plans) async {
    if (plans.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有执行记录可导出')));
      return;
    }

    final headers = [
      'id',
      'stock_code',
      'stock_name',
      'planned_buy_date',
      'executed_at',
      'executed_buy_price',
      'executed_position_ratio',
      'executed_matched',
      'reason',
    ];

    final rows = <String>[];
    rows.add(headers.join(','));

    for (final p in plans) {
      final row = [
        p.id?.toString() ?? '',
        p.stockCode,
        p.stockName,
        p.plannedBuyDate?.toIso8601String() ?? '',
        p.executedAt?.toIso8601String() ?? '',
        p.executedBuyPrice?.toString() ?? '',
        p.executedPositionRatio?.toString() ?? '',
        (p.executedMatched == true) ? '1' : '0',
        '"${p.reason.replaceAll('"', '""')}"',
      ];
      rows.add(row.join(','));
    }

    final csv = rows.join('\n');

    try {
      // Prefer external storage directory (shared) when available
      final dir = await getExternalStorageDirectory();
      String outPath;

      if (dir != null) {
        final exportDir = Directory(
          path.join(dir.path, '..', '..', 'TradeGuardianExports'),
        );
        if (!await exportDir.exists()) await exportDir.create(recursive: true);
        final fileName =
            'trade_plan_history_${DateTime.now().toIso8601String().split("T")[0]}.csv';
        outPath = path.join(exportDir.path, fileName);
      } else {
        final dbPath = await getDatabasesPath();
        final fileName =
            'trade_plan_history_${DateTime.now().toIso8601String().split("T")[0]}.csv';
        outPath = path.join(dbPath, fileName);
      }

      final file = File(outPath);
      await file.writeAsString(csv);
      // 弹出共享对话框，优先让用户直接分享或保存文件到任意位置
      try {
        await Share.shareFiles([outPath], text: 'TradeGuardian 执行历史导出');
      } catch (_) {
        // 回退到提示文件路径
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导出成功: $outPath')));
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('执行历史')),
      body: FutureBuilder<List<TradePlan>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snapshot.data ?? <TradePlan>[];

          return Column(
            children: [
              Expanded(
                child: plans.isEmpty
                    ? const Center(child: Text('暂无执行记录'))
                    : ListView.separated(
                        itemCount: plans.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final p = plans[index];
                          return ListTile(
                            title: Text('${p.stockCode} ${p.stockName}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '计划: ${p.plannedBuyDate?.toLocal().toString().split(' ')[0] ?? '-'}',
                                ),
                                Text(
                                  '执行: ${p.executedAt?.toLocal().toString().split(' ')[0] ?? '-'}  价格: ${p.executedBuyPrice ?? '-'}  仓位: ${p.executedPositionRatio ?? '-'}',
                                ),
                                Text(
                                  '是否与计划一致: ${p.executedMatched == true ? '是' : '否'}',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          _loadHistory();
                        },
                        child: const Text('刷新'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: plans.isEmpty
                            ? null
                            : () => _exportCsv(plans),
                        child: const Text('导出 CSV'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
