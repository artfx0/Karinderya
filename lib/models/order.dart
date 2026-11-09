import 'app_state.dart';
import 'cart_item.dart';

class Order {
  final String id;
  final String tableNum;
  final OrderKind kind;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final PaymentStatus payStatus;
  final PaymentMethod paymentMethod;
  final String? referenceNumber;
  final String? staffId;
  final String? staffName;
  final bool isVoided;
  final String? voidReason;
  final String? customerName;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.tableNum,
    required this.kind,
    required this.items,
    required this.total,
    required this.status,
    required this.payStatus,
    this.paymentMethod = PaymentMethod.cash,
    this.referenceNumber,
    this.staffId,
    this.staffName,
    this.isVoided = false,
    this.voidReason,
    this.customerName,
    required this.createdAt,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    String? id,
    String? tableNum,
    OrderKind? kind,
    List<CartItem>? items,
    double? total,
    OrderStatus? status,
    PaymentStatus? payStatus,
    PaymentMethod? paymentMethod,
    String? referenceNumber,
    String? staffId,
    String? staffName,
    bool? isVoided,
    String? voidReason,
    String? customerName,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      tableNum: tableNum ?? this.tableNum,
      kind: kind ?? this.kind,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      payStatus: payStatus ?? this.payStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      isVoided: isVoided ?? this.isVoided,
      voidReason: voidReason ?? this.voidReason,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
