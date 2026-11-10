import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/views/owner/owner_dashboard_view.dart';

void main() {
  testWidgets('Phase 5 Staff: Real-time employee search filters staff directory by name',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('owner@karinderya.ph', 'owner123');
    controller.setOwnerTabIndex(2); // Staff tab

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => OwnerDashboardView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // All 3 staff rendered initially
    expect(find.text('Aling Nena'), findsOneWidget);
    expect(find.text('Ana Reyes'), findsOneWidget);
    expect(find.text('Benjie Santos'), findsOneWidget);

    // Search by name in real time
    await tester.enterText(
      find.widgetWithText(TextField, 'Maghanap ng pangalan ng kawani...'),
      'Benjie',
    );
    await tester.pumpAndSettle();

    expect(find.text('Benjie Santos'), findsOneWidget);
    expect(find.text('Aling Nena'), findsNothing);
    expect(find.text('Ana Reyes'), findsNothing);

    // Clear search restores full directory
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('Aling Nena'), findsOneWidget);
    expect(find.text('Ana Reyes'), findsOneWidget);
  });

  testWidgets('Phase 5 Utang: Debtor search, auto-clear settled debts, and Add Debtor flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('owner@karinderya.ph', 'owner123');
    controller.setOwnerTabIndex(3); // Utang tab

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => OwnerDashboardView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // 1. Settled seed customer (Kuya Jojo, balance 0) must NOT appear
    expect(find.text('Kuya Jojo'), findsNothing);
    expect(find.text('Mang Kanor'), findsOneWidget);
    expect(find.text('Ate Gina'), findsOneWidget);
    expect(find.text('Tito Boy'), findsOneWidget);

    // 2. Real-time Debtor Search
    final searchField = find.widgetWithText(TextField, 'Maghanap ng may utang o contact info...');
    await tester.enterText(searchField, 'Tito');
    await tester.pumpAndSettle();
    expect(find.text('Tito Boy'), findsOneWidget);
    expect(find.text('Mang Kanor'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    // 3. Auto-clear settled debt immediately upon full payment
    await tester.tap(find.text('Ate Gina'));
    await tester.pumpAndSettle();
    expect(find.text('Mag-record ng Bayad'), findsOneWidget);

    await tester.tap(find.text('I-record ang Bayad'));
    await tester.pumpAndSettle();

    // Ate Gina immediately disappears from the active list
    expect(find.text('Ate Gina'), findsNothing);
    expect(controller.activeDebtors.any((c) => c.name == 'Ate Gina'), isFalse);

    // Wait for payment SnackBar to dismiss cleanly
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 4. Add Debtor Flow via FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Magdagdag ng Bagong May Utang'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Pangalan (Name)'), 'Mang Tomas');
    await tester.enterText(
      find.widgetWithText(TextField, 'Contact Information (Phone / Address)'),
      '0917-999-1122',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Initial Debt Amount'), '450');
    await tester.tap(find.text('I-save ang Debtor'));
    await tester.pumpAndSettle();

    // Newly added debtor immediately appears in active Utang list
    expect(find.text('Mang Tomas'), findsOneWidget);
    expect(find.text('0917-999-1122'), findsOneWidget);
    expect(find.text('₱450'), findsOneWidget);
  });
}
