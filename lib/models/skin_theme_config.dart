import 'package:flutter/material.dart';

import '../app_language.dart';

class SkinConfig {
  final String id;
  final String name;
  final String englishName;
  final int cost;
  final Color xColor;
  final Color oColor;
  final List<Shadow> xShadow;
  final List<Shadow> oShadow;
  final String emoji;

  SkinConfig({
    required this.id,
    required this.name,
    required this.englishName,
    required this.cost,
    required this.xColor,
    required this.oColor,
    required this.xShadow,
    required this.oShadow,
    required this.emoji,
  });

  String displayName(AppLanguage language) {
    return language == AppLanguage.vi ? name : englishName;
  }

  static final List<SkinConfig> allSkins = [
    SkinConfig(
      id: 'default',
      name: 'Neon mặc định',
      englishName: 'Default Neon',
      cost: 0,
      emoji: '🎮',
      xColor: const Color(0xFF00F2FE),
      oColor: const Color(0xFFF43F5E),
      xShadow: [
        const Shadow(color: Color(0xFF00F2FE), blurRadius: 8),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFF43F5E), blurRadius: 8),
      ],
    ),
    SkinConfig(
      id: 'gold',
      name: 'Vàng hoàng kim',
      englishName: 'Royal Gold',
      cost: 150,
      emoji: '👑',
      xColor: const Color(0xFFFFD700),
      oColor: const Color(0xFFFFA500),
      xShadow: [
        const Shadow(color: Color(0xFFFFD700), blurRadius: 14),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFFFA500), blurRadius: 14),
      ],
    ),
    SkinConfig(
      id: 'volcano',
      name: 'Hỏa ngục magma',
      englishName: 'Magma Inferno',
      cost: 120,
      emoji: '🔥',
      xColor: const Color(0xFFFF4500),
      oColor: const Color(0xFFFF0000),
      xShadow: [
        const Shadow(color: Color(0xFFFF4500), blurRadius: 12),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFFF0000), blurRadius: 12),
      ],
    ),
    SkinConfig(
      id: 'ocean',
      name: 'Xanh đại dương',
      englishName: 'Ocean Blue',
      cost: 100,
      emoji: '🌊',
      xColor: const Color(0xFF00BFFF),
      oColor: const Color(0xFF0000FF),
      xShadow: [
        const Shadow(color: Color(0xFF00BFFF), blurRadius: 12),
      ],
      oShadow: [
        const Shadow(color: Color(0xFF0000FF), blurRadius: 12),
      ],
    ),
    SkinConfig(
      id: 'cosmic',
      name: 'Tinh vân Cosmic',
      englishName: 'Cosmic Nebula',
      cost: 200,
      emoji: '🌌',
      xColor: const Color(0xFFE040FB),
      oColor: const Color(0xFF00E5FF),
      xShadow: [
        const Shadow(color: Color(0xFFE040FB), blurRadius: 12),
      ],
      oShadow: [
        const Shadow(color: Color(0xFF00E5FF), blurRadius: 12),
      ],
    ),
    SkinConfig(
      id: 'retro',
      name: 'Điện tử Retro',
      englishName: 'Retro Arcade',
      cost: 120,
      emoji: '👾',
      xColor: const Color(0xFF39FF14),
      oColor: const Color(0xFFFF5722),
      xShadow: [
        const Shadow(color: Color(0xFF39FF14), blurRadius: 8),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFFF5722), blurRadius: 8),
      ],
    ),
    SkinConfig(
      id: 'sakura',
      name: 'Anh đào Sakura',
      englishName: 'Sakura Blossom',
      cost: 160,
      emoji: '🌸',
      xColor: const Color(0xFFFFB7B2),
      oColor: const Color(0xFFFFC6FF),
      xShadow: [
        const Shadow(color: Color(0xFFFFB7B2), blurRadius: 10),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFFFC6FF), blurRadius: 10),
      ],
    ),
    SkinConfig(
      id: 'ice',
      name: 'Băng tinh Tuyết',
      englishName: 'Ice Crystal',
      cost: 140,
      emoji: '❄️',
      xColor: const Color(0xFFE0F7FA),
      oColor: const Color(0xFF80DEEA),
      xShadow: [
        const Shadow(color: Color(0xFF80DEEA), blurRadius: 12),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFE0F7FA), blurRadius: 12),
      ],
    ),
    SkinConfig(
      id: 'emerald',
      name: 'Lục bảo Rừng xanh',
      englishName: 'Emerald Forest',
      cost: 130,
      emoji: '🍃',
      xColor: const Color(0xFF00E676),
      oColor: const Color(0xFF1DE9B6),
      xShadow: [
        const Shadow(color: Color(0xFF00E676), blurRadius: 10),
      ],
      oShadow: [
        const Shadow(color: Color(0xFF1DE9B6), blurRadius: 10),
      ],
    ),
    SkinConfig(
      id: 'cyberpunk',
      name: 'Neon Cyberpunk',
      englishName: 'Cyberpunk Neon',
      cost: 180,
      emoji: '⚡',
      xColor: const Color(0xFFFF007F),
      oColor: const Color(0xFFFFFF00),
      xShadow: [
        const Shadow(color: Color(0xFFFF007F), blurRadius: 14),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFFFFF00), blurRadius: 14),
      ],
    ),
    SkinConfig(
      id: 'amethyst',
      name: 'Thạch anh Tím',
      englishName: 'Royal Amethyst',
      cost: 220,
      emoji: '🔮',
      xColor: const Color(0xFFD500F9),
      oColor: const Color(0xFF7C4DFF),
      xShadow: [
        const Shadow(color: Color(0xFFD500F9), blurRadius: 14),
      ],
      oShadow: [
        const Shadow(color: Color(0xFF7C4DFF), blurRadius: 14),
      ],
    ),
    SkinConfig(
      id: 'solar',
      name: 'Thái dương Hào quang',
      englishName: 'Solar Flare',
      cost: 250,
      emoji: '☀️',
      xColor: const Color(0xFFFFD600),
      oColor: const Color(0xFFFF6D00),
      xShadow: [
        const Shadow(color: Color(0xFFFFD600), blurRadius: 16),
      ],
      oShadow: [
        const Shadow(color: Color(0xFFFF6D00), blurRadius: 16),
      ],
    ),
  ];

  static SkinConfig getSkin(String id) {
    return allSkins.firstWhere((s) => s.id == id, orElse: () => allSkins.first);
  }
}

