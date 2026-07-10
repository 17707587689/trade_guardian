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

  /// 计划买入：单日或开始日期
  final DateTime? plannedBuyDate;

  /// 计划买入结束日期（可选，表示区间）
  final DateTime? plannedBuyEndDate;

  /// 执行相关信息
  final DateTime? executedAt;
  final double? executedBuyPrice;
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

    this.status = TradePlanStatus.draft,

    this.plannedBuyDate,
    this.plannedBuyEndDate,
    this.executedAt,
    this.executedBuyPrice,
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
      'status': status.name,

      'planned_buy_date': plannedBuyDate?.toIso8601String(),
      'planned_buy_end_date': plannedBuyEndDate?.toIso8601String(),

      'executed_at': executedAt?.toIso8601String(),
      'executed_buy_price': executedBuyPrice,
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

      status: TradePlanStatus.values.firstWhere(
        (e) => e.name == map['status'],

        orElse: () => TradePlanStatus.draft,
      ),

      plannedBuyDate: map['planned_buy_date'] != null
          ? DateTime.parse(map['planned_buy_date'])
          : null,
      plannedBuyEndDate: map['planned_buy_end_date'] != null
          ? DateTime.parse(map['planned_buy_end_date'])
          : null,

      executedAt: map['executed_at'] != null
          ? DateTime.parse(map['executed_at'])
          : null,
      executedBuyPrice: map['executed_buy_price'] != null
          ? (map['executed_buy_price'] as num).toDouble()
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
    TradePlanStatus? status,
    DateTime? createdAt,
    DateTime? plannedBuyDate,
    DateTime? plannedBuyEndDate,
    DateTime? executedAt,
    double? executedBuyPrice,
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
      status: status ?? this.status,
      plannedBuyDate: plannedBuyDate ?? this.plannedBuyDate,
      plannedBuyEndDate: plannedBuyEndDate ?? this.plannedBuyEndDate,
      executedAt: executedAt ?? this.executedAt,
      executedBuyPrice: executedBuyPrice ?? this.executedBuyPrice,
      executedPositionRatio:
          executedPositionRatio ?? this.executedPositionRatio,
      executedMatched: executedMatched ?? this.executedMatched,
      executedReturnRate: executedReturnRate ?? this.executedReturnRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TradePlan{id: $id, stockCode: $stockCode, stockName: $stockName, buyPrice: $buyPrice, stopLossPrice: $stopLossPrice, targetPrice: $targetPrice, positionRatio: $positionRatio, reason: $reason, plannedBuyDate: $plannedBuyDate, plannedBuyEndDate: $plannedBuyEndDate, executedAt: $executedAt, executedBuyPrice: $executedBuyPrice, executedPositionRatio: $executedPositionRatio, executedMatched: $executedMatched, executedReturnRate: $executedReturnRate, status: ${status.name}, createdAt: ${createdAt.toIso8601String()}}';
  }
}
