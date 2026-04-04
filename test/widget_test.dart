import 'package:flutter_test/flutter_test.dart';
import 'package:pillapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PillApp());
    expect(find.text('WALL-E Meds'), findsNothing);
  });
}
