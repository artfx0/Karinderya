import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/views/staff/order_history_view.dart';
import 'package:karinderya_mobile_application/views/widgets/owner_pin_modal.dart';
import 'package:karinderya_mobile_application/views/widgets/receipt_preview_modal.dart';

void main() {
  testWidgets('Order History renders search, payment filters, and itemized orders', (WidgetTester tester) async {
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
          body: OrderHistoryView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // Verify Title & Filter Chips
    expect(find.text('Kasaysayan ng Order'), findsOneWidget);
    expect(find.text('Lahat'), findsOneWidget);
    expect(find.text('Cash'), findsWidgets);
    expect(find.text('GCash'), findsWidgets);
    expect(find.text('Maya'), findsWidgets);
    expect(find.text('Utang'), findsWidgets);
    expect(find.text('Voided'), findsWidgets);

    // Filter by GCash
    await tester.tap(find.text('GCash').first);
    await tester.pump();

    // Search for non-existent order
    await tester.enterText(find.byType(TextField), 'NONEXISTENT_QUERY_999');
    await tester.pump();
    expect(find.text('Walang natagpuang order'), findsOneWidget);
  });

  testWidgets('Voiding order requires Owner PIN (1234) and rejects invalid PINs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('staff@karinderya.ph', 'staff123');

    // Add and pay for an order
    final dish = controller.dishes.first;
    final initialStock = dish.stock;
    controller.addToCart(dish);
    controller.completeCashPayment(500.0);

    final completedOrder = controller.orders.first;
    expect(controller.dishes.first.stock, equals(initialStock - 1));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OwnerPinModal(
            controller: controller,
            order: completedOrder,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify Owner PIN modal header
    expect(find.text('Kailangan ng Owner PIN'), findsOneWidget);

    // 1. Enter Wrong PIN: 9 9 9 9
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(ElevatedButton, '9'));
      await tester.pump();
    }

    // Verify Error message
    expect(find.textContaining('Maling Owner PIN'), findsOneWidget);
    expect(controller.orders.first.isVoided, isFalse);
    expect(controller.dishes.first.stock, equals(initialStock - 1)); // Stock not restored yet

    // 2. Enter Correct PIN: 1 2 3 4
    await tester.tap(find.widgetWithText(ElevatedButton, '1'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '2'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '3'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '4'));
    await tester.pump();

    // Verify Order is now VOIDED and dish stock restored
    expect(controller.orders.first.isVoided, isTrue);
    expect(controller.dishes.first.stock, equals(initialStock));
  });

  testWidgets('Reprinting receipt for voided order shows void warning banner', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('staff@karinderya.ph', 'staff123');

    // Add and pay
    controller.addToCart(controller.dishes.first);
    controller.completeCashPayment(200.0);

    final order = controller.orders.first;
    // Void with correct Owner PIN
    controller.voidOrder(orderId: order.id, reason: 'Maling ulam ang na-punch', pin: '1234');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceiptPreviewModal(
            controller: controller,
            order: controller.orders.first,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify Thermal slip shows VOID watermark
    expect(find.textContaining('*** ORDER NA-VOID ***'), findsOneWidget);
    expect(find.textContaining('Maling ulam ang na-punch'), findsOneWidget);
  });
}
