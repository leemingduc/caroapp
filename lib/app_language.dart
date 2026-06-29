import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { vi, en }

extension AppLanguageExt on AppLanguage {
  String get code => this == AppLanguage.vi ? 'vi' : 'en';
  String get shortLabel => this == AppLanguage.vi ? 'VI' : 'EN';
  String get name => this == AppLanguage.vi ? 'Tiếng Việt' : 'English';
}

class AppText {
  const AppText(this.appLanguage);

  final AppLanguage appLanguage;

  bool get isVi => appLanguage == AppLanguage.vi;

  String get appTitle => 'CARO ARENA';
  String get appSubtitle => isVi ? 'Cờ caro trực tuyến' : 'Online Gomoku game';
  String get signIn => isVi ? 'Đăng nhập' : 'Sign in';
  String get signUp => isVi ? 'Đăng kí' : 'Sign up';
  String get signUpAccount => isVi ? 'Đăng kí tài khoản' : 'Create account';
  String get email => 'Email';
  String get password => isVi ? 'Mật khẩu' : 'Password';
  String get confirmPassword => isVi ? 'Xác nhận mật khẩu' : 'Confirm password';
  String get showPassword => isVi ? 'Hiện mật khẩu' : 'Show password';
  String get hidePassword => isVi ? 'Ẩn mật khẩu' : 'Hide password';
  String get emailRequired => isVi ? 'Vui lòng nhập email' : 'Please enter your email';
  String get emailInvalid => isVi ? 'Email không hợp lệ' : 'Invalid email';
  String get passwordRequired => isVi ? 'Vui lòng nhập mật khẩu' : 'Please enter your password';
  String get confirmPasswordRequired => isVi ? 'Vui lòng nhập lại mật khẩu' : 'Please confirm your password';
  String get passwordMismatch => isVi ? 'Mật khẩu không trùng khớp' : 'Passwords do not match';
  String get authRequestFailed => isVi ? 'Không thể xử lý yêu cầu. Vui lòng thử lại.' : 'Could not process the request. Please try again.';
  String get signUpSuccess => isVi ? 'Đăng kí thành công. Vui lòng kiểm tra email để xác nhận tài khoản.' : 'Account created. Please check your email to confirm it.';
  String get alreadyHaveAccount => isVi ? 'Đã có tài khoản? Đăng nhập' : 'Already have an account? Sign in';
  String get noAccountYet => isVi ? 'Chưa có tài khoản? Đăng kí ngay' : 'No account yet? Sign up';
  String get signOut => isVi ? 'Đăng xuất' : 'Sign out';
  String get language => isVi ? 'Ngôn ngữ' : 'Language';

  String get reviveNoDiamonds => isVi ? '⚠️ Bạn không đủ Kim Cương để hồi sinh!' : '⚠️ Not enough Diamonds to revive!';
  String reviveSuccess(int cost) => isVi ? '✨ Hồi sinh thành công! Đã sử dụng $cost Kim Cương 💎' : '✨ Revived successfully! Spent $cost Diamonds 💎';
  String get hintNoDiamonds => isVi ? '⚠️ Bạn không đủ Kim Cương để nhận gợi ý (cần 10 💎)!' : '⚠️ Not enough Diamonds for a hint (need 10 💎)!';
  String get hintShown => isVi ? '💡 Đã hiển thị gợi ý AI! Trừ 10 Kim Cương 💎' : '💡 AI hint shown! Spent 10 Diamonds 💎';
  String get hintNotFound => isVi ? 'Không tìm được nước gợi ý phù hợp.' : 'No suitable hint was found.';
  String winReward(int diamonds) => isVi ? '🎉 Chiến thắng! Bạn nhận được +$diamonds Kim Cương 💎' : '🎉 Victory! You received +$diamonds Diamonds 💎';

