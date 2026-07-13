import 'package:flutter/material.dart';

import '../models/trading_rule.dart';
import '../repositories/trading_rule_repository.dart';

class TradeRuleConfirmDialog extends StatefulWidget {
  final bool showEastMoneyButton;

  final bool cancelEnabled;

  const TradeRuleConfirmDialog({
    super.key,

    this.showEastMoneyButton = true,

    this.cancelEnabled = true,
  });

  @override
  State<TradeRuleConfirmDialog> createState() => _TradeRuleConfirmDialogState();
}

class _TradeRuleConfirmDialogState extends State<TradeRuleConfirmDialog> {
  final TradingRuleRepository _repository = TradingRuleRepository();

  late Future<List<TradingRule>> _rulesFuture;

  List<bool> checkedList = [];

  @override
  void initState() {
    super.initState();

    _rulesFuture = _repository.getAllRules();
  }

  bool get allChecked {
    if (checkedList.isEmpty) {
      return false;
    }

    return checkedList.every((element) => element);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("交易原则确认"),

      content: SizedBox(
        width: double.maxFinite,

        height: 450,

        child: FutureBuilder<List<TradingRule>>(
          future: _rulesFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text("加载交易原则失败：${snapshot.error}");
            }

            final rules = snapshot.data ?? [];

            if (rules.isEmpty) {
              return const Center(child: Text("暂无交易原则，请先管理交易原则"));
            }

            if (checkedList.length != rules.length) {
              checkedList = List.generate(rules.length, (_) => false);
            }

            return Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "请逐条确认以下交易原则",

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: rules.length,

                    itemBuilder: (context, index) {
                      final rule = rules[index];

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,

                        title: Text("${index + 1}. ${rule.content}"),

                        value: checkedList[index],

                        onChanged: (value) {
                          setState(() {
                            checkedList[index] = value ?? false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),

      actions: [
        if (widget.cancelEnabled)
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },

            child: const Text('取消'),
          ),

        ElevatedButton(
          onPressed: allChecked
              ? () {
                  Navigator.pop(context, true);
                }
              : null,

          child: Text(widget.showEastMoneyButton ? '进入东方财富' : '确认'),
        ),
      ],
    );
  }
}
