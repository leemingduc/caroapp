import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caroapp/screens/profile_dialog.dart';
import 'package:caroapp/models/user_profile.dart';
import 'package:caroapp/app_language.dart';

void main() {
  testWidgets('ProfileDialog renders profile information and password fields', (WidgetTester tester) async {
    final userProfile = UserProfile(
      id: 'test-user-id',
      email: 'player@example.com',
      diamonds: 150,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDialog(
            userProfile: userProfile,
            language: AppLanguage.vi,
          ),
        ),
      ),
    );

    // Verify dialog header / title
    expect(find.text('HỒ SƠ'), findsOneWidget);
    
    // Verify email display
    expect(find.text('player@example.com'), findsOneWidget);

    // Verify change password section text
    expect(find.text('Đổi mật khẩu'), findsOneWidget);

    // Verify input fields
    expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
    expect(find.text('Mật khẩu mới'), findsOneWidget);
    expect(find.text('Xác nhận mật khẩu mới'), findsOneWidget);

    // Verify action buttons
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('Xác nhận'), findsOneWidget);
  });
}