  String get aiWon => isVi ? 'MÁY ĐÃ THẮNG!' : 'AI WON!';
  String get reviveQuestion => isVi
      ? 'Bạn đã bị Máy đánh bại. Bạn có muốn hồi sinh để tiếp tục trận đấu không?'
      : 'The AI defeated you. Do you want to revive and continue this match?';
  String get reviveFee => isVi ? 'Phí hồi sinh:' : 'Revive fee:';
  String diamonds(int value) => isVi ? '$value Kim Cương 💎' : '$value Diamonds 💎';
  String balance(int value) => isVi ? 'Số dư của bạn: $value Kim Cương 💎' : 'Your balance: $value Diamonds 💎';
  String get acceptLoss => isVi ? 'Chấp nhận thua' : 'Accept loss';
  String get reviveNow => isVi ? 'Hồi sinh ngay' : 'Revive now';
  String get notEnoughDiamonds => isVi ? 'Không đủ Kim Cương' : 'Not enough Diamonds';
  String get notEnoughDiamondsToRevive => isVi ? 'Không đủ Kim Cương để hồi sinh' : 'Not enough Diamonds to revive';

  String get aiThinking => isVi ? 'Máy nghĩ...' : 'AI thinking...';
  String get turn => isVi ? 'Lượt: ' : 'Turn: ';
  String get youX => isVi ? 'Bạn (X)' : 'You (X)';
  String get draw => isVi ? 'Hòa' : 'Draw';
  String get drawBang => isVi ? 'Hòa!' : 'Draw!';
  String winner(String value) => isVi ? '$value Thắng!' : '$value Wins!';
  String get playing => isVi ? 'Đang chơi' : 'Playing';
  String get victory => isVi ? 'CHIẾN THẮNG!' : 'VICTORY!';
  String playerWon(String value) => isVi ? 'PLAYER $value đã thắng cuộc!' : 'PLAYER $value won!';
  String get drawTitle => isVi ? 'HÒA CỜ' : 'DRAW';
  String get boardFull => isVi ? 'Bàn cờ đã đầy!' : 'The board is full!';
  String get aiThinkingTitle => isVi ? 'MÁY ĐANG NGHĨ' : 'AI THINKING';
  String get calculatingMove => isVi ? '🤖 Đang tính toán nước đi...' : '🤖 Calculating a move...';
  String get yourTurnX => isVi ? 'Lượt của BẠN (X)' : 'YOUR turn (X)';
  String get aiTurnO => isVi ? 'Lượt của MÁY (O)' : 'AI turn (O)';
  String get playerXTurn => isVi ? 'Lượt của PLAYER X' : 'PLAYER X turn';
  String get playerOTurn => isVi ? 'Lượt của PLAYER O' : 'PLAYER O turn';

