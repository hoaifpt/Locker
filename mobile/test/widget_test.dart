// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:locker_mobile/main.dart';

void main() {
<<<<<<< HEAD
  testWidgets('Login screen UI test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Kiểm tra các thành phần chính
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Tiếp tục'), findsOneWidget);
    expect(find.text('Số điện thoại'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Đăng ký ngay'), findsOneWidget);
=======
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
>>>>>>> cd41969f38b41cd3f098ee3ee44d55472bf88075
  });
}
