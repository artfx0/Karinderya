import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/views/owner/owner_dashboard_view.dart';

void main() {
  test('Phase 3 Unit: Controller filters sales and top dish reactively by selected date', () {
    final controller = KarinderyaController();
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);

    // Today's seeded totals: 110 + 240 + 290 + 220 = 860 (Cash = 400)
    expect(controller.isSelectedSalesDateToday, isTrue);
    expect(controller.ordersForSelectedDate.length, 4);
    expect(controller.totalSalesForSelectedDate, 860.0);
    expect(controller.cashSalesForSelectedDate, 400.0);

    // Select yesterday: #1035 (460 cash) + #1034 (290 maya) = 750
    controller.setSalesDate(yesterday);
    expect(controller.isSelectedSalesDateToday, isFalse);
    expect(controller.ordersForSelectedDate.length, 2);
    expect(controller.totalSalesForSelectedDate, 750.0);
    expect(controller.cashSalesForSelectedDate, 460.0);

    // Select 2 days ago: #1031 (550 gcash) + #1030 (150 utang) = 700
    controller.setSalesDate(twoDaysAgo);
    expect(controller.ordersForSelectedDate.length, 2);
    expect(controller.totalSalesForSelectedDate, 700.0);
    expect(controller.cashSalesForSelectedDate, 0.0);
  });

  testWidgets('Phase 3 Widget: Reactive Calendar updates sales immediately without Apply/Submit button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('owner@karinderya.ph', 'owner123');

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => OwnerDashboardView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // Initially displays Today's sales (₱860)
    expect(find.text('₱860'), findsOneWidget);

    // Open calendar sheet
    await tester.tap(find.byIcon(Icons.calendar_month));
    await tester.pumpAndSettle();

    // Verify CalendarDatePicker exists and ZERO Apply/Submit/Enter/OK buttons
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Enter'), findsNothing);
    expect(find.text('OK'), findsNothing);

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (yesterday.month != now.month) {
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
    }

    // Tap yesterday's day cell -> sheet closes & updates immediately to ₱750
    await tester.tap(find.text('${yesterday.day}').first);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsNothing);
    expect(find.text('₱750'), findsOneWidget);
    expect(find.text('2 orders recorded'), findsOneWidget);

    // Tap quick "Today" reset button -> back to ₱860
    await tester.tap(find.widgetWithText(TextButton, 'Today'));
    await tester.pumpAndSettle();
    expect(find.text('₱860'), findsOneWidget);
  });
}