  String get shop => isVi ? 'Cửa hàng' : 'Shop';
  String get leaderboard => isVi ? 'Bảng xếp hạng' : 'Leaderboard';
  String get aiHint10 => isVi ? '💡 Gợi ý AI (10đ)' : '💡 AI Hint (10)';
  String get hint10 => isVi ? '💡 Gợi ý (10đ)' : '💡 Hint (10)';
  String get undo => isVi ? 'Hoàn tác' : 'Undo';
  String get centerBoard => isVi ? 'Căn giữa bàn cờ' : 'Center board';
  String get replay => isVi ? 'Chơi lại' : 'Replay';
  String get newMatch => isVi ? 'CHƠI LẠI TRẬN MỚI' : 'START NEW MATCH';
  String get resetScore => isVi ? 'Đặt lại điểm số' : 'Reset score';
  String get resetAllScores => isVi ? 'Đặt lại tất cả điểm số (0 - 0)' : 'Reset all scores (0 - 0)';
  String get scoreTitle => isVi ? 'TỈ SỐ TRẬN ĐẤU' : 'MATCH SCORE';
  String get settingsTitle => isVi ? 'THIẾT LẬP GAME' : 'GAME SETTINGS';
  String get matchSettings => isVi ? 'CÀI ĐẶT TRẬN ĐẤU' : 'MATCH SETTINGS';
  String get boardSize => isVi ? 'Kích thước:' : 'Board size:';
  String get customSizeTooltip => isVi ? 'Nhấp để tự nhập kích thước (3–35)' : 'Click to enter a custom size (3–35)';
  String winLengthInfo(int count) => isVi ? 'Cần $count ô liên tiếp để thắng' : 'Need $count in a row to win';
  String get gameMode => isVi ? 'CHẾ ĐỘ CHƠI' : 'GAME MODE';
  String get twoPlayers => isVi ? '👥 2 Người' : '👥 2 Players';
  String get versusAi => isVi ? '🤖 vs Máy' : '🤖 vs AI';
  String get pvpOnline => isVi ? '⚔️ PvP Online' : '⚔️ Online PvP';
  String get searchingOpponent => isVi ? 'Đang tìm đối thủ...' : 'Searching for opponent...';
  String get matchmaking => isVi ? 'Ghép Trận' : 'Matchmaking';
  String get cancelMatchmaking => isVi ? 'Hủy Tìm Trận' : 'Cancel Matchmaking';
  String get opponentTurn => isVi ? 'Lượt của đối thủ...' : 'Opponent\'s turn...';
  String get yourTurn => isVi ? 'Lượt của BẠN!' : 'Your turn!';
  String get surrender => isVi ? 'Đầu hàng' : 'Surrender';
  String get turnTimeout => isVi ? 'Hết thời gian lượt!' : 'Turn timeout!';
  String get opponentDisconnected => isVi ? 'Đối thủ đã rời trận hoặc đầu hàng!' : 'Opponent left or surrendered!';
  String timeRemaining(int s) => isVi ? 'Thời gian còn lại: ${s}s' : 'Time remaining: ${s}s';
  String get waitingOpponent => isVi ? 'Đang chờ đối thủ...' : 'Waiting for opponent...';
  String get aiDifficulty => isVi ? 'ĐỘ KHÓ AI' : 'AI DIFFICULTY';
  String get doubleBlock => isVi ? 'Chặn 2 đầu:' : 'Double-block rule:';
  String get doubleBlockLong => isVi ? 'Luật chặn hai đầu:' : 'Double-block rule:';
  String get doubleBlockDesc => isVi ? 'Không thắng nếu bị chặn 2 đầu' : 'No win if both ends are blocked';
  String get doubleBlockDescLong => isVi ? 'Không thắng khi bị đối thủ chặn cả 2 đầu' : 'No win when both ends are blocked by the opponent';
  String ruleModeChanged(bool enabled) => isVi
      ? 'Đã chuyển sang luật ${enabled ? "chặn hai đầu" : "tự do (Gomoku)"}.'
      : 'Rule changed to ${enabled ? "double-block" : "free Gomoku"}.';
  String get panZoomHelp => isVi ? 'Kéo để di chuyển bàn cờ • Ctrl + lăn chuột để thu phóng' : 'Click and drag to pan • Ctrl + scroll to zoom';

  String get customSizeTitle => isVi ? 'Kích thước tự chọn' : 'Custom board size';
  String get customSizePrompt => isVi ? 'Nhập kích thước bàn cờ (từ 3 đến 35):' : 'Enter board size (from 3 to 35):';
  String get customSizeLabel => isVi ? 'Kích thước (3 - 35)' : 'Size (3 - 35)';
  String get customSizeHint => isVi ? 'Nhập số từ 3 đến 35' : 'Enter a number from 3 to 35';
  String get numberRequired => isVi ? 'Vui lòng nhập một số' : 'Please enter a number';
  String get sizeInvalid => isVi ? 'Kích thước phải từ 3 đến 35' : 'Size must be from 3 to 35';
  String get cancel => isVi ? 'Hủy' : 'Cancel';
  String get confirm => isVi ? 'Xác nhận' : 'Confirm';
  String get continueText => isVi ? 'Tiếp tục' : 'Continue';
  String get close => isVi ? 'Đóng' : 'Close';
  String get changeSettingsTitle => isVi ? 'Thay đổi cài đặt?' : 'Change settings?';
  String get changeSettingsBody => isVi
      ? 'Thay đổi cài đặt sẽ bắt đầu lại trận hiện tại. Bạn có muốn tiếp tục không?'
      : 'Changing settings will restart the current match. Do you want to continue?';