class ThemeConfig {
  final String id;
  final String name;
  final String englishName;
  final int cost;
  final List<Color> bgGradient;
  final Color boardBg;
  final Color gridLineColor;
  final Color boardBorderColor;
  final String emoji;

  ThemeConfig({
    required this.id,
    required this.name,
    required this.englishName,
    required this.cost,
    required this.bgGradient,
    required this.boardBg,
    required this.gridLineColor,
    required this.boardBorderColor,
    required this.emoji,
  });

  String displayName(AppLanguage language) {
    return language == AppLanguage.vi ? name : englishName;
  }

  static final List<ThemeConfig> allThemes = [
    ThemeConfig(
      id: 'default',
      name: 'Đá phiến tối',
      englishName: 'Dark Slate',
      cost: 0,
      emoji: '🌌',
      bgGradient: [
        const Color(0xFF0F172A),
        const Color(0xFF1E293B),
        const Color(0xFF020617),
      ],
      boardBg: const Color(0xFF0F172A).withOpacity(0.85),
      gridLineColor: Colors.white.withOpacity(0.06),
      boardBorderColor: Colors.white.withOpacity(0.12),
    ),
    ThemeConfig(
      id: 'cyberpunk',
      name: 'Lưới cyberpunk',
      englishName: 'Cyberpunk Grid',
      cost: 200,
      emoji: '⚡',
      bgGradient: [
        const Color(0xFF1A0B2E),
        const Color(0xFF0F051D),
        const Color(0xFF05000A),
      ],
      boardBg: const Color(0xFF220A3E).withOpacity(0.85),
      gridLineColor: const Color(0xFFFF007F).withOpacity(0.2),
      boardBorderColor: const Color(0xFF39FF14),
    ),
    ThemeConfig(
      id: 'wood',
      name: 'Gỗ cổ điển',
      englishName: 'Classic Wood',
      cost: 150,
      emoji: '🪵',
      bgGradient: [
        const Color(0xFF3E2723),
        const Color(0xFF4E342E),
        const Color(0xFF2D1500),
      ],
      boardBg: const Color(0xFF8B4513).withOpacity(0.9),
      gridLineColor: const Color(0xFF5C2C16).withOpacity(0.4),
      boardBorderColor: const Color(0xFFD2B48C),
    ),
    ThemeConfig(
      id: 'sakura',
      name: 'Hoa anh đào',
      englishName: 'Sakura',
      cost: 180,
      emoji: '🌸',
      bgGradient: [
        const Color(0xFF2A1B24),
        const Color(0xFF1E1219),
        const Color(0xFF11080D),
      ],
      boardBg: const Color(0xFF421C2B).withOpacity(0.9),
      gridLineColor: const Color(0xFFFFC0CB).withOpacity(0.25),
      boardBorderColor: const Color(0xFFFFB6C1),
    ),
    ThemeConfig(
      id: 'cosmic_nebula',
      name: 'Vũ trụ Cosmic',
      englishName: 'Cosmic Nebula',
      cost: 220,
      emoji: '🌌',
      bgGradient: [
        const Color(0xFF090514),
        const Color(0xFF180A2B),
        const Color(0xFF020105),
      ],
      boardBg: const Color(0xFF120822).withOpacity(0.85),
      gridLineColor: const Color(0xFFE040FB).withOpacity(0.18),
      boardBorderColor: const Color(0xFF00E5FF),
    ),
    ThemeConfig(
      id: 'ice_cave',
      name: 'Động băng Lạnh',
      englishName: 'Ice Cave',
      cost: 160,
      emoji: '🏔️',
      bgGradient: [
        const Color(0xFF0A192F),
        const Color(0xFF0D253F),
        const Color(0xFF050E1A),
      ],
      boardBg: const Color(0xFF0F2B48).withOpacity(0.85),
      gridLineColor: const Color(0xFF80DEEA).withOpacity(0.2),
      boardBorderColor: const Color(0xFFE0F7FA),
    ),
    ThemeConfig(
      id: 'emerald_jade',
      name: 'Lục bảo Hoàng gia',
      englishName: 'Royal Emerald',
      cost: 150,
      emoji: '❇️',
      bgGradient: [
        const Color(0xFF051C12),
        const Color(0xFF0A2E1E),
        const Color(0xFF010604),
      ],
      boardBg: const Color(0xFF0C3825).withOpacity(0.88),
      gridLineColor: const Color(0xFF1DE9B6).withOpacity(0.2),
      boardBorderColor: const Color(0xFF00E676),
    ),
    ThemeConfig(
      id: 'retro_arcade',
      name: 'Lưới Retro Arcade',
      englishName: 'Retro Grid',
      cost: 140,
      emoji: '🕹️',
      bgGradient: [
        const Color(0xFF08020F),
        const Color(0xFF140526),
        const Color(0xFF000000),
      ],
      boardBg: const Color(0xFF1A0A33).withOpacity(0.85),
      gridLineColor: const Color(0xFF39FF14).withOpacity(0.18),
      boardBorderColor: const Color(0xFFFF5722),
    ),
    ThemeConfig(
      id: 'golden_sunset',
      name: 'Hoàng hôn Vàng',
      englishName: 'Golden Sunset',
      cost: 180,
      emoji: '🌇',
      bgGradient: [
        const Color(0xFF240A00),
        const Color(0xFF3E1500),
        const Color(0xFF100000),
      ],
      boardBg: const Color(0xFF501E03).withOpacity(0.9),
      gridLineColor: const Color(0xFFFFD600).withOpacity(0.2),
      boardBorderColor: const Color(0xFFFF6D00),
    ),
  ];

  static ThemeConfig getTheme(String id) {
    return allThemes.firstWhere((t) => t.id == id, orElse: () => allThemes.first);
  }
}
