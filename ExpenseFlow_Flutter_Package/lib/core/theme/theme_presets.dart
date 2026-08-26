import 'package:flutter/material.dart';

class PresetThemeData {
  final String id;
  final String name;
  final Color primary;
  final Color accent;
  final Color surfaceDark;
  final Color backgroundDark;
  final String description;

  const PresetThemeData({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.surfaceDark,
    required this.backgroundDark,
    required this.description,
  });
}

class AppThemePresets {
  static const List<PresetThemeData> presets = [
    PresetThemeData(
      id: 'emerald_wealth',
      name: 'Emerald Wealth',
      primary: Color(0xFF0D5C3A),
      accent: Color(0xFF00E676),
      surfaceDark: Color(0xFF0C2417),
      backgroundDark: Color(0xFF05120B),
      description: 'Prestigious deep emerald green with electric mint accents.',
    ),
    PresetThemeData(
      id: 'midnight_sapphire',
      name: 'Midnight Sapphire',
      primary: Color(0xFF0F3460),
      accent: Color(0xFF00F0FF),
      surfaceDark: Color(0xFF0A192F),
      backgroundDark: Color(0xFF020C1B),
      description: 'Modern high-tech navy blue with futuristic cyan glow.',
    ),
    PresetThemeData(
      id: 'obsidian_gold',
      name: 'Obsidian Gold',
      primary: Color(0xFF2C2519),
      accent: Color(0xFFFFD700),
      surfaceDark: Color(0xFF1E1C18),
      backgroundDark: Color(0xFF100F0D),
      description: 'Ultra-luxurious dark obsidian paired with champagne gold.',
    ),
    PresetThemeData(
      id: 'rose_luxury',
      name: 'Rose Luxury',
      primary: Color(0xFF4A154B),
      accent: Color(0xFFFF4081),
      surfaceDark: Color(0xFF2B0E2C),
      backgroundDark: Color(0xFF160517),
      description: 'Opulent deep royal plum accented with vibrant rose shimmer.',
    ),
    PresetThemeData(
      id: 'cyber_amethyst',
      name: 'Cyber Amethyst',
      primary: Color(0xFF3F1D78),
      accent: Color(0xFFBD00FF),
      surfaceDark: Color(0xFF220C47),
      backgroundDark: Color(0xFF0F0422),
      description: 'Neon synthwave violet with electric purple highlights.',
    ),
  ];

  static PresetThemeData getById(String id) {
    return presets.firstWhere(
      (p) => p.id == id,
      orElse: () => presets[0],
    );
  }
}
