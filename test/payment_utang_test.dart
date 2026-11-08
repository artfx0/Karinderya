import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/models/app_state.dart';

void main() {
  group('Cash Payment & Utang Recording Tests', () {
    late KarinderyaController controller;

    setUp(() {
      controller = KarinderyaController();
    });

    test('Cash payment with change reduces stock, clears cart, and creates order', () {
      final adobo = controller.dishes.firstWhere((d) => d.id == 'dish-1');
      final initialStock = adobo.stock;

      controller.addToCart(adobo); // 90
      expect(controller.cartTotal, 90.0);

      // Pay with 100
      controller.completeCashPayment(100.0);

      expect(controller.screen, ScreenState.success);
      expect(controller.lastTotalPaid, 90.0);
      expect(controller.lastChange, 10.0);
      expect(controller.cart.isEmpty, true);

      // Verify stock was reduced
      final updatedAdobo = controller.dishes.firstWhere((d) => d.id == 'dish-1');
      expect(updatedAdobo.stock, initialStock - 1);

      // Verify new order in orders list
      expect(controller.orders.first.payStatus, PaymentStatus.paid);
      expect(controller.orders.first.total, 90.0);
    });

    test('Record Utang updates customer balance and creates On debt order', () {
      final rice = controller.dishes.firstWhere((d) => d.id == 'dish-4');
      controller.addToCart(rice); // 20
      controller.addToCart(rice); // 20 -> total 40

      final initialBalance = controller.customers.firstWhere((c) => c.name == 'Ate Gina').balance;

      final success = controller.recordUtang('Ate Gina');
      expect(success, true);
      expect(controller.cart.isEmpty, true);

      // Check customer balance increased by 40
      final updatedCustomer = controller.customers.firstWhere((c) => c.name == 'Ate Gina');
      expect(updatedCustomer.balance, initialBalance + 40.0);

      // Check order
      expect(controller.orders.first.payStatus, PaymentStatus.onDebt);
      expect(controller.orders.first.customerName, 'Ate Gina');
    });

    test('Record Utang for brand new customer adds new record to customers list', () {
      final lumpia = controller.dishes.firstWhere((d) => d.id == 'dish-3');
      controller.addToCart(lumpia); // 60

      final initialCount = controller.customers.length;
      final success = controller.recordUtang('Kapitan Mario');

      expect(success, true);
      expect(controller.customers.length, initialCount + 1);

      final newCust = controller.customers.firstWhere((c) => c.name == 'Kapitan Mario');
      expect(newCust.balance, 60.0);
      expect(newCust.avatarInitials, 'KM');
    });
  });
}
