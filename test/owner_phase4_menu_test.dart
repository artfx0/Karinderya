import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/controllers/karinderya_controller.dart';
import 'package:karinderya_mobile_application/models/app_state.dart';
import 'package:karinderya_mobile_application/views/owner/owner_dashboard_view.dart';

void main() {
  test('Phase 4 Unit: Controller categorizes, searches, and sorts owner menu dishes', () {
    final controller = KarinderyaController();

    // Default category is Ulams (3 items in seed: Adobo, Lumpia, Pinakbet)
    expect(controller.ownerMenuCategory, DishCategory.ulam);
    expect(controller.filteredOwnerDishes.length, 3);

    // Search filters within active category
    controller.setOwnerMenuSearchQuery('Adobo');
    expect(controller.filteredOwnerDishes.map((d) => d.name).toList(), ['Chicken Adobo']);

    // Clear search & sort by price low to high in Ulams (Lumpia 60, Pinakbet 75, Adobo 90)
    controller.setOwnerMenuSearchQuery('');
    controller.setOwnerMenuSort(OwnerMenuSortOption.priceLowToHigh);
    expect(
      controller.filteredOwnerDishes.map((d) => d.name).toList(),
      ['Lumpiang Shanghai', 'Pinakbet Tagalog', 'Chicken Adobo'],
    );

    // Filter availability: Sold Out Only -> Pinakbet Tagalog
    controller.setOwnerMenuAvailability(OwnerMenuAvailabilityFilter.soldOutOnly);
    expect(controller.filteredOwnerDishes.map((d) => d.name).toList(), ['Pinakbet Tagalog']);

    // Reset filters and switch to Drinks
    controller.resetOwnerMenuFilters();
    controller.setOwnerMenuCategory(DishCategory.drinks);
    expect(controller.filteredOwnerDishes.map((d) => d.name).toList(), ['Sago’t Gulaman']);
  });

  testWidgets('Phase 4 Widget: Menu Setup renders 4 strict category tabs, persistent search, and sort modal',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = KarinderyaController();
    controller.loginWithCredentials('owner@karinderya.ph', 'owner123');
    controller.setOwnerTabIndex(1); // Menu Setup

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => OwnerDashboardView(controller: controller),
        ),
      ),
    );
    await tester.pump();

    // 1. All 4 category tabs present with counts
    expect(find.text('Ulams (3)'), findsOneWidget);
    expect(find.text('Rice & Sides (1)'), findsOneWidget);
    expect(find.text('Soup (1)'), findsOneWidget);
    expect(find.text('Drinks (1)'), findsOneWidget);

    // Initially on Ulams -> shows Chicken Adobo, hides Steamed Rice
    expect(find.text('Chicken Adobo'), findsOneWidget);
    expect(find.text('Steamed Rice'), findsNothing);

    // 2. Tap Rice & Sides -> shows Steamed Rice
    await tester.tap(find.text('Rice & Sides (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Steamed Rice'), findsOneWidget);
    expect(find.text('Chicken Adobo'), findsNothing);

    // 3. Switch back to Ulams and test real-time search
    await tester.tap(find.text('Ulams (3)'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Lumpia');
    await tester.pumpAndSettle();
    expect(find.text('Lumpiang Shanghai'), findsOneWidget);
    expect(find.text('Chicken Adobo'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('Chicken Adobo'), findsOneWidget);

    // 4. Open Filter & Sort sheet via filter icon
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.text('Ayusin at Salain (Sort & Filter)'), findsOneWidget);

    await tester.tap(find.text('Sold Out Lang'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tapos na'));
    await tester.pumpAndSettle();

    // Only sold-out item (Pinakbet Tagalog) remains visible
    expect(find.text('Pinakbet Tagalog'), findsOneWidget);
    expect(find.text('Chicken Adobo'), findsNothing);
  });
}
