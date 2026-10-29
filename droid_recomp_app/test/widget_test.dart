import 'package:flutter_test/flutter_test.dart';
import 'package:droid_recomp_app/main.dart';

void main() {
  testWidgets('DroidRecompApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DroidRecompApp());
    expect(find.byType(DroidRecompApp), findsOneWidget);
  });
}
