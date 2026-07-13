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

  /// 买入条件
  final String? buyCondition1;
  final String? buyCondition2;
  final String? buyCondition3;

  /// 卖出条件
  final String? sellCondition1;
  final String? sellCondition2;
  final String? sellCondition3;

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

    this.buyCondition1,
    this.buyCondition2,
    this.buyCondition3,

    this.sellCondition1,
    this.sellCondition2,
    this.sellCondition3,

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
      'buy_condition_1': buyCondition1,
      'buy_condition_2': buyCondition2,
      'buy_condition_3': buyCondition3,

      'sell_condition_1': sellCondition1,
      'sell_condition_2': sellCondition2,
      'sell_condition_3': sellCondition3,

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
      buyCondition1: map['buy_condition_1'],
      buyCondition2: map['buy_condition_2'],
      buyCondition3: map['buy_condition_3'],

      sellCondition1: map['sell_condition_1'],
      sellCondition2: map['sell_condition_2'],
      sellCondition3: map['sell_condition_3'],

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
    String? buyCondition1,
    String? buyCondition2,
    String? buyCondition3,

    String? sellCondition1,
    String? sellCondition2,
    String? sellCondition3,

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
      buyCondition1: buyCondition1 ?? this.buyCondition1,
      buyCondition2: buyCondition2 ?? this.buyCondition2,
      buyCondition3: buyCondition3 ?? this.buyCondition3,

      sellCondition1: sellCondition1 ?? this.sellCondition1,
      sellCondition2: sellCondition2 ?? this.sellCondition2,
      sellCondition3: sellCondition3 ?? this.sellCondition3,

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
