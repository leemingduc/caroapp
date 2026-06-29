import 'dart:convert';

class UserProfile {
  final String id;
  final String email;
  final int diamonds;
  final int winsPvc;
  final int lossesPvc;
  final int draws;
  final List<String> unlockedSkins;
  final List<String> unlockedThemes;
  final String selectedSkin;
  final String selectedTheme;
  final List<String> unlockedEmotes;

  UserProfile({
    required this.id,
    required this.email,
    this.diamonds = 100,
    this.winsPvc = 0,
    this.lossesPvc = 0,
    this.draws = 0,
    this.unlockedSkins = const ['default'],
    this.unlockedThemes = const ['default'],
    this.selectedSkin = 'default',
    this.selectedTheme = 'default',
    this.unlockedEmotes = const ['wave', 'angry', 'laugh'],
  });

  UserProfile copyWith({
    String? id,
    String? email,
    int? diamonds,
    int? winsPvc,
    int? lossesPvc,
    int? draws,
    List<String>? unlockedSkins,
    List<String>? unlockedThemes,
    String? selectedSkin,
    String? selectedTheme,
    List<String>? unlockedEmotes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      diamonds: diamonds ?? this.diamonds,
      winsPvc: winsPvc ?? this.winsPvc,
      lossesPvc: lossesPvc ?? this.lossesPvc,
      draws: draws ?? this.draws,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      selectedSkin: selectedSkin ?? this.selectedSkin,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      unlockedEmotes: unlockedEmotes ?? this.unlockedEmotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'diamonds': diamonds,
      'wins_pvc': winsPvc,
      'losses_pvc': lossesPvc,
      'draws': draws,
      // Encode as JSON strings for consistent Supabase text column serialization
      'unlocked_skins': json.encode(unlockedSkins),
      'unlocked_themes': json.encode(unlockedThemes),
      'selected_skin': selectedSkin,
      'selected_theme': selectedTheme,
      'unlocked_emotes': json.encode(unlockedEmotes),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Helper to safely parse List<String> from dynamic database representations
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is String) {
        try {
          final decoded = json.decode(val);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    final skins = parseList(map['unlocked_skins']);
    final themes = parseList(map['unlocked_themes']);
    final emotes = parseList(map['unlocked_emotes']);

    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      diamonds: map['diamonds'] ?? 100,
      winsPvc: map['wins_pvc'] ?? 0,
      lossesPvc: map['losses_pvc'] ?? 0,
      draws: map['draws'] ?? 0,
      unlockedSkins: skins.isEmpty ? ['default'] : skins,
      unlockedThemes: themes.isEmpty ? ['default'] : themes,
      selectedSkin: map['selected_skin'] ?? 'default',
      selectedTheme: map['selected_theme'] ?? 'default',
      unlockedEmotes: emotes.isEmpty ? ['wave', 'angry', 'laugh'] : emotes,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