  String get rulesTitle => isVi ? 'Luật Chơi Cờ Caro' : 'Gomoku Rules';
  String get rule1 => isVi ? 'Người chơi lần lượt đặt X và O lên các ô trống.' : 'Players take turns placing X and O on empty cells.';
  String get rule2 => isVi
      ? 'Chiến thắng khi đủ ô liên tiếp thẳng hàng ngang, dọc hoặc chéo: 3x3 cần 3 ô, 4x4 cần 4 ô, 5x5-19x19 cần 5 ô, 20x20-35x35 cần 6 ô.'
      : 'Win by forming enough consecutive cells horizontally, vertically, or diagonally: 3x3 needs 3, 4x4 needs 4, 5x5-19x19 needs 5, 20x20-35x35 needs 6.';
  String get rule3 => isVi
      ? 'Luật chặn 2 đầu (nếu bật): Nếu chuỗi đủ điều kiện thắng bị chặn ở cả 2 đầu bởi quân cờ của đối thủ thì chưa được tính thắng.'
      : 'Double-block rule (if enabled): a winning-length line blocked at both ends by the opponent does not count as a win.';
  String get rule4 => isVi
      ? 'Thu phóng: Dùng Ctrl + lăn chuột trên PC hoặc kéo 2 ngón tay trên Mobile để phóng to/thu nhỏ. Kéo bằng 1 ngón/chuột để di chuyển bàn cờ.'
      : 'Zoom: use Ctrl + mouse wheel on PC or pinch with two fingers on mobile. Drag with one finger/mouse to move the board.';

  String get shopTitle => isVi ? 'CỬA HÀNG CARO' : 'CARO SHOP';
  String get skinsTab => isVi ? 'SKIN QUÂN CỜ' : 'PIECE SKINS';
  String get themesTab => isVi ? 'THEME BÀN CỜ' : 'BOARD THEMES';
  String get closeShop => isVi ? 'ĐÓNG CỬA HÀNG' : 'CLOSE SHOP';
  String get active => isVi ? 'Đang dùng' : 'Active';
  String get apply => isVi ? 'Áp dụng' : 'Apply';
  String unlockedSkin(String name) => isVi ? '🎉 Mở khóa thành công Skin "$name"!' : '🎉 Unlocked skin "$name"!';
  String get buySkinFailed => isVi ? '❌ Đã xảy ra lỗi khi mua Skin. Vui lòng thử lại!' : '❌ Could not buy this skin. Please try again!';
  String get buySkinUnknown => isVi ? '❌ Lỗi không xác định khi mua Skin. Vui lòng thử lại!' : '❌ Unknown error while buying skin. Please try again!';
  String get applySkinSuccess => isVi ? '✨ Đã áp dụng Skin quân cờ mới!' : '✨ New piece skin applied!';
  String get applySkinFailed => isVi ? '❌ Không thể áp dụng Skin. Vui lòng thử lại!' : '❌ Could not apply this skin. Please try again!';
  String unlockedTheme(String name) => isVi ? '🎉 Mở khóa thành công Theme "$name"!' : '🎉 Unlocked theme "$name"!';
  String get buyThemeFailed => isVi ? '❌ Đã xảy ra lỗi khi mua Theme. Vui lòng thử lại!' : '❌ Could not buy this theme. Please try again!';
  String get buyThemeUnknown => isVi ? '❌ Lỗi không xác định khi mua Theme. Vui lòng thử lại!' : '❌ Unknown error while buying theme. Please try again!';
  String get applyThemeSuccess => isVi ? '✨ Đã áp dụng giao diện bàn cờ mới!' : '✨ New board theme applied!';
  String get applyThemeFailed => isVi ? '❌ Không thể áp dụng Theme. Vui lòng thử lại!' : '❌ Could not apply this theme. Please try again!';
  String get unknownErrorRetry => isVi ? '❌ Lỗi không xác định. Vui lòng thử lại!' : '❌ Unknown error. Please try again!';

