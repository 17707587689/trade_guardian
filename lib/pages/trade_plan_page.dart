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
  late TextEditingController _maxBuyQuantityCtrl;
  late TextEditingController _maxBuyAmountCtrl;
  late TextEditingController _buyConditionCtrl;
  late TextEditingController _reasonCtrl;

  late TextEditingController _sellConditionCtrl;

  late TextEditingController _executionNoteCtrl;

  bool _allowT = false;

  DateTime? _plannedDate;

  DateTime? _executedAt;
  DateTime? _executedSellDate;
  late TextEditingController _executedBuyPriceCtrl;
  late TextEditingController _executedSellPriceCtrl;
  late TextEditingController _executedPositionRatioCtrl;
  late TextEditingController _buyQuantityCtrl;
  late TextEditingController _buyTotalAmountCtrl;
  late TextEditingController _sellTotalAmountCtrl;
  String? _didT;
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
    _maxBuyQuantityCtrl = TextEditingController(
      text: p?.maxBuyQuantity?.toString() ?? '',
    );
    _maxBuyAmountCtrl = TextEditingController(
      text: p?.maxBuyAmount?.toString() ?? '',
    );
    _buyConditionCtrl = TextEditingController(text: p?.buyCondition ?? '');
    _reasonCtrl = TextEditingController(text: p?.reason ?? '');

    _sellConditionCtrl = TextEditingController(text: p?.sellCondition ?? '');

    _allowT = p?.allowT ?? false;

    _plannedDate = p?.plannedDate;

    _executionNoteCtrl = TextEditingController(text: p?.executionNote ?? '');

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
    _buyQuantityCtrl = TextEditingController(
      text: p?.buyQuantity?.toString() ?? '',
    );
    _buyTotalAmountCtrl = TextEditingController(
      text: p?.buyTotalAmount?.toString() ?? '',
    );
    _sellTotalAmountCtrl = TextEditingController(
      text: p?.sellTotalAmount?.toString() ?? '',
    );
    _didT = p?.didT == null ? null : (p!.didT! ? '是' : '否');
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
    _maxBuyQuantityCtrl.dispose();
    _maxBuyAmountCtrl.dispose();
    _buyConditionCtrl.dispose();
    _reasonCtrl.dispose();
    _sellConditionCtrl.dispose();
    _executionNoteCtrl.dispose();
    _executedBuyPriceCtrl.dispose();
    _executedSellPriceCtrl.dispose();
    _executedPositionRatioCtrl.dispose();
    _buyQuantityCtrl.dispose();
    _buyTotalAmountCtrl.dispose();
    _sellTotalAmountCtrl.dispose();
    super.dispose();
  }

  String _requiredLabel(String label) => '* $label';

  /// 通用简约标签样式（14号字，左对齐）
  static const TextStyle _labelStyle = TextStyle(fontSize: 14);

  /// 无星号可选项的 InputDecoration
  InputDecoration _optInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: _labelStyle,
      alignLabelWithHint: true,
    );
  }

  /// 必填项带星号的 InputDecoration
  InputDecoration _reqInput(String label) {
    return InputDecoration(
      labelText: _requiredLabel(label),
      labelStyle: _labelStyle,
      alignLabelWithHint: true,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // 计划制定日期必填校验
    if (_plannedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择计划制定日期')));
      return;
    }

    final buyPrice = double.tryParse(_buyPriceCtrl.text) ?? 0;
    final stopLoss = double.tryParse(_stopLossCtrl.text) ?? 0;
    final target = double.tryParse(_targetPriceCtrl.text) ?? 0;
    final ratio = double.tryParse(_positionRatioCtrl.text) ?? 0;
    final maxBuyQuantity = double.tryParse(_maxBuyQuantityCtrl.text);
    final maxBuyAmount = double.tryParse(_maxBuyAmountCtrl.text);
    final executedBuyPrice = double.tryParse(_executedBuyPriceCtrl.text);
    final executedSellPrice = double.tryParse(_executedSellPriceCtrl.text);
    final executedPosRatio = double.tryParse(_executedPositionRatioCtrl.text);
    final buyQuantity = double.tryParse(_buyQuantityCtrl.text);
    final buyTotalAmount = double.tryParse(_buyTotalAmountCtrl.text);
    final sellTotalAmount = double.tryParse(_sellTotalAmountCtrl.text);
    final didT = _didT == '是' ? true : (_didT == '否' ? false : null);
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
                  buyCondition: _buyConditionCtrl.text,
                  sellCondition: _sellConditionCtrl.text,
                  maxBuyQuantity: maxBuyQuantity,
                  maxBuyAmount: maxBuyAmount,
                  buyQuantity: buyQuantity,
                  buyTotalAmount: buyTotalAmount,
                  sellTotalAmount: sellTotalAmount,
                  didT: didT,
                  allowT: _allowT,
                  executionNote: _executionNoteCtrl.text,
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
              buyCondition: _buyConditionCtrl.text,
              sellCondition: _sellConditionCtrl.text,
              maxBuyQuantity: maxBuyQuantity,
              maxBuyAmount: maxBuyAmount,
              buyQuantity: buyQuantity,
              buyTotalAmount: buyTotalAmount,
              sellTotalAmount: sellTotalAmount,
              didT: didT,
              allowT: _allowT,
              plannedDate: _plannedDate,
              executionNote: _executionNoteCtrl.text,
              status: _status,
              executedAt: _executedAt,
              executedBuyPrice: executedBuyPrice,
              executedSellPrice: executedSellPrice,
              executedSellDate: _executedSellDate,
              executedPositionRatio: executedPosRatio,
              executedReturnRate: executedReturnRate,
              executedMatched: _executedMatched,
              createdAt: widget.plan?.createdAt ?? now,
            );

    try {
      if (newPlan.id == null) {
        await _repository.insertPlan(newPlan);
      } else {
        await _repository.updatePlan(newPlan);
      }
    } catch (e, stack) {
      debugPrint("保存交易计划异常:");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("保存失败:\n$e"),
          duration: const Duration(seconds: 5),
        ),
      );

      return;
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

  String? _optionalNumberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
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
        return '已作废';
    }
  }

  /// 构建多行输入框的单行显示 + ... 展开图标
  Widget _buildMultiLineField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? _requiredLabel(label) : label,
        hintText: hintText ?? (required ? '' : ''),
        labelStyle: _labelStyle,
        alignLabelWithHint: true,
        suffixIcon: _buildSuffixIcon(controller: controller, title: label),
      ),
      maxLines: 1,
      readOnly: true,
      validator: validator,
      onTap: () => _showEditableContent(label, controller),
    );
  }

  /// 显示可编辑内容对话框
  void _showEditableContent(String title, TextEditingController controller) {
    final editingCtrl = TextEditingController(text: controller.text);
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: Text(title),
        content: SizedBox(
          width: screenWidth,
          child: TextField(
            controller: editingCtrl,
            minLines: 3,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
              hintText: '请输入内容',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.text = editingCtrl.text;
              setState(() {});
              Navigator.of(ctx).pop();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 构建展开图标
  Widget? _buildSuffixIcon({
    required TextEditingController controller,
    required String title,
  }) {
    final text = controller.text;
    if (text.isEmpty || !text.contains('\n')) return null;
    return IconButton(
      icon: const Icon(Icons.more_horiz, size: 20),
      onPressed: () => _showEditableContent(title, controller),
      tooltip: '编辑全部内容',
    );
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
              // ===== 计划信息（标题） =====
              const SizedBox(height: 6),
              const Text(
                '计划信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Divider(thickness: 2, height: 1, color: Color(0xFF333333)),
              const SizedBox(height: 4),
              // 股票代码 / 股票名称
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCodeCtrl,
                      decoration: _reqInput('股票代码'),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockNameCtrl,
                      decoration: _reqInput('股票名称'),
                      validator: _requiredValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 买入价格 / 止损价格
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buyPriceCtrl,
                      decoration: _reqInput('买入价格'),
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
                      decoration: _reqInput('止损价格'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _numberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 目标价格 / 仓位比例
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetPriceCtrl,
                      decoration: _reqInput('目标价格'),
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
                      decoration: _reqInput('仓位比例 (0-1)'),
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
              const SizedBox(height: 4),
              // 最大买入数量（手）/ 最大买入金额（元）
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxBuyQuantityCtrl,
                      decoration: _optInput('最大买入数量（手）'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxBuyAmountCtrl,
                      decoration: _optInput('最大买入金额（元）'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 买入条件
              _buildMultiLineField(
                controller: _buyConditionCtrl,
                label: '买入条件',
                hintText: '可输入多行内容',
              ),
              const SizedBox(height: 4),
              // 卖出条件
              _buildMultiLineField(
                controller: _sellConditionCtrl,
                label: '卖出条件',
                hintText: '可输入多行内容',
              ),
              const SizedBox(height: 4),
              // 是否允许做T
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _allowT,
                    onChanged: (v) => setState(() => _allowT = v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _allowT = !_allowT),
                    child: const Text('是否允许做T', style: _labelStyle),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 计划制定日期（必填）
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _plannedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setState(() => _plannedDate = d);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: _requiredLabel('计划制定日期'),
                    labelStyle: _labelStyle,
                  ),
                  child: Text(
                    _plannedDate == null
                        ? '请选择日期'
                        : _plannedDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // 买入理由（多行输入，显示单行）
              _buildMultiLineField(
                controller: _reasonCtrl,
                label: '买入理由',
                required: true,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 6),
              // ===== 执行信息（标题） =====
              const SizedBox(height: 6),
              const Text(
                '执行信息',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Divider(thickness: 2, height: 1, color: Color(0xFF333333)),
              const SizedBox(height: 4),
              // 买入日期 / 卖出日期
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
                        decoration: InputDecoration(
                          labelText: '买入日期',
                          labelStyle: _labelStyle,
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
                        decoration: InputDecoration(
                          labelText: '卖出日期',
                          labelStyle: _labelStyle,
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
              const SizedBox(height: 4),
              // 买入价格 / 卖出价格
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _executedBuyPriceCtrl,
                      decoration: _optInput('买入价格'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _executedSellPriceCtrl,
                      decoration: _optInput('卖出价格'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 买入数量（手）/ 买入总金额（元）
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buyQuantityCtrl,
                      decoration: _optInput('买入数量（手）'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _buyTotalAmountCtrl,
                      decoration: _optInput('买入总金额（元）'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 是否有做T / 卖出总金额（元）
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _didT,
                      decoration: InputDecoration(
                        labelText: '是否有做T',
                        labelStyle: _labelStyle,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '是',
                          child: Text(
                            '是',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '否',
                          child: Text(
                            '否',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _didT = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sellTotalAmountCtrl,
                      decoration: _optInput('卖出总金额（元）'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 仓位 / 收益率
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _executedPositionRatioCtrl,
                      decoration: _optInput('仓位'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '收益率（自动计算）',
                        labelStyle: _labelStyle,
                      ),
                      child: Text(_calculateReturnRateText()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 执行总结（多行输入，显示单行）
              _buildMultiLineField(
                controller: _executionNoteCtrl,
                label: '执行总结',
              ),
              const SizedBox(height: 4),
              // 是否与计划一致
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _executedMatched,
                    onChanged: (v) =>
                        setState(() => _executedMatched = v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _executedMatched = !_executedMatched),
                    child: const Text('是否与计划一致', style: _labelStyle),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 状态
              DropdownButtonFormField<TradePlanStatus>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: '状态',
                  labelStyle: _labelStyle,
                ),
                items: TradePlanStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          _statusLabel(s),
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _status = v ?? TradePlanStatus.draft),
              ),
              const SizedBox(height: 12),
              // 底部按钮
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
