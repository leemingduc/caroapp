import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:caroapp/main.dart';

void main() {
  testWidgets('login screen shows email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('CARO ARENA'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Dang nhap'), findsAtLeastNWidgets(1));
    expect(find.text('Dang ky'), findsOneWidget);
  });

  testWidgets('login screen can switch to register mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Chua co tai khoan? Dang ky ngay'));
    await tester.pump();

    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Dang ky tai khoan'), findsOneWidget);
  });

  testWidgets('game screen shows signed in user email', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CaroGameScreen(
          userEmail: 'player@example.com',
          userId: 'dummy-id',
        ),
      ),
    );

    expect(find.text('player@example.com'), findsOneWidget);
  });
}
