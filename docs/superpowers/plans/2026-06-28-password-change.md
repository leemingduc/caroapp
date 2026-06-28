# Password Change & Profile Dialog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a simple profile dialog popup featuring a secure password change form styled using the app's existing UI, and integrate it into the user badge of the Caro game screen.

**Architecture:** 
1. Define localizable strings for the profile and change password fields in `AppText`.
2. Create `ProfileDialog` as a new `StatefulWidget` dialog that uses Supabase Auth to first re-authenticate the user with their current password and then update their password.
3. Integrate an icon button in the `CaroGameScreen` user badge to open the `ProfileDialog`.

**Tech Stack:** Flutter, Dart, Supabase Auth (`supabase_flutter` package)

## Global Constraints
- Keep lines short and clean.
- Strictly adhere to standard visual styles (cyan accent `Color(0xFF00F2FE)`, dark backgrounds, and rounded dialog cards).
- Use localizable keys for all user-facing text via `LanguageManager.instance.text`.

---

### Task 1: Add localization keys in `lib/app_language.dart`

**Files:**
- Modify: `lib/app_language.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: None
- Produces: The following getters on `AppText`:
  - `profileTitle` -> VI: 'HỒ SƠ', EN: 'PROFILE'
  - `changePassword` -> VI: 'Đổi mật khẩu', EN: 'Change password'
  - `currentPassword` -> VI: 'Mật khẩu hiện tại', EN: 'Current password'
  - `newPassword` -> VI: 'Mật khẩu mới', EN: 'New password'
  - `confirmNewPassword` -> VI: 'Xác nhận mật khẩu mới', EN: 'Confirm new password'
  - `currentPasswordRequired` -> VI: 'Vui lòng nhập mật khẩu hiện tại', EN: 'Please enter your current password'
  - `newPasswordRequired` -> VI: 'Vui lòng nhập mật khẩu mới', EN: 'Please enter a new password'
  - `confirmNewPasswordRequired` -> VI: 'Vui lòng xác nhận mật khẩu mới', EN: 'Please confirm your new password'
  - `currentPasswordIncorrect` -> VI: 'Mật khẩu hiện tại không chính xác', EN: 'Current password is incorrect'
  - `changePasswordSuccess` -> VI: 'Thay đổi mật khẩu thành công!', EN: 'Password changed successfully!'
  - `changePasswordFailed` -> VI: 'Thay đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu hiện tại.', EN: 'Password change failed. Please check your current password.'
  - `saving` -> VI: 'Đang lưu...', EN: 'Saving...'

- [ ] **Step 1: Write the failing test**
  Add unit tests in `test/widget_test.dart` asserting that the new getters exist on `AppText` and return non-empty strings.
  ```dart
  test('AppText provides localization keys for change password', () {
    final viText = AppText(AppLanguage.vi);
    final enText = AppText(AppLanguage.en);

    expect(viText.profileTitle, 'HỒ SƠ');
    expect(enText.profileTitle, 'PROFILE');
    
    expect(viText.changePassword, 'Đổi mật khẩu');
    expect(enText.changePassword, 'Change password');

    expect(viText.currentPassword, 'Mật khẩu hiện tại');
    expect(enText.currentPassword, 'Current password');

    expect(viText.newPassword, 'Mật khẩu mới');
    expect(enText.newPassword, 'New password');

    expect(viText.confirmNewPassword, 'Xác nhận mật khẩu mới');
    expect(enText.confirmNewPassword, 'Confirm new password');

    expect(viText.currentPasswordRequired, 'Vui lòng nhập mật khẩu hiện tại');
    expect(enText.currentPasswordRequired, 'Please enter your current password');

    expect(viText.newPasswordRequired, 'Vui lòng nhập mật khẩu mới');
    expect(enText.newPasswordRequired, 'Please enter a new password');

    expect(viText.confirmNewPasswordRequired, 'Vui lòng xác nhận mật khẩu mới');
    expect(enText.confirmNewPasswordRequired, 'Please confirm your new password');

    expect(viText.currentPasswordIncorrect, 'Mật khẩu hiện tại không chính xác');
    expect(enText.currentPasswordIncorrect, 'Current password is incorrect');

    expect(viText.changePasswordSuccess, 'Thay đổi mật khẩu thành công!');
    expect(enText.changePasswordSuccess, 'Password changed successfully!');

    expect(viText.changePasswordFailed, 'Thay đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu hiện tại.');
    expect(enText.changePasswordFailed, 'Password change failed. Please check your current password.');

    expect(viText.saving, 'Đang lưu...');
    expect(enText.saving, 'Saving...');
  });
  ```

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test`
  Expected: Compilation error or test failure (getters not defined in `AppText`).

