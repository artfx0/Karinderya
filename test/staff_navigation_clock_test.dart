import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/views/staff/staff_dashboard_view.dart';

void main() {
  testWidgets('Staff Dashboard renders Live PST Clock and 5-Tab Navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    // Login as staff
    controller.loginWithCredentials('staff@karinderya.ph', 'staff123');

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => StaffDashboardView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // 1. Verify Live Clock and Philippine Standard Time (PST) in Header
    expect(find.textContaining('PST'), findsOneWidget);
    expect(find.text('Karinderya'), findsOneWidget);
    expect(find.textContaining('Ana Reyes'), findsWidgets);

    // 2. Verify all 5 navigation tabs exist
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Shift'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // 3. Switch to History Tab (Index 2)
    controller.setStaffTabIndex(2);
    await tester.pump();
    expect(find.text('Kasaysayan ng Order'), findsOneWidget);
    expect(find.text('Lahat'), findsOneWidget);

    // 4. Switch to Shift Tab (Index 3)
    controller.setStaffTabIndex(3);
    await tester.pump();
    expect(find.text('BUOD NG AKING SHIFT'), findsOneWidget);
    expect(find.text('Reconciliation ng Cash Drawer'), findsOneWidget);
    expect(find.text('Nai-punch na Order'), findsOneWidget);
    expect(find.text('Natanggap na Cash'), findsOneWidget);

    // 5. Switch to Settings Tab (Index 4)
    controller.setStaffTabIndex(4);
    await tester.pump();
    expect(find.text('MGA KAGUSTUHAN (PREFERENCES)'), findsOneWidget);
    expect(find.text('Protektado ang Karinderya Data'), findsOneWidget);
    expect(find.text('Mag-log out'), findsOneWidget);
  });
}
