import 'package:flutter/material.dart';

class SkinConfig {
  final String id;
  final String name;
  final int cost;
  final Color xColor;
  final Color oColor;
  final List<Shadow> xShadow;
  final List<Shadow> oShadow;
  final String emoji;

  SkinConfig({
    required this.id,
    required this.name,
    required this.cost,
    required this.xColor,
    required this.oColor,
    required this.xShadow,
    required this.oShadow,
    required this.emoji,
  });

  static final List<SkinConfig> allSkins = [
    SkinConfig(
      id: 'default',
      name: 'Neon mặc định',
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
  ];

  static SkinConfig getSkin(String id) {
    return allSkins.firstWhere((s) => s.id == id, orElse: () => allSkins.first);
  }
}

class ThemeConfig {
  final String id;
  final String name;
  final int cost;
  final List<Color> bgGradient;
  final Color boardBg;
  final Color gridLineColor;
  final Color boardBorderColor;
  final String emoji;

  ThemeConfig({
    required this.id,
    required this.name,
    required this.cost,
    required this.bgGradient,
    required this.boardBg,
    required this.gridLineColor,
    required this.boardBorderColor,
    required this.emoji,
  });

  static final List<ThemeConfig> allThemes = [
    ThemeConfig(
      id: 'default',
      name: 'Dark Slate',
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
      name: 'Cyberpunk Grid',
      cost: 200,
      emoji: '⚡',
      bgGradient: [
        const Color(0xFF1A0B2E),
        const Color(0xFF0F051D),
        const Color(0xFF05000A),
      ],
      boardBg: const Color(0xFF220A3E).withOpacity(0.85),
      gridLineColor: const Color(0xFFFF007F).withOpacity(0.2), // Neon Pink
      boardBorderColor: const Color(0xFF39FF14), // Neon Green
    ),
    ThemeConfig(
      id: 'wood',
      name: 'Gỗ cổ điển',
      cost: 150,
      emoji: '🪵',
      bgGradient: [
        const Color(0xFF3E2723),
        const Color(0xFF4E342E),
        const Color(0xFF2D1500),
      ],
      boardBg: const Color(0xFF8B4513).withOpacity(0.9), // SaddleBrown
      gridLineColor: const Color(0xFF5C2C16).withOpacity(0.4),
      boardBorderColor: const Color(0xFFD2B48C), // Tan wood border
    ),
    ThemeConfig(
      id: 'sakura',
      name: 'Hoa anh đào',
      cost: 180,
      emoji: '🌸',
      bgGradient: [
        const Color(0xFF2A1B24),
        const Color(0xFF1E1219),
        const Color(0xFF11080D),
      ],
      boardBg: const Color(0xFF421C2B).withOpacity(0.9), // Deep rosewood
      gridLineColor: const Color(0xFFFFC0CB).withOpacity(0.25), // Pink line
      boardBorderColor: const Color(0xFFFFB6C1), // Light pink border
    ),
  ];

  static ThemeConfig getTheme(String id) {
    return allThemes.firstWhere((t) => t.id == id, orElse: () => allThemes.first);
  }
}
