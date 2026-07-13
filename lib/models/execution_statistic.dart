class ExecutionStatistic {
  final int matched;

  final int total;

  const ExecutionStatistic({required this.matched, required this.total});

  String get display {
    if (total == 0) {
      return '0/0 (0%)';
    }

    final rate = (matched / total * 100).round();

    return '$matched/$total ($rate%)';
  }
}
