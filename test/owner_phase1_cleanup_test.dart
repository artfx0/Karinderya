import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/models/app_state.dart';
import 'package:karinderya_mobile_application/views/owner/owner_dashboard_view.dart';

void main() {
  testWidgets('Phase 1: Owner Dashboard hides Staff POS, Set today\'s menu, Open drawer and provides Logout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('owner@karinderya.ph', 'owner123');
    expect(controller.screen, ScreenState.owner);
    expect(controller.role, UserRole.owner);

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => OwnerDashboardView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // 1. Removed actions/buttons must not exist
    expect(find.text('Staff POS'), findsNothing);
    expect(find.text("Set today's menu"), findsNothing);
    expect(find.text('Set today’s menu'), findsNothing);
    expect(find.text('Open drawer'), findsNothing);

    // 2. Owner Header Logout button must exist and prompt confirmation before logging out
    final logoutIcon = find.byIcon(Icons.logout);
    expect(logoutIcon, findsOneWidget);

    await tester.tap(logoutIcon);
    await tester.pumpAndSettle();

    expect(find.text('Mag-log out?'), findsOneWidget);
    await tester.tap(find.text('Oo, mag-log out'));
    await tester.pumpAndSettle();

    expect(controller.screen, ScreenState.login);
  });
}
