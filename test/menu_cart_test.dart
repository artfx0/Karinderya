import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/models/app_state.dart';

void main() {
  group('KarinderyaController Cart & Menu Tests', () {
    late KarinderyaController controller;

    setUp(() {
      controller = KarinderyaController();
    });

    test('Initial dishes loaded and cart is empty', () {
      expect(controller.dishes.isNotEmpty, true);
      expect(controller.cart.isEmpty, true);
      expect(controller.cartTotal, 0.0);
    });

    test('Add dish to cart increments count and calculates total', () {
      final adobo = controller.dishes.firstWhere((d) => d.id == 'dish-1');
      final success = controller.addToCart(adobo);

      expect(success, true);
      expect(controller.cartItemCount, 1);
      expect(controller.cartTotal, 90.0);

      // Add another adobo
      controller.addToCart(adobo);
      expect(controller.cartItemCount, 2);
      expect(controller.cartTotal, 180.0);
    });

    test('Blocked from adding sold out dish', () {
      final soldOutDish = controller.dishes.firstWhere((d) => d.id == 'dish-5');
      final success = controller.addToCart(soldOutDish);
      expect(success, false);
      expect(controller.cart.isEmpty, true);
    });

    test('Start new order resets cart and updates table', () {
      final adobo = controller.dishes.firstWhere((d) => d.id == 'dish-1');
      controller.addToCart(adobo);
      expect(controller.cart.isNotEmpty, true);

      controller.startNewOrder(kind: OrderKind.takeout, tableNum: 'Takeout');
      expect(controller.cart.isEmpty, true);
      expect(controller.activeOrderKind, OrderKind.takeout);
    });
  });
}
