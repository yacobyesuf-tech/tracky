import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_presets.dart';
import '../../core/theme/glass_container.dart';
import '../../core/services/haptic_service.dart';

class ThemeCustomizerScreen extends StatefulWidget {
  const ThemeCustomizerScreen({super.key});

  @override
  State<ThemeCustomizerScreen> createState() => _ThemeCustomizerScreenState();
}

class _ThemeCustomizerScreenState extends State<ThemeCustomizerScreen> {
  Color _tempPrimary = const Color(0xFF0D5C3A);
  Color _tempAccent = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<ThemeProvider>(context, listen: false);
    _tempPrimary = prov.primaryColor;
    _tempAccent = prov.accentColor;
  }

  void _openColorPicker({required bool isPrimary}) {
    HapticService.lightImpact();
    Color currentColor = isPrimary ? _tempPrimary : _tempAccent;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isPrimary ? 'Pick Primary Brand Color' : 'Pick Accent Glow Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                setState(() {
                  if (isPrimary) {
                    _tempPrimary = color;
                  } else {
                    _tempAccent = color;
                  }
                });
              },
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                HapticService.mediumImpact();
                final prov = Provider.of<ThemeProvider>(context, listen: false);
                prov.setCustomColors(primary: _tempPrimary, accent: _tempAccent);
                Navigator.pop(ctx);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Aesthetics'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // Dark / Light Mode Switch
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: themeProv.accentColor,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Dark Mode (OLED Glass)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: themeProv.isDarkMode,
                  activeColor: themeProv.accentColor,
                  onChanged: (val) {
                    HapticService.selectionClick();
                    themeProv.toggleDarkMode(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Live Interactive Glass Preview Card
          Text(
            'Live Preview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          GlassContainer(
            borderRadius: 22,
            padding: const EdgeInsets.all(20),
            customColor: themeProv.primaryColor,
            opacity: 0.25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: themeProv.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          themeProv.isCustomTheme ? 'Custom Palette' : themeProv.activePreset.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeProv.accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Instant 60fps Dynamic Surface Rendering',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeProv.primaryColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Primary: #',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeProv.accentColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Accent: #',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Custom Theme Creator Section
          Text(
            'Custom Theme Creator',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select arbitrary Primary and Accent colors to generate a bespoke UI theme.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openColorPicker(isPrimary: true),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: themeProv.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Primary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Tap to edit', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _openColorPicker(isPrimary: false),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: themeProv.accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Accent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Tap to edit', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 5 Professional Preset Themes
          Text(
            'Professional Presets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppThemePresets.presets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final preset = AppThemePresets.presets[index];
              final isSelected = !themeProv.isCustomTheme && themeProv.activePreset.id == preset.id;

              return InkWell(
                onTap: () {
                  HapticService.mediumImpact();
                  themeProv.setPreset(preset);
                },
                borderRadius: BorderRadius.circular(18),
                child: GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(16),
                  border: isSelected
                      ? Border.all(color: preset.accent, width: 2)
                      : null,
                  child: Row(
                    children: [
                      // Preset Color Pair Indicators
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: preset.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(-8, 0),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: preset.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? Colors.black : Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              preset.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: preset.accent, size: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
