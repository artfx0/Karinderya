import 'app_state.dart';

class Dish {
  final String id;
  final String name;
  final double price;
  final DishCategory category;
  final int stock;
  final int cap;
  final String image;
  final bool isAvailable;

  const Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.cap,
    required this.image,
    this.isAvailable = true,
  });

  bool get isSoldOut => !isAvailable || stock <= 0;

  double get stockRatio => cap > 0 ? (stock / cap).clamp(0.0, 1.0) : 0.0;

  Dish copyWith({
    String? id,
    String? name,
    double? price,
    DishCategory? category,
    int? stock,
    int? cap,
    String? image,
    bool? isAvailable,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      cap: cap ?? this.cap,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
