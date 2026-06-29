import '../supabase_config.dart';

class FriendsService {
  /// Tìm kiếm profile theo email (khớp chính xác).
  static Future<Map<String, dynamic>?> findProfileByEmail(String email) async {
    try {
      final result = await supabase
          .from('profiles')
          .select('id, email, last_seen_at')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();
      return result;
    } catch (e) {
      print('findProfileByEmail failed: $e');
      return null;
    }
  }

  /// Gửi lời mời kết bạn từ [userId] tới người dùng có email [friendEmail].
  /// Trả về: 'sent' | 'exists' | 'not_found' | 'self' | 'error'
  static Future<String> sendRequest(String userId, String friendEmail) async {
    try {
      final target = await findProfileByEmail(friendEmail);
      if (target == null) return 'not_found';

      final friendId = target['id'] as String;
      if (friendId == userId) return 'self';

      await supabase.from('friends').insert({
        'user_id': userId,
        'friend_id': friendId,
        'status': 'pending',
      });
      return 'sent';
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('unique_friendship') || msg.contains('duplicate')) {
        return 'exists';
      }
      print('sendRequest failed: $e');
      return 'error';
    }
  }

  /// Trả về danh sách tất cả bạn bè đã được chấp nhận của [userId].
  /// Mỗi phần tử chứa: relationship_id, id, email, last_seen_at.
  static Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    try {
      // Truy vấn khi user là người gửi lời mời (user_id = userId)
      final sentRows = await supabase
          .from('friends')
          .select('id, friend_id')
          .eq('user_id', userId)
          .eq('status', 'accepted');

      // Truy vấn khi user là người nhận lời mời (friend_id = userId)
      final receivedRows = await supabase
          .from('friends')
          .select('id, user_id')
          .eq('friend_id', userId)
          .eq('status', 'accepted');

      final List<Map<String, dynamic>> result = [];

      for (final row in (sentRows as List)) {
        final profile = await supabase
            .from('profiles')
            .select('id, email, last_seen_at')
            .eq('id', row['friend_id'] as String)
            .maybeSingle();
        if (profile != null) {
          result.add({
            'relationship_id': row['id'],
            'id': row['friend_id'],
            'email': profile['email'],
            'last_seen_at': profile['last_seen_at'],
          });
        }
      }

      for (final row in (receivedRows as List)) {
        final profile = await supabase
            .from('profiles')
            .select('id, email, last_seen_at')
            .eq('id', row['user_id'] as String)
            .maybeSingle();
        if (profile != null) {
          result.add({
            'relationship_id': row['id'],
            'id': row['user_id'],
            'email': profile['email'],
            'last_seen_at': profile['last_seen_at'],
          });
        }
      }

      return result;
    } catch (e) {
      print('getFriends failed: $e');
      return [];
    }
  }

  /// Trả về danh sách lời mời kết bạn đang chờ chấp nhận của [userId] (là người nhận).
  static Future<List<Map<String, dynamic>>> getPendingReceived(
      String userId) async {
    try {
      final rows = await supabase
          .from('friends')
          .select('id, user_id')
          .eq('friend_id', userId)
          .eq('status', 'pending');

      final List<Map<String, dynamic>> result = [];
      for (final row in (rows as List)) {
        final profile = await supabase
            .from('profiles')
            .select('id, email')
            .eq('id', row['user_id'] as String)
            .maybeSingle();
        if (profile != null) {
          result.add({
            'relationship_id': row['id'],
            'id': row['user_id'],
            'email': profile['email'],
          });
        }
      }
      return result;
    } catch (e) {
      print('getPendingReceived failed: $e');
      return [];
    }
  }

  /// Chấp nhận lời mời kết bạn. [requestId] là `friends.id`.
  static Future<bool> acceptRequest(String requestId) async {
    try {
      await supabase
          .from('friends')
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);
      return true;
    } catch (e) {
      print('acceptRequest failed: $e');
      return false;
    }
  }

  /// Xóa bất kỳ mối quan hệ bạn bè nào theo id.
  static Future<bool> removeRelationship(String relationshipId) async {
    try {
      await supabase.from('friends').delete().eq('id', relationshipId);
      return true;
    } catch (e) {
      print('removeRelationship failed: $e');
      return false;
    }
  }
}
