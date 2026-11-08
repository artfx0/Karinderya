import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/models/app_state.dart';
import 'package:karinderya_mobile_application/models/dish.dart';
import 'package:karinderya_mobile_application/models/staff_member.dart';

void main() {
  group('Owner Actions & State Updates', () {
    late KarinderyaController controller;

    setUp(() {
      controller = KarinderyaController();
    });

    test('Update daily goal', () {
      controller.updateDailyGoal(8000.0);
      expect(controller.dailyGoal, 8000.0);
    });

    test('Toggle dish availability and adjust servings/cap', () {
      final dishId = 'dish-1';
      final initialAvailability = controller.dishes.firstWhere((d) => d.id == dishId).isAvailable;

      controller.toggleDishAvailability(dishId);
      expect(controller.dishes.firstWhere((d) => d.id == dishId).isAvailable, !initialAvailability);

      controller.updateDishCap(dishId, 30);
      expect(controller.dishes.firstWhere((d) => d.id == dishId).cap, 30);

      controller.updateDishStock(dishId, 25);
      expect(controller.dishes.firstWhere((d) => d.id == dishId).stock, 25);
    });

    test('Add new dish to menu', () {
      final initialLength = controller.dishes.length;
      controller.addDish(
        const Dish(
          id: 'dish-new',
          name: 'Bicol Express',
          price: 85.0,
          category: DishCategory.ulam,
          stock: 10,
          cap: 10,
          image: 'assets/adobo.svg',
        ),
      );
      expect(controller.dishes.length, initialLength + 1);
      expect(controller.dishes.any((d) => d.name == 'Bicol Express'), true);
    });

    test('Toggle staff shift and add new staff', () {
      final staffId = 'staff-2';
      final initialShift = controller.staff.firstWhere((s) => s.id == staffId).onShift;

      controller.toggleStaffShift(staffId);
      expect(controller.staff.firstWhere((s) => s.id == staffId).onShift, !initialShift);

      controller.addStaff(
        const StaffMember(
          id: 'staff-new',
          name: 'Cardo Dalisay',
          role: UserRole.staff,
          onShift: true,
        ),
      );
      expect(controller.staff.any((s) => s.name == 'Cardo Dalisay'), true);
    });

    test('Settle customer debt with partial and full payment', () {
      final custId = 'cust-1'; // Mang Kanor: 350 balance
      final initialBalance = controller.customers.firstWhere((c) => c.id == custId).balance;

      // Partial payment of 150
      controller.settleCustomerDebt(custId, 150.0);
      expect(controller.customers.firstWhere((c) => c.id == custId).balance, initialBalance - 150.0);

      // Settle remaining 200
      controller.settleCustomerDebt(custId, 200.0);
      final fullyPaidCust = controller.customers.firstWhere((c) => c.id == custId);
      expect(fullyPaidCust.balance, 0.0);
      expect(fullyPaidCust.isPaidInFull, true);
    });
  });
}
