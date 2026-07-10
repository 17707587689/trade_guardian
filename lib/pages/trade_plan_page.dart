import 'package:flutter/material.dart';

import '../models/trade_plan.dart';
import '../repositories/trade_plan_repository.dart';

class TradePlanPage extends StatefulWidget {
  const TradePlanPage({super.key, this.plan});

  final TradePlan? plan;

  @override
  State<TradePlanPage> createState() => _TradePlanPageState();
}

class _TradePlanPageState extends State<TradePlanPage> {
  final _formKey = GlobalKey<FormState>();
  final TradePlanRepository _repository = TradePlanRepository();

  late TextEditingController _stockCodeCtrl;
  late TextEditingController _stockNameCtrl;
  late TextEditingController _buyPriceCtrl;
  late TextEditingController _stopLossCtrl;
  late TextEditingController _targetPriceCtrl;
  late TextEditingController _positionRatioCtrl;
  late TextEditingController _reasonCtrl;
  DateTime? _plannedBuyDate;
  DateTime? _plannedBuyEndDate;

  DateTime? _executedAt;
  DateTime? _executedSellDate;
  late TextEditingController _executedBuyPriceCtrl;
  late TextEditingController _executedSellPriceCtrl;
  late TextEditingController _executedPositionRatioCtrl;
  bool _executedMatched = false;

  TradePlanStatus _status = TradePlanStatus.draft;

  @override
  void initState() {
    super.initState();

    final p = widget.plan;
    _stockCodeCtrl = TextEditingController(text: p?.stockCode ?? '');
    _stockNameCtrl = TextEditingController(text: p?.stockName ?? '');
    _buyPriceCtrl = TextEditingController(text: p?.buyPrice.toString() ?? '');
    _stopLossCtrl = TextEditingController(
      text: p?.stopLossPrice.toString() ?? '',
    );
    _targetPriceCtrl = TextEditingController(
      text: p?.targetPrice.toString() ?? '',
    );
    _positionRatioCtrl = TextEditingController(
      text: p?.positionRatio.toString() ?? '',
    );
    _reasonCtrl = TextEditingController(text: p?.reason ?? '');
    _plannedBuyDate = p?.plannedBuyDate;
    _plannedBuyEndDate = p?.plannedBuyEndDate;

    _executedAt = p?.executedAt;
    _executedSellDate = p?.executedSellDate;
    _executedBuyPriceCtrl = TextEditingController(
      text: p?.executedBuyPrice?.toString() ?? '',
    );
    _executedSellPriceCtrl = TextEditingController(
      text: p?.executedSellPrice?.toString() ?? '',
    );
    _executedPositionRatioCtrl = TextEditingController(
      text: p?.executedPositionRatio?.toString() ?? '',
    );
    _executedMatched = p?.executedMatched ?? false;
    _status = p?.status ?? TradePlanStatus.draft;
  }

