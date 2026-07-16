import 'package:flutter/material.dart';

import '../models/trade_plan.dart';
import '../repositories/trade_plan_repository.dart';

import 'trade_plan_page.dart';

class TradePlanManagePage extends StatefulWidget {
  const TradePlanManagePage({
    super.key,
    this.initialStatus,
    this.initialDaysFilter = 0,
  });

  final TradePlanStatus? initialStatus;
  final int initialDaysFilter;

  @override
  State<TradePlanManagePage> createState() => _TradePlanManagePageState();
}

class _TradePlanManagePageState extends State<TradePlanManagePage> {
  final TradePlanRepository _repository = TradePlanRepository();

  late Future<List<TradePlan>> _plansFuture;

  TradePlanStatus? _statusFilter;

  int _daysFilter = 0;
  // 0:全部
  // 7:最近7天
  // 30:最近30天
  // 90:最近90天

  bool _batchMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();

    _statusFilter = widget.initialStatus;
    _daysFilter = widget.initialDaysFilter;

    _loadPlans();
  }

  void _loadPlans() {
    _plansFuture = _repository.getAllPlans();
  }

  String _statusLabel(TradePlanStatus s) {
    switch (s) {
      case TradePlanStatus.draft:
        return "草稿";

      case TradePlanStatus.pendingeffective:
        return "待生效";

      case TradePlanStatus.effective:
        return "生效中";

      case TradePlanStatus.executing:
        return "执行中";

      case TradePlanStatus.completed:
        return "已完成";

      case TradePlanStatus.cancelled:
        return "已作废";
    }
  }

  Future<void> _createPlan() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const TradePlanPage()));

    if (result == true) {
      setState(() {
        _loadPlans();
      });
    }
  }

  List<TradePlan> _filterPlans(List<TradePlan> plans) {
    final now = DateTime.now();

    return plans.where((p) {
      // 状态过滤

      if (_statusFilter != null && p.status != _statusFilter) {
        return false;
      }

      // 时间过滤

      if (_daysFilter > 0) {
        final start = now.subtract(Duration(days: _daysFilter));

        if (p.createdAt.isBefore(start)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _openPlan(TradePlan plan) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => TradePlanPage(plan: plan)));

    if (result == true) {
      setState(() {
        _loadPlans();
      });
    }
  }

  Future<void> _deletePlan(TradePlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
          '确定要删除 "${plan.stockCode} ${plan.stockName}" 吗？\n该操作不可恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.deletePlan(plan.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已删除')));
      setState(() {
        _loadPlans();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }

  Future<void> _batchDelete() async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 条交易计划吗？\n该操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final id in _selectedIds) {
        await _repository.deletePlan(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已删除 ${_selectedIds.length} 条计划')));
      setState(() {
        _selectedIds.clear();
        _batchMode = false;
        _loadPlans();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('批量删除失败: $e')));
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _batchMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleBatchMode() {
    setState(() {
      _batchMode = !_batchMode;
      if (!_batchMode) {
        _selectedIds.clear();
      }
    });
  }

  Widget _buildStatusFilter() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667eea).withAlpha(60)),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<TradePlanStatus?>(
        initialValue: _statusFilter,
        decoration: const InputDecoration(
          labelText: "状态",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text("全部状态")),
          ...TradePlanStatus.values.map(
            (e) => DropdownMenuItem(value: e, child: Text(_statusLabel(e))),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _statusFilter = value;
          });
        },
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667eea).withAlpha(60)),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<int>(
        initialValue: _daysFilter,
        decoration: const InputDecoration(
          labelText: "时间",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: const [
          DropdownMenuItem(value: 0, child: Text("全部时间")),
          DropdownMenuItem(value: 7, child: Text("最近7天")),
          DropdownMenuItem(value: 30, child: Text("最近30天")),
          DropdownMenuItem(value: 90, child: Text("最近90天")),
        ],
        onChanged: (value) {
          setState(() {
            _daysFilter = value ?? 0;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_batchMode ? "已选 ${_selectedIds.length} 项" : "维护交易计划"),
        actions: [
          if (!_batchMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: '批量删除',
              onPressed: _toggleBatchMode,
            ),
          if (_batchMode) ...[
            TextButton(
              onPressed: _selectedIds.isNotEmpty ? _batchDelete : null,
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: '退出批量模式',
              onPressed: _toggleBatchMode,
            ),
          ],
        ],
      ),

      floatingActionButton: _batchMode
          ? null
          : FloatingActionButton(
              onPressed: _createPlan,
              child: const Icon(Icons.add),
            ),

      body: FutureBuilder<List<TradePlan>>(
        future: _plansFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("加载失败：${snapshot.error}"));
          }

          final allPlans = snapshot.data ?? [];

          final plans = _filterPlans(allPlans);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: [
                    Expanded(child: _buildStatusFilter()),

                    const SizedBox(width: 12),

                    Expanded(child: _buildDateFilter()),
                  ],
                ),
              ),

              Expanded(
                child: plans.isEmpty
                    ? const Center(child: Text("暂无交易计划"))
                    : ListView.separated(
                        itemCount: plans.length,

                        separatorBuilder: (_, _) => const Divider(),

                        itemBuilder: (context, index) {
                          final p = plans[index];

                          final date = p.createdAt.toLocal().toString().split(
                            " ",
                          )[0];

                          if (_batchMode) {
                            final isSelected = _selectedIds.contains(p.id);
                            return ListTile(
                              leading: Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelection(p.id!),
                              ),
                              title: Text(
                                "${p.stockCode} ${p.stockName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "制定日期：$date\n"
                                "状态：${_statusLabel(p.status)}",
                              ),
                              onTap: () => _toggleSelection(p.id!),
                            );
                          }

                          return ListTile(
                            title: Text(
                              "${p.stockCode} ${p.stockName}",

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Text(
                              "制定日期：$date\n"
                              "状态：${_statusLabel(p.status)}",
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  tooltip: '删除',
                                  onPressed: () => _deletePlan(p),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),

                            onTap: () => _openPlan(p),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
