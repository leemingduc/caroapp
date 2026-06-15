import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../supabase_config.dart';

class DbService {
  static const String _profileCacheKeyPrefix = 'caro_arena_profile_';

  static Future<void> _cacheProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_profileCacheKeyPrefix${profile.id}',
      profile.toJson(),
    );
  }

  static Map<String, dynamic> _profilePayload(UserProfile profile) {
    return {
      ...profile.toMap(),
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static Future<void> _touchProfile(String userId, String email) async {
    try {
      await supabase
          .from('profiles')
          .update({
            'email': email,
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      print('Supabase touch profile failed: $e');
    }
  }

  /// Fetch user profile from Supabase with SharedPreferences cache as fallback
  static Future<UserProfile> getProfile(String userId, String email) async {
    final cacheKey = '$_profileCacheKeyPrefix$userId';
    final prefs = await SharedPreferences.getInstance();

    // 1. Try to fetch from Supabase
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final profile = UserProfile.fromMap(response);
        // Cache locally
        await _cacheProfile(profile);
        await _touchProfile(userId, email);
        return profile;
      } else {
        // Profile not found in remote DB, let's create a new one
        final newProfile = UserProfile(id: userId, email: email);
        await saveProfile(newProfile);
        return newProfile;
      }
    } catch (e) {
      print('Supabase fetch failed, falling back to local cache: $e');
      
      // 2. Fallback to local cache
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        try {
          return UserProfile.fromJson(cachedJson);
        } catch (_) {}
      }
      
      // 3. Fallback to default profile if cache is empty
      return UserProfile(id: userId, email: email);
    }
  }

  /// Save user profile to both SharedPreferences cache and Supabase (non-blocking for UI)
  static Future<bool> saveProfile(UserProfile profile) async {
    // 1. Save locally first (immediate responsiveness)
    try {
      await _cacheProfile(profile);
    } catch (e) {
      print('Local cache save failed: $e');
      return false;
    }

    // 2. Try to sync to Supabase with 1 retry
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        await supabase.from('profiles').upsert(
              _profilePayload(profile),
              onConflict: 'id',
            );
        return true; // Both local + remote succeeded
      } catch (e) {
        print('Supabase upsert attempt ${attempt + 1} failed: $e');
        if (attempt == 0) {
          try {
            await supabase.from('profiles').upsert(
                  profile.toMap(),
                  onConflict: 'id',
                );
            return true;
          } catch (_) {}
        }
        if (attempt == 0) {
          // Wait briefly before retry
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    // Local save succeeded even if remote failed
    return true;
  }

  /// Atomically records a PvC match in Supabase, updates profile counters, and
  /// stores a history row for audit/leaderboard rebuilds.
  static Future<UserProfile?> recordPvcMatch({
    required String userId,
    required String email,
    required String outcome,
    required String aiDifficulty,
    required int boardSize,
    required int winLength,
    required int movesCount,
  }) async {
    try {
      final response = await supabase.rpc(
        'record_pvc_match',
        params: {
          'p_user_id': userId,
          'p_email': email,
          'p_outcome': outcome,
          'p_ai_difficulty': aiDifficulty,
          'p_board_size': boardSize,
          'p_win_length': winLength,
          'p_moves_count': movesCount,
        },
      );

      final Map<String, dynamic>? profileMap;
      if (response is Map<String, dynamic>) {
        profileMap = response;
      } else if (response is List && response.isNotEmpty) {
        profileMap = Map<String, dynamic>.from(response.first as Map);
      } else {
        profileMap = null;
      }

      if (profileMap == null) return null;

      return UserProfile.fromMap(profileMap);
    } catch (e) {
      print('Failed to record PvC match: $e');
      return null;
    }
  }

  static Future<void> savePvcMatchHistory({
    required String userId,
    required String email,
    required String outcome,
    required String aiDifficulty,
    required int boardSize,
    required int winLength,
    required int movesCount,
    required int diamondDelta,
    required int diamondsAfter,
    required int winsPvcAfter,
  }) async {
    try {
      await supabase.from('pvc_match_history').insert({
        'user_id': userId,
        'email': email,
        'outcome': outcome,
        'ai_difficulty': aiDifficulty,
        'board_size': boardSize,
        'win_length': winLength,
        'moves_count': movesCount,
        'diamond_delta': diamondDelta,
        'diamonds_after': diamondsAfter,
        'wins_pvc_after': winsPvcAfter,
      });
    } catch (e) {
      print('Failed to save PvC match history fallback: $e');
    }
  }

  /// Realtime diamond leaderboard.
  static Stream<List<Map<String, dynamic>>> getLeaderboardStream() {
    return supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('diamonds', ascending: false)
        .order('wins_pvc', ascending: false)
        .limit(10)
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  /// Get leaderboard from Supabase, or mock leaderboard if failed
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('email, diamonds, wins_pvc')
          .order('diamonds', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to load online leaderboard: $e');
    }

    // Fallback: Mock leaderboard (premium bots)
    return [
      {'email': 'AlphaCaro_Bot 🤖', 'diamonds': 9999, 'wins_pvc': 420},
      {'email': 'ProMasterCaro 🏆', 'diamonds': 2500, 'wins_pvc': 188},
      {'email': 'GomokuKing 👑', 'diamonds': 1800, 'wins_pvc': 120},
      {'email': 'Caroliner_AI ⚡', 'diamonds': 1200, 'wins_pvc': 85},
      {'email': 'DeepCaro 🧠', 'diamonds': 950, 'wins_pvc': 62},
      {'email': 'NewbieCaroPlayer', 'diamonds': 100, 'wins_pvc': 0},
    ];
  }
}