  @override
  void dispose() {
    _stockCodeCtrl.dispose();
    _stockNameCtrl.dispose();
    _buyPriceCtrl.dispose();
    _stopLossCtrl.dispose();
    _targetPriceCtrl.dispose();
    _positionRatioCtrl.dispose();
    _reasonCtrl.dispose();
    _executedBuyPriceCtrl.dispose();
    _executedSellPriceCtrl.dispose();
    _executedPositionRatioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final buyPrice = double.tryParse(_buyPriceCtrl.text) ?? 0;
    final stopLoss = double.tryParse(_stopLossCtrl.text) ?? 0;
    final target = double.tryParse(_targetPriceCtrl.text) ?? 0;
    final ratio = double.tryParse(_positionRatioCtrl.text) ?? 0;
    final executedBuyPrice = double.tryParse(_executedBuyPriceCtrl.text);
    final executedSellPrice = double.tryParse(_executedSellPriceCtrl.text);
    final executedPosRatio = double.tryParse(_executedPositionRatioCtrl.text);
    final executedReturnRate =
        (executedBuyPrice != null &&
            executedSellPrice != null &&
            executedBuyPrice != 0)
        ? (executedSellPrice - executedBuyPrice) / executedBuyPrice
        : null;

    final now = DateTime.now();

    final newPlan =
        (widget.plan ??
                TradePlan(
                  stockCode: _stockCodeCtrl.text,
                  stockName: _stockNameCtrl.text,
                  buyPrice: buyPrice,
                  stopLossPrice: stopLoss,
                  targetPrice: target,
                  positionRatio: ratio,
                  reason: _reasonCtrl.text,
                  createdAt: now,
                ))
            .copyWith(
              stockCode: _stockCodeCtrl.text,
              stockName: _stockNameCtrl.text,
              buyPrice: buyPrice,
              stopLossPrice: stopLoss,
              targetPrice: target,
              positionRatio: ratio,
              reason: _reasonCtrl.text,
              status: _status,
              plannedBuyDate: _plannedBuyDate,
              plannedBuyEndDate: _plannedBuyEndDate,
              executedAt: _executedAt,
              executedBuyPrice: executedBuyPrice,
              executedSellPrice: executedSellPrice,
              executedSellDate: _executedSellDate,
              executedPositionRatio: executedPosRatio,
              executedReturnRate: executedReturnRate,
              executedMatched: _executedMatched,
              createdAt: widget.plan?.createdAt ?? now,
            );

    if (newPlan.id == null) {
      await _repository.insertPlan(newPlan);
    } else {
      await _repository.updatePlan(newPlan);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String _calculateReturnRateText() {
    final executedBuyPrice = double.tryParse(_executedBuyPriceCtrl.text);
    final executedSellPrice = double.tryParse(_executedSellPriceCtrl.text);
    if (executedBuyPrice == null ||
        executedSellPrice == null ||
        executedBuyPrice == 0) {
      return '-';
    }
    final rate = (executedSellPrice - executedBuyPrice) / executedBuyPrice;
    return rate.toStringAsFixed(4);
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '必填项';
    return null;
  }

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '必填项';
    if (double.tryParse(v) == null) return '请输入数字';
    return null;
  }

  String _statusLabel(TradePlanStatus s) {
    switch (s) {
      case TradePlanStatus.draft:
        return '草稿';
      case TradePlanStatus.pendingeffective:
        return '待生效';
      case TradePlanStatus.executing:
        return '执行中';
      case TradePlanStatus.effective:
        return '生效中';
      case TradePlanStatus.completed:
        return '已完成';
      case TradePlanStatus.cancelled:
        return '已取消';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plan != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑交易计划' : '新建交易计划'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCodeCtrl,
                      decoration: const InputDecoration(labelText: '股票代码'),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockNameCtrl,
                      decoration: const InputDecoration(labelText: '股票名称'),
                      validator: _requiredValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buyPriceCtrl,
                      decoration: const InputDecoration(labelText: '买入价格'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stopLossCtrl,
                      decoration: const InputDecoration(labelText: '止损价格'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetPriceCtrl,
                      decoration: const InputDecoration(labelText: '目标价格'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _positionRatioCtrl,
                      decoration: const InputDecoration(
                        labelText: '仓位比例 (0-1)',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final err = _numberValidator(v);
                        if (err != null) return err;
                        final val = double.tryParse(v!);
                        if (val == null || val < 0 || val > 1) {
                          return '请输入 0 到 1 之间的数';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(labelText: '交易理由'),
                maxLines: 3,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              const Text('计划买入', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _plannedBuyDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _plannedBuyDate = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '计划买入日期（开始）',
                        ),
                        child: Text(
                          _plannedBuyDate == null
                              ? '未设置'
                              : _plannedBuyDate!.toLocal().toString().split(
                                  ' ',
                                )[0],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _plannedBuyEndDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _plannedBuyEndDate = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '计划买入日期（结束，可选）',
                        ),
                        child: Text(
                          _plannedBuyEndDate == null
                              ? '未设置'
                              : _plannedBuyEndDate!.toLocal().toString().split(
                                  ' ',
                                )[0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('执行信息', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _executedAt ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _executedAt = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '实际买入日期（可选）',
                        ),
                        child: Text(
                          _executedAt == null
                              ? '未设置'
                              : _executedAt!.toLocal().toString().split(' ')[0],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _executedSellDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) setState(() => _executedSellDate = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '实际卖出日期（可选）',
                        ),
                        child: Text(
                          _executedSellDate == null
                              ? '未设置'
                              : _executedSellDate!.toLocal().toString().split(
                                  ' ',
                                )[0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _executedBuyPriceCtrl,
                      decoration: const InputDecoration(
                        labelText: '实际买入价格（可选）',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _executedSellPriceCtrl,
                      decoration: const InputDecoration(
                        labelText: '实际卖出价格（可选）',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _executedPositionRatioCtrl,
                      decoration: const InputDecoration(labelText: '实际仓位（可选）'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: '收益率（自动计算）'),
                      child: Text(_calculateReturnRateText()),
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                value: _executedMatched,
                onChanged: (v) => setState(() => _executedMatched = v ?? false),
                title: const Text('是否与计划一致'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TradePlanStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: '状态'),
                items: TradePlanStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabel(s)),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _status = v ?? TradePlanStatus.draft),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('保存并返回'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
