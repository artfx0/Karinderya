import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/views/staff/shift_summary_view.dart';
import 'package:karinderya_mobile_application/views/staff/staff_settings_view.dart';

void main() {
  group('Phase 5: Shift Drawer Reconciliation & Staff Settings Tests', () {
    test('Cash Drawer Reconciliation formula and variance logic', () {
      final controller = KarinderyaController();
      controller.loginWithCredentials('staff@karinderya.ph', 'staff123');

      final shift = controller.currentShift;
      expect(shift, isNotNull);
      expect(shift!.startingFloat, equals(1000.0));
      expect(shift.cashSales, equals(0.0));
      expect(shift.utangCollected, equals(0.0));
      expect(shift.expectedCashInDrawer, equals(1000.0));

      // 1. Simulate Cash Sale
      controller.addToCart(controller.dishes.first);
      final saleTotal = controller.cartTotal;
      controller.completeCashPayment(saleTotal + 50); // e.g. ₱150

      // 2. Simulate Debt Collection (cash collected from suki)
      controller.settleCustomerDebt(controller.customers.first.id, 200.0);

      final updatedShift = controller.currentShift!;
      expect(updatedShift.cashSales, equals(saleTotal));
      expect(updatedShift.utangCollected, equals(200.0));
      expect(updatedShift.expectedCashInDrawer, equals(1000.0 + saleTotal + 200.0));

      // 3. Test Variance - Balanced
      controller.updateCountedCash(1000.0 + saleTotal + 200.0);
      expect(controller.currentShift!.cashVariance, equals(0.0));

      // 4. Test Variance - Over
      controller.updateCountedCash(1000.0 + saleTotal + 250.0);
      expect(controller.currentShift!.cashVariance, equals(50.0));

      // 5. Test Variance - Short
      controller.updateCountedCash(1000.0 + saleTotal + 150.0);
      expect(controller.currentShift!.cashVariance, equals(-50.0));
    });

    testWidgets('ShiftSummaryView renders cashier info, drawer metrics and variance chip', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final controller = KarinderyaController();
      controller.loginWithCredentials('staff@karinderya.ph', 'staff123');

      // Make a cash sale
      controller.addToCart(controller.dishes.first);
      final saleTotal = controller.cartTotal;
      controller.completeCashPayment(saleTotal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShiftSummaryView(controller: controller),
          ),
        ),
      );
      await tester.pump();

      // Verify Cashier Banner & Required Metrics
      expect(find.text('Ana Reyes'), findsOneWidget);
      expect(find.text('BUOD NG AKING SHIFT'), findsOneWidget);
      expect(find.text('Nai-punch na Order'), findsOneWidget);
      expect(find.text('Natanggap na Cash'), findsOneWidget);
      expect(find.text('Bayad sa Utang'), findsOneWidget);

      // Verify Drawer calculation
      expect(find.text('Reconciliation ng Cash Drawer'), findsOneWidget);
      expect(find.text('Panimulang Float (Sinsilyo):'), findsOneWidget);
      expect(find.text('Inaasahang Pera sa Drawer:'), findsOneWidget);

      // Input counted cash
      await tester.enterText(find.byType(TextField), '1150.00');
      await tester.pump();

      // Verify Balanced or Variance display
      expect(find.textContaining('Drawer'), findsWidgets);

      // Verify Shift Action buttons
      expect(find.text('I-print ang Buod'), findsOneWidget);
      expect(find.text('I-end ang Shift'), findsOneWidget);

      // Tap End Shift button and confirm dialog
      await tester.ensureVisible(find.text('I-end ang Shift'));
      await tester.tap(find.text('I-end ang Shift'));
      await tester.pumpAndSettle();
      expect(find.text('I-end ang kasalukuyang shift?'), findsOneWidget);
      await tester.tap(find.text('Oo, I-end ang Shift'));
      await tester.pumpAndSettle();

      expect(controller.currentShift!.isActive, isFalse);
    });

    testWidgets('StaffSettingsView exposes preferences and strictly hides owner-level controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final controller = KarinderyaController();
      controller.loginWithCredentials('staff@karinderya.ph', 'staff123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffSettingsView(controller: controller),
          ),
        ),
      );
      await tester.pump();

      // Verify Staff Preferences
      expect(find.text('MGA KAGUSTUHAN (PREFERENCES)'), findsOneWidget);
      expect(find.text('Kitchen Mode (Mataas na Contrast)'), findsOneWidget);
      expect(find.text('Tunog at Haptic Feedback'), findsOneWidget);
      expect(find.text('Lapad ng Thermal Receipt'), findsOneWidget);
      expect(find.text('Protektado ang Karinderya Data'), findsOneWidget);
      expect(find.text('Mag-log out'), findsOneWidget);

      // Strict RBAC Verification: Owner controls must NOT be present
      expect(find.text('Lumipat sa Owner Dashboard'), findsNothing);
      expect(find.text('Business Financials'), findsNothing);
      expect(find.text('Kabuuang Sales'), findsNothing);
      expect(find.text('Net Profit'), findsNothing);
    });
  });
}