- [ ] **Step 3: Write minimal implementation**
  Add the getters inside `class AppText` in `lib/app_language.dart`:
  ```dart
  String get profileTitle => isVi ? 'HỒ SƠ' : 'PROFILE';
  String get changePassword => isVi ? 'Đổi mật khẩu' : 'Change password';
  String get currentPassword => isVi ? 'Mật khẩu hiện tại' : 'Current password';
  String get newPassword => isVi ? 'Mật khẩu mới' : 'New password';
  String get confirmNewPassword => isVi ? 'Xác nhận mật khẩu mới' : 'Confirm new password';
  String get currentPasswordRequired => isVi ? 'Vui lòng nhập mật khẩu hiện tại' : 'Please enter your current password';
  String get newPasswordRequired => isVi ? 'Vui lòng nhập mật khẩu mới' : 'Please enter a new password';
  String get confirmNewPasswordRequired => isVi ? 'Vui lòng xác nhận mật khẩu mới' : 'Please confirm your new password';
  String get currentPasswordIncorrect => isVi ? 'Mật khẩu hiện tại không chính xác' : 'Current password is incorrect';
  String get changePasswordSuccess => isVi ? 'Thay đổi mật khẩu thành công!' : 'Password changed successfully!';
  String get changePasswordFailed => isVi ? 'Thay đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu hiện tại.' : 'Password change failed. Please check your current password.';
  String get saving => isVi ? 'Đang lưu...' : 'Saving...';
  ```

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test`
  Expected: PASS

- [ ] **Step 5: Commit**
  Run commands:
  ```powershell
  git add lib/app_language.dart test/widget_test.dart
  git commit -m "feat: add localization keys for change password feature"
  ```

---

### Task 2: Implement `ProfileDialog` widget

**Files:**
- Create: `lib/screens/profile_dialog.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `AppText`, `UserProfile`, global `supabase` client.
- Produces: `ProfileDialog` widget class.

