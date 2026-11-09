class ShiftRecord {
  final String cashierId;
  final String cashierName;
  final DateTime startedAt;
  final double startingFloat;
  final double cashSales;
  final double gcashSales;
  final double mayaSales;
  final double utangIssued;
  final double utangCollected;
  final int ordersCount;
  final DateTime? endedAt;
  final double? actualCountedCash;

  const ShiftRecord({
    required this.cashierId,
    required this.cashierName,
    required this.startedAt,
    this.startingFloat = 1000.0,
    this.cashSales = 0.0,
    this.gcashSales = 0.0,
    this.mayaSales = 0.0,
    this.utangIssued = 0.0,
    this.utangCollected = 0.0,
    this.ordersCount = 0,
    this.endedAt,
    this.actualCountedCash,
  });

  bool get isActive => endedAt == null;

  double get expectedCashInDrawer => startingFloat + cashSales + utangCollected;

  double get totalDigitalSales => gcashSales + mayaSales;

  double get totalSales => cashSales + totalDigitalSales + utangIssued;

  double get cashVariance {
    if (actualCountedCash == null) return 0.0;
    return actualCountedCash! - expectedCashInDrawer;
  }

  ShiftRecord copyWith({
    String? cashierId,
    String? cashierName,
    DateTime? startedAt,
    double? startingFloat,
    double? cashSales,
    double? gcashSales,
    double? mayaSales,
    double? utangIssued,
    double? utangCollected,
    int? ordersCount,
    DateTime? endedAt,
    double? actualCountedCash,
  }) {
    return ShiftRecord(
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      startedAt: startedAt ?? this.startedAt,
      startingFloat: startingFloat ?? this.startingFloat,
      cashSales: cashSales ?? this.cashSales,
      gcashSales: gcashSales ?? this.gcashSales,
      mayaSales: mayaSales ?? this.mayaSales,
      utangIssued: utangIssued ?? this.utangIssued,
      utangCollected: utangCollected ?? this.utangCollected,
      ordersCount: ordersCount ?? this.ordersCount,
      endedAt: endedAt ?? this.endedAt,
      actualCountedCash: actualCountedCash ?? this.actualCountedCash,
    );
  }
}
