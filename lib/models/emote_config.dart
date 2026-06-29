class EmoteConfig {
  final String id;
  final String emoji;
  final String nameVi;
  final String nameEn;
  final int cost; // 0 = miễn phí

  const EmoteConfig({
    required this.id,
    required this.emoji,
    required this.nameVi,
    required this.nameEn,
    required this.cost,
  });

  static const List<EmoteConfig> allEmotes = [
    EmoteConfig(id: 'wave',      emoji: '👋', nameVi: 'Xin chào',   nameEn: 'Wave',      cost: 0),
    EmoteConfig(id: 'angry',     emoji: '😡', nameVi: 'Tức giận',   nameEn: 'Angry',     cost: 0),
    EmoteConfig(id: 'laugh',     emoji: '😄', nameVi: 'Cười',       nameEn: 'Laugh',     cost: 0),
    EmoteConfig(id: 'cry',       emoji: '😭', nameVi: 'Khóc',       nameEn: 'Cry',       cost: 50),
    EmoteConfig(id: 'surprised', emoji: '😲', nameVi: 'Ngạc nhiên', nameEn: 'Surprised', cost: 50),
    EmoteConfig(id: 'love',      emoji: '🥰', nameVi: 'Yêu thương', nameEn: 'Love',      cost: 50),
    EmoteConfig(id: 'cool',      emoji: '😎', nameVi: 'Ngầu',       nameEn: 'Cool',      cost: 50),
    EmoteConfig(id: 'thinking',  emoji: '🤔', nameVi: 'Suy nghĩ',  nameEn: 'Thinking',  cost: 50),
    EmoteConfig(id: 'sleep',     emoji: '😴', nameVi: 'Buồn ngủ',  nameEn: 'Sleepy',    cost: 50),
    EmoteConfig(id: 'wink',      emoji: '😉', nameVi: 'Nháy mắt',  nameEn: 'Wink',      cost: 50),
  ];

  static EmoteConfig getEmote(String id) {
    return allEmotes.firstWhere(
      (e) => e.id == id,
      orElse: () => allEmotes.first,
    );
  }
}
