class TradingRule {
  /// 主键
  final int? id;

  /// 规则内容
  final String content;

  /// 排序
  final int sortOrder;

  /// 是否必须确认
  final bool required;

  const TradingRule({
    this.id,
    required this.content,
    required this.sortOrder,
    this.required = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'sort_order': sortOrder,
      'required': required ? 1 : 0,
    };
  }

  factory TradingRule.fromMap(Map<String, dynamic> map) {
    return TradingRule(
      id: map['id'] as int?,
      content: map['content'] as String,
      sortOrder: map['sort_order'] as int,
      required: (map['required'] as int) == 1,
    );
  }
}
