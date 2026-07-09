enum TradePlanStatus { draft, active, completed, cancelled }

class TradePlan {
  final int? id;

  final String stockCode;

  final String stockName;

  final double buyPrice;

  final double stopLossPrice;

  final double targetPrice;

  final double positionRatio;

  final String reason;

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

      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
