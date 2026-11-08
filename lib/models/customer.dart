class Customer {
  final String id;
  final String name;
  final double balance;
  final double originalTotal;
  final int openOrders;
  final String date;

  const Customer({
    required this.id,
    required this.name,
    required this.balance,
    required this.originalTotal,
    required this.openOrders,
    required this.date,
  });

  String get avatarInitials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CU';
  }

  double get paymentProgress {
    if (originalTotal <= 0) return 1.0;
    final paid = originalTotal - balance;
    return (paid / originalTotal).clamp(0.0, 1.0);
  }

  bool get isPaidInFull => balance <= 0;

  Customer copyWith({
    String? id,
    String? name,
    double? balance,
    double? originalTotal,
    int? openOrders,
    String? date,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      originalTotal: originalTotal ?? this.originalTotal,
      openOrders: openOrders ?? this.openOrders,
      date: date ?? this.date,
    );
  }
}