  String get leaderboardTitle => isVi ? 'BẢNG XẾP HẠNG' : 'LEADERBOARD';
  String get closeLeaderboard => isVi ? 'ĐÓNG BẢNG XẾP HẠNG' : 'CLOSE LEADERBOARD';
  String get leaderboardLoadFailed => isVi ? 'Không thể tải bảng xếp hạng.\nVui lòng thử lại!' : 'Could not load the leaderboard.\nPlease try again!';
  String get noPlayerData => isVi ? 'Chưa có dữ liệu người chơi.' : 'No player data yet.';
  String get anonymous => isVi ? 'Ẩn danh' : 'Anonymous';
  String winsVsAi(int wins) => isVi ? 'Thắng máy: $wins trận' : 'AI wins: $wins matches';

  String difficulty(String key) {
    switch (key) {
      case 'easy':
        return isVi ? '🎮 Dễ' : '🎮 Easy';
      case 'amateur':
        return isVi ? '🏠 Nghiệp dư' : '🏠 Amateur';
      case 'medium':
        return isVi ? '⚔️ Trung bình' : '⚔️ Medium';
      case 'semiPro':
        return isVi ? '🎯 Bán chuyên' : '🎯 Semi-pro';
      case 'professional':
        return isVi ? '🏆 Chuyên nghiệp' : '🏆 Professional';
      default:
        return key;
    }
  }

  String winLevelTitle(String key) {
    switch (key) {
      case 'easy':
        return isVi ? '🎮 Chiến thắng!' : '🎮 Victory!';
      case 'amateur':
        return isVi ? '🏠 Xuất sắc!' : '🏠 Excellent!';
      case 'medium':
        return isVi ? '⚔️ Ấn tượng!' : '⚔️ Impressive!';
      case 'semiPro':
        return isVi ? '🎯 Bán chuyên nghiệp!' : '🎯 Semi-pro!';
      case 'professional':
        return isVi ? '🏆 HUYỀN THOẠI!' : '🏆 LEGENDARY!';
      default:
        return isVi ? 'Chiến thắng!' : 'Victory!';
    }
  }

  String winLevelSubtitle(String key) {
    switch (key) {
      case 'easy':
        return isVi ? 'Bạn đã vượt qua AI dễ' : 'You beat Easy AI';
      case 'amateur':
        return isVi ? 'Bạn đã vượt qua AI nghiệp dư' : 'You beat Amateur AI';
      case 'medium':
        return isVi ? 'Bạn đã chinh phục AI trung bình' : 'You conquered Medium AI';
      case 'semiPro':
        return isVi ? 'Bạn đã đánh bại AI bán chuyên!' : 'You defeated Semi-pro AI!';
      case 'professional':
        return isVi ? 'Bạn đã ĐÁNH BẠI AI CHUYÊN NGHIỆP!' : 'You BEAT PROFESSIONAL AI!';
      default:
        return '';
    }
  }

  String get masterLevelAchieved => isVi ? 'ĐẠT CẤP BẬC CAO THỦ' : 'MASTER LEVEL ACHIEVED';

