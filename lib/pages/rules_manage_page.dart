import 'package:flutter/material.dart';

import '../models/trading_rule.dart';
import '../repositories/trading_rule_repository.dart';

class RulesManagePage extends StatefulWidget {
  const RulesManagePage({super.key});

  @override
  State<RulesManagePage> createState() => _RulesManagePageState();
}

class _RulesManagePageState extends State<RulesManagePage> {
  final TradingRuleRepository _repository = TradingRuleRepository();
  late Future<List<TradingRule>> _rulesFuture;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  void _loadRules() {
    _rulesFuture = _repository.getAllRules();
  }

  Future<void> _saveRuleOrder(List<TradingRule> rules) async {
    for (int i = 0; i < rules.length; i++) {
      await _repository.updateRule(rules[i].copyWith(sortOrder: i + 1));
    }
  }

  Future<void> _showRuleDialog({TradingRule? rule}) async {
    final controller = TextEditingController(text: rule?.content ?? '');
    final isNew = rule == null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? '新增原则' : '修改原则'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '原则内容',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      final content = controller.text.trim();
      if (isNew) {
        final maxOrder = await _getMaxSortOrder();
        await _repository.insertRule(
          TradingRule(content: content, sortOrder: maxOrder + 1),
        );
      } else {
        await _repository.updateRule(rule.copyWith(content: content));
      }
      setState(() {
        _loadRules();
      });
    }
  }

  Future<int> _getMaxSortOrder() async {
    final rules = await _repository.getAllRules();
    if (rules.isEmpty) return 0;
    return rules.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b);
  }

  Future<void> _deleteRule(TradingRule rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除原则'),
        content: Text('确定要删除"${rule.content}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true && rule.id != null) {
      await _repository.deleteRule(rule.id!);
      setState(() {
        _loadRules();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('交易原则管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRuleDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TradingRule>>(
        future: _rulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('加载失败：${snapshot.error}'));
          }

          final rules = snapshot.data ?? <TradingRule>[];

          if (rules.isEmpty) {
            return const Center(child: Text('暂无交易原则，点击右下角 + 新增'));
          }

          return ReorderableListView.builder(
            itemCount: rules.length,
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex--;
                }

                final item = rules.removeAt(oldIndex);

                rules.insert(newIndex, item);
              });

              _saveRuleOrder(rules);
            },
            itemBuilder: (context, index) {
              final rule = rules[index];
              return ListTile(
                key: ValueKey(rule.id),
                title: Row(
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(rule.content)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showRuleDialog(rule: rule),
                    ),
                    IconButton(
                      iconSize: 18,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRule(rule),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
