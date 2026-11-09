import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/models/app_state.dart';
import 'package:karinderya_mobile_application/views/sheets/checkout_sheet.dart';
import 'package:karinderya_mobile_application/views/success/success_view.dart';
import 'package:karinderya_mobile_application/views/widgets/receipt_preview_modal.dart';

void main() {
  testWidgets('CheckoutSheet renders all 4 payment methods (Cash, GCash, Maya, Utang)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('staff@karinderya.ph', 'staff123');
    // Add dish to cart
    controller.addToCart(controller.dishes.first);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CheckoutSheet(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // Verify all 4 payment options are visible
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('GCash'), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Utang'), findsOneWidget);
  });

  test('Digital Payment flow updates shift records and creates order with ref number', () {
    final controller = KarinderyaController();
    controller.loginWithCredentials('staff@karinderya.ph', 'staff123');

    final dish = controller.dishes.first;
    final initialStock = dish.stock;
    controller.addToCart(dish);
    final orderTotal = controller.cartTotal;

    // Complete payment using GCash
    controller.completeDigitalPayment(
      method: PaymentMethod.gcash,
      referenceNumber: 'GCASH-REF-998877',
    );

    // Verify inventory deducted
    expect(controller.dishes.first.stock, equals(initialStock - 1));

    // Verify order created
    expect(controller.orders.first.paymentMethod, equals(PaymentMethod.gcash));
    expect(controller.orders.first.referenceNumber, equals('GCASH-REF-998877'));
    expect(controller.orders.first.total, equals(orderTotal));
    expect(controller.screen, equals(ScreenState.success));

    // Verify shift record updated
    expect(controller.currentShift?.gcashSales, equals(orderTotal));
    expect(controller.currentShift?.ordersCount, equals(1));
  });

  testWidgets('SuccessView displays "I-print ang Resibo" button and opens thermal slip modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('staff@karinderya.ph', 'staff123');
    controller.addToCart(controller.dishes.first);
    controller.completeDigitalPayment(
      method: PaymentMethod.gcash,
      referenceNumber: 'GCASH-771122',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SuccessView(controller: controller),
      ),
    );
    await tester.pump();

    // Verify "Salamat po!" and "I-print ang Resibo" button
    expect(find.text('Salamat po!'), findsOneWidget);
    expect(find.text('I-print ang Resibo'), findsOneWidget);
    expect(find.textContaining('Bagong Order'), findsOneWidget);

    // Tap "I-print ang Resibo"
    await tester.tap(find.text('I-print ang Resibo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Thermal Receipt Modal opened
    expect(find.byType(ReceiptPreviewModal), findsOneWidget);
    expect(find.text('KARINDERYA NI ALING NENA'), findsOneWidget);
    expect(find.text('I-print sa Thermal Printer'), findsOneWidget);
  });
}
