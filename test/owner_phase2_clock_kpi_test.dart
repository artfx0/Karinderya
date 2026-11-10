import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/views/owner/owner_dashboard_view.dart';
import 'package:karinderya_mobile_application/views/owner/sales_detail_report_view.dart';
import 'package:karinderya_mobile_application/views/widgets/dashboard_live_clock.dart';

void main() {
  testWidgets('Phase 2: Body Live Digital Clock excludes date/location and KPI cards navigate cleanly',
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

    // 1. Live Clock must be inside main body (DashboardLiveClock present inside SalesTabView)
    final clockFinder = find.byType(DashboardLiveClock);
    expect(clockFinder, findsOneWidget);

    // Check clock displays hh:mm AM/PM and excludes date and location
    final clockTextWidgets = find.descendant(
      of: clockFinder,
      matching: find.byType(Text),
    );
    final clockStrings = clockTextWidgets.evaluate().map((e) => (e.widget as Text).data ?? '').join(' ');
    expect(RegExp(r'\b\d{1,2}:\d{2}\s(AM|PM)\b').hasMatch(clockStrings), isTrue);
    expect(clockStrings.contains('PST'), isFalse);
    expect(clockStrings.contains('2026'), isFalse);
    expect(clockStrings.contains('Manila'), isFalse);
    expect(clockStrings.contains('Philippines'), isFalse);

    // 2. Tap Today's sales KPI -> navigates to SalesDetailReportView
    await tester.tap(find.text("Today's sales"));
    await tester.pumpAndSettle();
    expect(find.byType(SalesDetailReportView), findsOneWidget);
    expect(find.text('Detalye ng Benta (Sales Report)'), findsOneWidget);

    // Navigate back
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SalesDetailReportView), findsNothing);

    // 3. Tap Cash Sales KPI -> navigates to Cash Sales Report
    await tester.ensureVisible(find.text('Cash Sales'));
    await tester.tap(find.text('Cash Sales'));
    await tester.pumpAndSettle();
    expect(find.byType(SalesDetailReportView), findsOneWidget);
    expect(find.text('Cash Sales Report'), findsOneWidget);

    // Navigate back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Tap Active Utang KPI -> switches to Tab 3 (Utang)
    await tester.ensureVisible(find.text('Active Utang'));
    await tester.tap(find.text('Active Utang'));
    await tester.pumpAndSettle();
    expect(controller.ownerTabIndex, 3);

    // Switch back to Sales tab (0)
    controller.setOwnerTabIndex(0);
    await tester.pumpAndSettle();

    // 5. Tap Inventory Alert KPI -> switches to Tab 1 (Menu Setup)
    await tester.ensureVisible(find.text('Imbentaryo / Paubos na:'));
    await tester.tap(find.text('Imbentaryo / Paubos na:'));
    await tester.pumpAndSettle();
    expect(controller.ownerTabIndex, 1);
  });
}
