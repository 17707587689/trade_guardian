enum TradePlanStatus {
  draft,
  pendingeffective,
  executing,
  effective,
  completed,
  cancelled,
}

class TradePlan {
  final int? id;

  final String stockCode;

  final String stockName;

  final double buyPrice;

  final double stopLossPrice;

  final double targetPrice;

  final double positionRatio;

  final String reason;

  /// 买入条件（可选，支持多行文本）
  final String? buyCondition;

  /// 卖出条件（可选，支持多行文本）
  final String? sellCondition;

  /// 最大买入数量（手）
  final double? maxBuyQuantity;

  /// 最大买入金额（元）
  final double? maxBuyAmount;

  /// 执行信息
  final double? buyQuantity;
  final double? buyTotalAmount;
  final double? sellTotalAmount;
  final bool? didT;

  /// 是否允许做T
  final bool allowT;

  /// 计划制定日期
  final DateTime? plannedDate;

  /// 执行补充说明
  final String? executionNote;

  /// 执行相关信息
  final DateTime? executedAt;
  final double? executedBuyPrice;
  final double? executedSellPrice;
  final DateTime? executedSellDate;
  final double? executedPositionRatio;
  final bool? executedMatched;
  final double? executedReturnRate;

  final TradePlanStatus status;

  final DateTime createdAt;

