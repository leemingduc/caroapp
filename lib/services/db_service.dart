import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../supabase_config.dart';

class DbService {
  static const String _profileCacheKeyPrefix = 'caro_arena_profile_';

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
        await prefs.setString(cacheKey, profile.toJson());
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
    final cacheKey = '$_profileCacheKeyPrefix${profile.id}';

    // 1. Save locally first (immediate responsiveness)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, profile.toJson());
    } catch (e) {
      print('Local cache save failed: $e');
      return false;
    }

    // 2. Try to sync to Supabase with 1 retry
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        await supabase.from('profiles').upsert(profile.toMap());
        return true; // Both local + remote succeeded
      } catch (e) {
        print('Supabase upsert attempt ${attempt + 1} failed: $e');
        if (attempt == 0) {
          // Wait briefly before retry
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    // Local save succeeded even if remote failed
    return true;
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