  // Mobile game UI
  String get diamondsTitle => isVi ? 'KIM CƯƠNG' : 'DIAMONDS';
  String reviveWithDiamonds(int cost) => isVi
      ? 'HỒI SINH BẰNG KIM CƯƠNG (Tốn $cost 💎)'
      : 'REVIVE WITH DIAMONDS (Cost $cost 💎)';
  String playerWins(String player) => isVi ? 'Người chơi $player thắng!' : 'Player $player wins!';
  String get changeSettingsQuestion => isVi ? 'Thay đổi cài đặt?' : 'Change settings?';
  String get changeSettingsWarning => isVi
      ? 'Việc thay đổi kích thước bàn cờ sẽ bắt đầu một trận đấu mới và làm sạch bàn cờ hiện tại. Bạn có chắc chắn muốn tiếp tục?'
      : 'Changing the board size will start a new match and clear the current board. Are you sure you want to continue?';
  String get drawLabel => isVi ? 'HÒA' : 'DRAW';

  // Profile & Change Password
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

  // ─── Friends ───────────────────────────────────────────────────────────────
  String get friends => isVi ? 'Bạn bè' : 'Friends';
  String get friendsTitle => isVi ? 'BẠN BÈ' : 'FRIENDS';
  String get closeFriends => isVi ? 'ĐÓNG' : 'CLOSE';
  String get friendsTab => isVi ? 'BẠN BÈ' : 'FRIENDS';
  String get requestsTab => isVi ? 'LỜI MỜI' : 'REQUESTS';
  String get searchTab => isVi ? 'TÌM KIẾM' : 'SEARCH';
  String get searchByEmail => isVi ? 'Tìm theo email...' : 'Search by email...';
  String get addFriend => isVi ? 'Kết bạn' : 'Add friend';
  String get friendRequestSent => isVi ? '✅ Đã gửi lời mời kết bạn!' : '✅ Friend request sent!';
  String get friendRequestExists => isVi ? 'Lời mời đã tồn tại hoặc đã là bạn bè.' : 'Request already sent or already friends.';
  String get friendAccepted => isVi ? '✅ Đã chấp nhận kết bạn!' : '✅ Friend request accepted!';
  String get friendRemoved => isVi ? 'Đã xóa bạn bè.' : 'Friend removed.';
  String get friendActionFailed => isVi ? '❌ Thao tác thất bại. Vui lòng thử lại.' : '❌ Action failed. Please try again.';
  String get noFriendsYet => isVi ? 'Bạn chưa có bạn bè. Hãy tìm kiếm và kết bạn!' : 'No friends yet. Search and add some!';
  String get noPendingRequests => isVi ? 'Không có lời mời nào đang chờ.' : 'No pending requests.';
  String get userNotFound => isVi ? 'Không tìm thấy người dùng với email này.' : 'No user found with this email.';
  String get online => isVi ? 'Đang online' : 'Online';
  String get offline => isVi ? 'Offline' : 'Offline';
  String get accept => isVi ? 'Đồng ý' : 'Accept';
  String get decline => isVi ? 'Từ chối' : 'Decline';
  String get removeFriend => isVi ? 'Xóa bạn' : 'Remove';

