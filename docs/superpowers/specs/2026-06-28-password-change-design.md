# Design Specification: Password Change & Profile Dialog

This document outlines the design and implementation details for adding a password change feature inside a simple profile dialog. The feature will match the existing UI/UX patterns of the Caro Arena game.

## Overview
Currently, the application allows users to sign in and sign up using Supabase Auth. It also has dialogs for the Shop and Leaderboard. However, it lacks a profile screen or dialog where users can view their information or update their password.
This design introduces a **Profile Dialog** triggered from the user badge in the main game area, offering a password change form.

## User Interface & Experience

### 1. Entry Point: User Badge Integration
We will update `_buildUserBadge()` in [main.dart](file:///d:/cocaro/caroapp/lib/main.dart) to include a Profile button next to the Logout button.
* **Icon**: `Icons.manage_accounts_rounded` (fits theme style)
* **Tooltip**: Translated "Profile" string
* **Action**: Calls `_openProfile()` which opens the `ProfileDialog`

```dart
IconButton(
  tooltip: LanguageManager.instance.text.profileTitle,
  visualDensity: VisualDensity.compact,
  iconSize: 18,
  color: Colors.white70,
  onPressed: _openProfile,
  icon: const Icon(Icons.manage_accounts_rounded),
)
```

### 2. Profile Dialog (`ProfileDialog`)
We will create a new widget `ProfileDialog` in [profile_dialog.dart](file:///d:/cocaro/caroapp/lib/screens/profile_dialog.dart) styled consistently with `ShopDialog`.
* **Background**: Sleek dark color (`const Color(0xFF0F172A)`) with a translucent blurred dialog border.
* **Top Area**: Displays user profile title and the current user's email address.
* **Change Password Form**:
  * **Current Password**: Password input field with hide/show suffix toggle.
  * **New Password**: Password input field with hide/show suffix toggle.
  * **Confirm New Password**: Password input field.
* **Buttons**:
  * **Cancel/Close**: Styled similarly to the Shop close button (subtle white border on dark background).
  * **Change Password**: High-contrast gradient or solid cyan button (`Color(0xFF00F2FE)`) that triggers validation and submission.
* **Loading State**: Displays a `CircularProgressIndicator` inside the submit button while processing.

## Authentication & Backend Logic
Supabase does not have an API to update the user's password that automatically checks the current password as part of the same call. Therefore, we must perform a two-step validation:

1. **Verify Current Password**:
   Call `supabase.auth.signInWithPassword` using the current user's email and the entered *current password*.
   * If this succeeds, the current password is valid.
   * If it fails (e.g. `AuthException`), the user is shown a validation error: "Mật khẩu hiện tại không chính xác" (Current password is incorrect).
2. **Update Password**:
   Once the old password is verified, update the password via:
   `await supabase.auth.updateUser(UserAttributes(password: newPassword));`
3. **Handle success**:
   Show a success SnackBar, clear fields, and close the dialog.

## Localization Changes
We will update `lib/app_language.dart` to add the following localized strings (in both English and Vietnamese):
* `profileTitle`: Profile / Hồ sơ
* `changePassword`: Change Password / Đổi mật khẩu
* `currentPassword`: Current Password / Mật khẩu hiện tại
* `newPassword`: New Password / Mật khẩu mới
* `confirmNewPassword`: Confirm New Password / Xác nhận mật khẩu mới
* `currentPasswordRequired`: Please enter your current password / Vui lòng nhập mật khẩu hiện tại
* `newPasswordRequired`: Please enter a new password / Vui lòng nhập mật khẩu mới
* `confirmNewPasswordRequired`: Please confirm your new password / Vui lòng xác nhận mật khẩu mới
* `passwordMismatch`: Passwords do not match / Mật khẩu không trùng khớp
* `currentPasswordIncorrect`: Current password is incorrect / Mật khẩu hiện tại không chính xác
* `changePasswordSuccess`: Password changed successfully / Thay đổi mật khẩu thành công!
* `changePasswordFailed`: Failed to change password / Thay đổi mật khẩu thất bại

## Verification Plan

### Manual Verification
1. Log in with a test user.
2. Click the Profile/Manage Accounts icon on the user badge.
3. Verify that the Profile Dialog displays correct user email.
4. Test validations:
   * Empty inputs.
   * Invalid current password (should display error).
   * New password and confirm password mismatch.
5. Enter valid current password, matching new password, and click Change Password.
6. Verify success SnackBar is displayed and dialog closes.
7. Log out, and verify you can log in with the *new* password.
