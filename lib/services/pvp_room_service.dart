import 'dart:math';
import '../supabase_config.dart';

class PvpRoomService {
  /// Tạo phòng mới với mã 6 số ngẫu nhiên, trả về room_code.
  static Future<String> createRoom(String hostId) async {
    final rng = Random.secure();
    while (true) {
      // Tạo mã ngẫu nhiên từ 100000 đến 999999
      final code = (rng.nextInt(900000) + 100000).toString();
      try {
        // Xóa các phòng cũ còn đang chờ của host này
        await supabase
            .from('custom_rooms')
            .delete()
            .eq('host_id', hostId)
            .eq('status', 'waiting');

        await supabase.from('custom_rooms').insert({
          'room_code': code,
          'host_id': hostId,
          'status': 'waiting',
        });
        return code;
      } catch (e) {
        // Nếu trùng room_code thì thử lại
        final msg = e.toString();
        if (!msg.contains('duplicate') && !msg.contains('unique')) rethrow;
      }
    }
  }

  /// Host hủy phòng.
  static Future<void> cancelRoom(String roomCode) async {
    try {
      await supabase
          .from('custom_rooms')
          .update({
            'status': 'closed',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('room_code', roomCode);
    } catch (e) {
      print('cancelRoom failed: $e');
    }
  }

  /// Guest vào phòng theo mã. Gọi RPC join_custom_room.
  /// Trả về map với keys: status ('matched'|'not_found'|'self_join'|'error'),
  /// match_id, role, host_email.
  static Future<Map<String, dynamic>> joinRoom(
    String roomCode,
    String guestId,
    String guestEmail,
  ) async {
    try {
      final response = await supabase.rpc('join_custom_room', params: {
        'p_room_code': roomCode,
        'p_guest_id': guestId,
        'p_guest_email': guestEmail,
      });
      if (response is Map) return Map<String, dynamic>.from(response);
      return {'status': 'error'};
    } catch (e) {
      print('joinRoom failed: $e');
      return {'status': 'error'};
    }
  }
}
