import 'package:flutter_test/flutter_test.dart';
import 'package:tugas1_flutter/main.dart';

void main() {
  testWidgets('MyApp berhasil dijalankan', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}