  const TradePlan({
    this.id,

    required this.stockCode,

    required this.stockName,

    required this.buyPrice,

    required this.stopLossPrice,

    required this.targetPrice,

    required this.positionRatio,

    required this.reason,

    this.buyCondition,

    this.sellCondition,

    this.maxBuyQuantity,
    this.maxBuyAmount,
    this.buyQuantity,
    this.buyTotalAmount,
    this.sellTotalAmount,
    this.didT,

    this.allowT = false,

    this.plannedDate,

    this.executionNote,

    this.status = TradePlanStatus.draft,
    this.executedAt,
    this.executedBuyPrice,
    this.executedSellPrice,
    this.executedSellDate,
    this.executedPositionRatio,
    this.executedMatched,
    this.executedReturnRate,

    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'stock_code': stockCode,

      'stock_name': stockName,

      'buy_price': buyPrice,

      'stop_loss_price': stopLossPrice,

      'target_price': targetPrice,

      'position_ratio': positionRatio,

      'reason': reason,
      'buy_condition': buyCondition,
      'sell_condition': sellCondition,

      'max_buy_quantity': maxBuyQuantity,
      'max_buy_amount': maxBuyAmount,
      'buy_quantity': buyQuantity,
      'buy_total_amount': buyTotalAmount,
      'sell_total_amount': sellTotalAmount,
      'did_t': didT == true ? 1 : 0,
      'allow_t': allowT == true ? 1 : 0,

      'planned_date': plannedDate?.toIso8601String(),

      'execution_note': executionNote,
      'status': status.name,

      'executed_at': executedAt?.toIso8601String(),
      'executed_buy_price': executedBuyPrice,
      'executed_sell_price': executedSellPrice,
      'executed_sell_date': executedSellDate?.toIso8601String(),
      'executed_position_ratio': executedPositionRatio,
      'executed_matched': executedMatched == true ? 1 : 0,
      'executed_return_rate': executedReturnRate,

      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TradePlan.fromMap(Map<String, dynamic> map) {
    return TradePlan(
      id: map['id'],

      stockCode: map['stock_code'],

      stockName: map['stock_name'],

      buyPrice: map['buy_price'],

      stopLossPrice: map['stop_loss_price'],

      targetPrice: map['target_price'],

      positionRatio: map['position_ratio'],

      reason: map['reason'],
      buyCondition: map['buy_condition'],
      sellCondition: map['sell_condition'],

      maxBuyQuantity: map['max_buy_quantity'] != null
          ? (map['max_buy_quantity'] as num).toDouble()
          : null,
      maxBuyAmount: map['max_buy_amount'] != null
          ? (map['max_buy_amount'] as num).toDouble()
          : null,
      buyQuantity: map['buy_quantity'] != null
          ? (map['buy_quantity'] as num).toDouble()
          : null,
      buyTotalAmount: map['buy_total_amount'] != null
          ? (map['buy_total_amount'] as num).toDouble()
          : null,
      sellTotalAmount: map['sell_total_amount'] != null
          ? (map['sell_total_amount'] as num).toDouble()
          : null,
      didT: map['did_t'] != null ? (map['did_t'] as int) == 1 : null,
      allowT: map['allow_t'] != null ? (map['allow_t'] as int) == 1 : false,

      plannedDate: map['planned_date'] != null
          ? DateTime.parse(map['planned_date'])
          : null,

      executionNote: map['execution_note'],
      status: TradePlanStatus.values.firstWhere(
        (e) => e.name == map['status'],

        orElse: () => TradePlanStatus.draft,
      ),

      executedAt: map['executed_at'] != null
          ? DateTime.parse(map['executed_at'])
          : null,
      executedBuyPrice: map['executed_buy_price'] != null
          ? (map['executed_buy_price'] as num).toDouble()
          : null,
      executedSellPrice: map['executed_sell_price'] != null
          ? (map['executed_sell_price'] as num).toDouble()
          : null,
      executedSellDate: map['executed_sell_date'] != null
          ? DateTime.parse(map['executed_sell_date'])
          : null,
      executedPositionRatio: map['executed_position_ratio'] != null
          ? (map['executed_position_ratio'] as num).toDouble()
          : null,
      executedMatched: map['executed_matched'] != null
          ? (map['executed_matched'] as int) == 1
          : false,
      executedReturnRate: map['executed_return_rate'] != null
          ? (map['executed_return_rate'] as num).toDouble()
          : null,

      createdAt: DateTime.parse(map['created_at']),
    );
  }

  TradePlan copyWith({
    int? id,
    String? stockCode,
    String? stockName,
    double? buyPrice,
    double? stopLossPrice,
    double? targetPrice,
    double? positionRatio,
    String? reason,
    String? buyCondition,
    String? sellCondition,

    double? maxBuyQuantity,
    double? maxBuyAmount,
    double? buyQuantity,
    double? buyTotalAmount,
    double? sellTotalAmount,
    bool? didT,
    bool? allowT,

    DateTime? plannedDate,

    String? executionNote,
    TradePlanStatus? status,
    DateTime? createdAt,
    DateTime? executedAt,
    double? executedBuyPrice,
    double? executedSellPrice,
    DateTime? executedSellDate,
    double? executedPositionRatio,
    bool? executedMatched,
    double? executedReturnRate,
  }) {
    return TradePlan(
      id: id ?? this.id,
      stockCode: stockCode ?? this.stockCode,
      stockName: stockName ?? this.stockName,
      buyPrice: buyPrice ?? this.buyPrice,
      stopLossPrice: stopLossPrice ?? this.stopLossPrice,
      targetPrice: targetPrice ?? this.targetPrice,
      positionRatio: positionRatio ?? this.positionRatio,
      reason: reason ?? this.reason,
      buyCondition: buyCondition ?? this.buyCondition,
      sellCondition: sellCondition ?? this.sellCondition,

      maxBuyQuantity: maxBuyQuantity ?? this.maxBuyQuantity,
      maxBuyAmount: maxBuyAmount ?? this.maxBuyAmount,
      buyQuantity: buyQuantity ?? this.buyQuantity,
      buyTotalAmount: buyTotalAmount ?? this.buyTotalAmount,
      sellTotalAmount: sellTotalAmount ?? this.sellTotalAmount,
      didT: didT ?? this.didT,
      allowT: allowT ?? this.allowT,

      plannedDate: plannedDate ?? this.plannedDate,

      executionNote: executionNote ?? this.executionNote,
      status: status ?? this.status,
      executedAt: executedAt ?? this.executedAt,
      executedBuyPrice: executedBuyPrice ?? this.executedBuyPrice,
      executedSellPrice: executedSellPrice ?? this.executedSellPrice,
      executedSellDate: executedSellDate ?? this.executedSellDate,
      executedPositionRatio:
          executedPositionRatio ?? this.executedPositionRatio,
      executedMatched: executedMatched ?? this.executedMatched,
      executedReturnRate: executedReturnRate ?? this.executedReturnRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TradePlan{id: $id, stockCode: $stockCode, stockName: $stockName, buyPrice: $buyPrice, stopLossPrice: $stopLossPrice, targetPrice: $targetPrice, positionRatio: $positionRatio, reason: $reason, allowT: $allowT, plannedDate: $plannedDate, executedAt: $executedAt, executedBuyPrice: $executedBuyPrice, executedSellPrice: $executedSellPrice, executedSellDate: $executedSellDate, executedPositionRatio: $executedPositionRatio, executedMatched: $executedMatched, executedReturnRate: $executedReturnRate, status: ${status.name}, createdAt: ${createdAt.toIso8601String()}}';
  }
}
