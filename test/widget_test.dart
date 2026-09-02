import 'package:flutter_system_manager/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a clear message on unsupported platforms', (tester) async {
    await tester.pumpWidget(const FlutterSystemManagerApp(isWindows: false));

    expect(find.text('Windows required'), findsOneWidget);
    expect(
      find.textContaining(
        'This demo currently supports Windows system integration.',
      ),
      findsOneWidget,
    );
  });
}