  // ─── Custom Room ────────────────────────────────────────────────────────────
  String get pvpModeTitle => isVi ? 'CHỌN CHẾ ĐỘ PVP' : 'CHOOSE PVP MODE';
  String get autoMatchmaking => isVi ? 'Ghép trận tự động' : 'Auto Matchmaking';
  String get autoMatchmakingDesc => isVi ? 'Tự động tìm đối thủ ngẫu nhiên' : 'Find a random opponent automatically';
  String get createRoom => isVi ? 'Tạo phòng riêng' : 'Create Room';
  String get createRoomDesc => isVi ? 'Tạo phòng với mã 6 số và chia sẻ cho bạn bè' : 'Create a room with a 6-digit code and share it';
  String get joinRoom => isVi ? 'Vào phòng riêng' : 'Join Room';
  String get joinRoomDesc => isVi ? 'Nhập mã phòng 6 số để vào đấu với bạn bè' : 'Enter a 6-digit room code to play with a friend';
  String get yourRoomCode => isVi ? 'Mã phòng của bạn:' : 'Your room code:';
  String get waitingForGuest => isVi ? 'Đang chờ đối thủ vào phòng...' : 'Waiting for opponent to join...';
  String get cancelRoom => isVi ? 'Hủy phòng' : 'Cancel Room';
  String get enterRoomCode => isVi ? 'Nhập mã phòng 6 số' : 'Enter 6-digit room code';
  String get roomCodeHint => isVi ? 'Mã 6 chữ số' : '6-digit code';
  String get joinRoomButton => isVi ? 'Vào phòng' : 'Join';
  String get roomNotFound => isVi ? '❌ Không tìm thấy phòng hoặc phòng đã đầy.' : '❌ Room not found or already full.';
  String get roomSelfJoin => isVi ? '❌ Bạn không thể tự vào phòng của mình.' : '❌ You cannot join your own room.';
  String get roomJoinFailed => isVi ? '❌ Không thể vào phòng. Vui lòng thử lại.' : '❌ Could not join the room. Please try again.';
  String get copyCode => isVi ? 'Sao chép' : 'Copy';
  String get codeCopied => isVi ? '📋 Đã sao chép mã phòng!' : '📋 Room code copied!';

  // ─── Emotes ─────────────────────────────────────────────────────────────────
  String get emotesTab => isVi ? 'BIỂU CẢM' : 'EMOTES';
  String get emoteShopTitle => isVi ? 'BIỂU CẢM' : 'EMOTES';
  String get emoteUnlocked => isVi ? '🎉 Đã mở khóa biểu cảm!' : '🎉 Emote unlocked!';
  String get emoteBuyFailed => isVi ? '❌ Mua biểu cảm thất bại. Vui lòng thử lại.' : '❌ Emote purchase failed. Please try again.';
  String get emoteAlreadyOwned => isVi ? 'Biểu cảm này đã được mở khóa.' : 'This emote is already unlocked.';
  String get locked => isVi ? 'Khóa' : 'Locked';
  String get sendEmote => isVi ? 'Gửi biểu cảm' : 'Send Emote';

  // ─── Quick Chat ──────────────────────────────────────────────────────────────
  String get quickChatTab => isVi ? 'CHAT NHANH' : 'QUICK CHAT';
  String get quickChatTitle => isVi ? 'Chat nhanh' : 'Quick Chat';
  List<String> get quickChatMessages => [
    isVi ? 'Chào đối thủ! Chúc may mắn.' : 'Hello opponent! Good luck.',
    isVi ? 'Bạn đánh hay quá!' : 'Nice move!',
    isVi ? 'Chờ tôi một chút nhé...' : 'Give me a second...',
    isVi ? 'Cảm ơn nhé!' : 'Thank you!',
    isVi ? 'Xin lỗi, sơ suất quá!' : 'Sorry, my bad!',
    isVi ? 'Chơi tiếp ván nữa không?' : 'Want to play another round?',
    isVi ? 'Đừng đầu hàng nhé!' : 'Don\'t give up!',
    isVi ? 'Chúc mừng chiến thắng!' : 'Congratulations on your win!',
  ];
}

class LanguageManager {
  static final LanguageManager instance = LanguageManager._internal();
  LanguageManager._internal();

  AppLanguage _currentLanguage = AppLanguage.vi;
  final ValueNotifier<AppLanguage> languageNotifier = ValueNotifier(AppLanguage.vi);

  AppLanguage get currentLanguage => _currentLanguage;
  AppText get text => AppText(_currentLanguage);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language') ?? 'vi';
    _currentLanguage = code == 'en' ? AppLanguage.en : AppLanguage.vi;
    languageNotifier.value = _currentLanguage;
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _currentLanguage = lang;
    languageNotifier.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang.code);
  }
}
