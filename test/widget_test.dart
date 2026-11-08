import 'package:flutter_test/flutter_test.dart';
import 'package:karinderya_mobile_application/main.dart';

void main() {
  testWidgets('Karinderya initial load smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KarinderyaApp());
    expect(find.text('Karinderya'), findsOneWidget);
  });
}
