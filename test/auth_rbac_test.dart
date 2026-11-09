import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/models/app_state.dart';

void main() {
  group('Authentication & RBAC Tests', () {
    late KarinderyaController controller;

    setUp(() {
      controller = KarinderyaController();
    });

    test('Owner credentials automatically resolve to Owner role and screen', () {
      final success = controller.loginWithCredentials('owner@karinderya.ph', 'owner');
      expect(success, true);
      expect(controller.role, UserRole.owner);
      expect(controller.screen, ScreenState.owner);
      expect(controller.currentStaffName, 'Aling Nena');
    });

    test('Staff credentials automatically resolve to Staff role, screen and active shift', () {
      final success = controller.loginWithCredentials('staff@karinderya.ph', 'staff');
      expect(success, true);
      expect(controller.role, UserRole.staff);
      expect(controller.screen, ScreenState.staff);
      expect(controller.currentStaffName, 'Ana Reyes');
      expect(controller.currentShift, isNotNull);
      expect(controller.currentShift!.isActive, true);
      expect(controller.currentShift!.startingFloat, 1000.0);
    });

    test('Invalid credentials return false and remain on login screen', () {
      controller.setScreen(ScreenState.login);
      final success = controller.loginWithCredentials('wrong@karinderya.ph', 'wrongpass');
      expect(success, false);
      expect(controller.screen, ScreenState.login);
    });

    test('Owner PIN validation', () {
      expect(controller.verifyOwnerPin('1234'), true);
      expect(controller.verifyOwnerPin('0000'), false);
      expect(controller.verifyOwnerPin(''), false);
    });

    test('Voiding an order requires Owner PIN and restores dish stock', () {
      // Find a dish and place an order
      final adobo = controller.dishes.firstWhere((d) => d.id == 'dish-1');
      final initialStock = adobo.stock;

      controller.addToCart(adobo);
      controller.completeCashPayment(100.0);

      final placedOrder = controller.orders.first;
      expect(controller.dishes.firstWhere((d) => d.id == 'dish-1').stock, initialStock - 1);

      // Attempt void with wrong PIN
      final failedVoid = controller.voidOrder(
        orderId: placedOrder.id,
        reason: 'Customer cancelled',
        pin: '9999',
      );
      expect(failedVoid, false);
      expect(controller.orders.first.isVoided, false);

      // Void with valid Owner PIN
      final successfulVoid = controller.voidOrder(
        orderId: placedOrder.id,
        reason: 'Customer cancelled',
        pin: '1234',
      );
      expect(successfulVoid, true);
      expect(controller.orders.first.isVoided, true);
      expect(controller.orders.first.voidReason, 'Customer cancelled');

      // Stock must be restored
      expect(controller.dishes.firstWhere((d) => d.id == 'dish-1').stock, initialStock);
    });
  });
}
