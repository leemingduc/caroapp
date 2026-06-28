import 'package:flutter_test/flutter_test.dart';
import 'package:caroapp/app_language.dart';

void main() {
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
}
