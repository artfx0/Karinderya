import 'dish.dart';

class CartItem {
  final Dish dish;
  final int quantity;

  const CartItem({
    required this.dish,
    required this.quantity,
  });

  double get lineTotal => dish.price * quantity;

  CartItem copyWith({
    Dish? dish,
    int? quantity,
  }) {
    return CartItem(
      dish: dish ?? this.dish,
      quantity: quantity ?? this.quantity,
    );
  }
}