- [ ] **Step 1: Write the failing test**
  Add a widget test in `test/widget_test.dart` to verify `ProfileDialog` structure:
  ```dart
  testWidgets('ProfileDialog renders form and labels', (WidgetTester tester) async {
    final dummyProfile = UserProfile(id: 'test-id', email: 'test@example.com');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileDialog(
            userProfile: dummyProfile,
            language: AppLanguage.en,
          ),
        ),
      ),
    );

    expect(find.text('PROFILE'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Current password'), findsOneWidget);
    expect(find.text('New password'), findsOneWidget);
    expect(find.text('Confirm new password'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
  });
  ```

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test`
  Expected: Compilation error (cannot find `ProfileDialog`).

- [ ] **Step 3: Write minimal implementation**
  Create the file `lib/screens/profile_dialog.dart` and build the widget. In the change password logic, sign in using `supabase.auth.signInWithPassword` first to verify the current password, then update using `supabase.auth.updateUser`.
  ```dart
  import 'package:flutter/material.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../models/user_profile.dart';
  import '../app_language.dart';
  import '../supabase_config.dart';

  class ProfileDialog extends StatefulWidget {
    final UserProfile userProfile;
    final AppLanguage language;

    const ProfileDialog({
      super.key,
      required this.userProfile,
      required this.language,
    });

    @override
    State<ProfileDialog> createState() => _ProfileDialogState();
  }

  class _ProfileDialogState extends State<ProfileDialog> {
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    bool _isLoading = false;
    bool _obscureCurrent = true;
    bool _obscureNew = true;
    bool _obscureConfirm = true;

    AppText get _text => AppText(widget.language);

    @override
    void dispose() {
      _currentPasswordController.dispose();
      _newPasswordController.dispose();
      _confirmPasswordController.dispose();
      super.dispose();
    }

    Future<void> _submit() async {
      if (!_formKey.currentState!.validate() || _isLoading) return;

      setState(() => _isLoading = true);
      try {
        // Step 1: Re-authenticate to check current password
        await supabase.auth.signInWithPassword(
          email: widget.userProfile.email,
          password: _currentPasswordController.text,
        );

        // Step 2: Update the password
        await supabase.auth.updateUser(
          UserAttributes(password: _newPasswordController.text),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_text.changePasswordSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } on AuthException catch (error) {
        if (!mounted) return;
        String errMsg = _text.changePasswordFailed;
        if (error.message.toLowerCase().contains('invalid login credentials')) {
          errMsg = _text.currentPasswordIncorrect;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: Colors.redAccent,
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_text.changePasswordFailed),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F2FE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.manage_accounts_rounded,
                          color: Color(0xFF00F2FE),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        _text.profileTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.userProfile.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  Text(
                    _text.changePassword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: _text.currentPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) return _text.currentPasswordRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: _text.newPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) return _text.newPasswordRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: _text.confirmNewPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) return _text.confirmNewPasswordRequired;
                      if (value != _newPasswordController.text) return _text.passwordMismatch;
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.06),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.white.withOpacity(0.08)),
                            ),
                          ),
                          child: Text(_text.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00F2FE),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Text(_text.confirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test`
  Expected: PASS

- [ ] **Step 5: Commit**
  Run commands:
  ```powershell
  git add lib/screens/profile_dialog.dart test/widget_test.dart
  git commit -m "feat: implement ProfileDialog widget with secure password change form"
  ```

---

### Task 3: Integrate Profile Dialog into CaroGameScreen

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `ProfileDialog`
- Produces: `_openProfile()` on `_CaroGameScreenState`.

- [ ] **Step 1: Write the failing test**
  Add a widget test checking that tapping the profile button in the user badge displays the Profile Dialog.
  ```dart
  testWidgets('tapping profile icon button opens ProfileDialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CaroGameScreen(
          userEmail: 'player@example.com',
          userId: 'test-user-id',
        ),
      ),
    );

    // Let the profile load
    await tester.pumpAndSettle();

    // Verify profile icon is shown
    final profileButtonFinder = find.byIcon(Icons.manage_accounts_rounded);
    expect(profileButtonFinder, findsOneWidget);

    // Tap the button
    await tester.tap(profileButtonFinder);
    await tester.pumpAndSettle();

    // Dialog should be open
    expect(find.byType(ProfileDialog), findsOneWidget);
  });
  ```

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test`
  Expected: Fails (cannot find `Icons.manage_accounts_rounded` icon button on screen).

- [ ] **Step 3: Write minimal implementation**
  1. Add import: `import 'screens/profile_dialog.dart';` near the top of `lib/main.dart`.
  2. Implement `_openProfile()` function in `_CaroGameScreenState`:
     ```dart
     void _openProfile() {
       if (_userProfile == null) return;
       showDialog(
         context: context,
         builder: (context) => ProfileDialog(
           userProfile: _userProfile!,
           language: LanguageManager.instance.currentLanguage,
         ),
       );
     }
     ```
  3. Modify `_buildUserBadge()` in `lib/main.dart` to insert the IconButton:
     ```dart
     IconButton(
       tooltip: LanguageManager.instance.text.profileTitle,
       visualDensity: VisualDensity.compact,
       iconSize: 18,
       color: Colors.white70,
       onPressed: _openProfile,
       icon: const Icon(Icons.manage_accounts_rounded),
     ),
     ```

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test`
  Expected: PASS

- [ ] **Step 5: Commit**
  Run commands:
  ```powershell
  git add lib/main.dart test/widget_test.dart
  git commit -m "feat: integrate ProfileDialog into CaroGameScreen user badge"
  ```
