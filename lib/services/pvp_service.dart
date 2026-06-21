import 'dart:math';
import '../supabase_config.dart';

class PvpService {
  /// Tham gia hàng đợi ghép trận hoặc kết nối với đối thủ đang chờ sẵn
  /// Trả về một Map chứa: { match_id, status, role, opponent_email }
  static Future<Map<String, dynamic>> joinMatchmaking({
    required String userId,
    required String email,
    required int boardSize,
    required int winLength,
  }) async {
    try {
      final response = await supabase.rpc(
        'join_matchmaking',
        params: {
          'p_user_id': userId,
          'p_email': email,
          'p_board_size': boardSize,
          'p_win_length': winLength,
        },
      );
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return {'status': 'waiting', 'match_id': null, 'role': 'X', 'opponent_email': null};
    } catch (e) {
      print('joinMatchmaking failed: $e');
      return {'status': 'error', 'match_id': null, 'role': 'X', 'opponent_email': null, 'error': e.toString()};
    }
  }

  /// Hủy tìm trận, xóa người dùng khỏi hàng đợi ghép trận
  static Future<void> cancelMatchmaking(String userId) async {
    try {
      await supabase
          .from('matchmaking_queue')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('cancelMatchmaking failed: $e');
    }
  }

  /// Lấy thông tin hàng đợi ghép trận hiện tại của người dùng
  static Future<Map<String, dynamic>?> getQueueStatus(String userId) async {
    try {
      final data = await supabase
          .from('matchmaking_queue')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      print('getQueueStatus failed: $e');
      return null;
    }
  }

  /// Gửi nước đi lên Supabase
  static Future<void> makeMove({
    required String matchId,
    required String userId,
    required Map<Point<int>, String> board,
    required bool nextIsXTurn,
    required String? winner,
    required Point<int>? lastMove,
  }) async {
    try {
      // Chuyển đổi board từ Map<Point<int>, String> sang Map<String, String> để lưu JSONB
      final Map<String, String> dbBoard = {};
      board.forEach((point, mark) {
        dbBoard['${point.x},${point.y}'] = mark;
      });

      final String? lastMoveStr = lastMove != null ? '${lastMove.x},${lastMove.y}' : null;

      await supabase.rpc(
        'make_pvp_move',
        params: {
          'p_match_id': matchId,
          'p_user_id': userId,
          'p_board': dbBoard,
          'p_is_x_turn': nextIsXTurn,
          'p_winner': winner,
          'p_last_move': lastMoveStr,
        },
      );
    } catch (e) {
      print('makeMove failed: $e');
    }
  }

  /// Tổng kết trận đấu, cộng 20 Kim cương 💎 cho người thắng và cập nhật thống kê
  static Future<void> recordMatchResult({
    required String matchId,
    required String winnerId,
    required String loserId,
    required bool isDraw,
  }) async {
    try {
      await supabase.rpc(
        'record_pvp_match_result',
        params: {
          'p_match_id': matchId,
          'p_winner_id': winnerId,
          'p_loser_id': loserId,
          'p_is_draw': isDraw,
        },
      );
    } catch (e) {
      print('recordMatchResult failed: $e');
    }
  }

  /// Truy vấn thông tin trận đấu hiện tại (dùng làm fallback đồng bộ)
  static Future<Map<String, dynamic>?> getMatch(String matchId) async {
    try {
      final response = await supabase
          .from('pvp_matches')
          .select()
          .eq('id', matchId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('getMatch failed: $e');
      return null;
    }
  }
}
