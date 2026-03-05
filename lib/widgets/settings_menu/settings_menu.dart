import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/settings_service.dart';
import '../debug_panel.dart';
import '../../services/game_service.dart';
import '../../services/save_service.dart';
import '../../services/auto_save_service.dart';
import '../../services/tutorial_service.dart';
import '../../services/achievement_service.dart';
import '../../services/notification_service.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';
import '../../l10n/app_localizations.dart';

/// Settings menu drawer
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        final theme = settings.currentTheme;
        final l10n = AppLocalizations.of(context);

        return Drawer(
          backgroundColor: theme.background,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: theme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        l10n.settings,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Theme Section
                      _SectionHeader(
                        icon: Icons.palette,
                        title: l10n.theme,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),

                      // Dark themes
                      _SubSectionTitle(title: l10n.darkThemes, theme: theme),
                      const SizedBox(height: 8),
                      _ThemeGrid(
                        themes: AppThemes.darkThemes,
                        currentThemeId: settings.currentThemeId,
                        onSelect: (id) => settings.setTheme(id),
                        theme: theme,
                      ),

                      const SizedBox(height: 16),

                      // Light themes
                      _SubSectionTitle(title: l10n.lightThemes, theme: theme),
                      const SizedBox(height: 8),
                      _ThemeGrid(
                        themes: AppThemes.lightThemes,
                        currentThemeId: settings.currentThemeId,
                        onSelect: (id) => settings.setTheme(id),
                        theme: theme,
                      ),

                      const SizedBox(height: 24),

                      // Language Section
                      _SectionHeader(
                        icon: Icons.language,
                        title: l10n.language,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _LanguageSelector(
                        languages: settings.availableLanguages,
                        currentLanguage: settings.currentLanguage,
                        onSelect: (code) => settings.setLanguage(code),
                        theme: theme,
                      ),

                      const SizedBox(height: 24),

                      // Display Section
                      _SectionHeader(
                        icon: Icons.display_settings,
                        title: l10n.get('display'),
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _FullscreenToggle(
                        isFullscreen: settings.isFullscreen,
                        onToggle: () => settings.toggleFullscreen(),
                        theme: theme,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 8),
                      Consumer<SoundService>(
                        builder: (context, sound, _) {
                          return GestureDetector(
                            onTap: () => sound.toggleSound(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: theme.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    sound.enabled ? Icons.volume_up : Icons.volume_off,
                                    color: theme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.get('sound'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: sound.enabled,
                                    onChanged: (_) => sound.toggleSound(),
                                    activeThumbColor: theme.primary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Expert Mode toggle
                      GestureDetector(
                        onTap: () => settings.toggleExpertMode(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                settings.expertMode ? Icons.analytics : Icons.analytics_outlined,
                                color: theme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.get('expert_mode'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      l10n.get('expert_mode_desc'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings.expertMode,
                                onChanged: (_) => settings.toggleExpertMode(),
                                activeThumbColor: theme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Notifications Section
                      _SectionHeader(
                        icon: Icons.notifications,
                        title: l10n.get('notifications'),
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      Consumer<GameService>(
                        builder: (context, game, _) {
                          return _PriceAlertThresholdSlider(
                            theme: theme,
                            l10n: l10n,
                            value: game.priceAlertThreshold,
                            onChanged: game.setPriceAlertThreshold,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Save/Load Section
                      _SectionHeader(
                        icon: Icons.save,
                        title: '${l10n.save} / ${l10n.load}',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _SaveLoadButtons(theme: theme, l10n: l10n),

                      const SizedBox(height: 24),

                      // Game Section
                      _SectionHeader(
                        icon: Icons.sports_esports,
                        title: l10n.get('game'),
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _GiveUpButton(theme: theme, l10n: l10n),

                      const SizedBox(height: 24),

                      // Tutorial Section
                      _SectionHeader(
                        icon: Icons.school,
                        title: 'Tutorial',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _RestartTutorialButton(theme: theme, l10n: l10n),

                      // Debug panel (only in debug builds)
                      if (DebugPanel.enabled) ...[
                        const SizedBox(height: 24),
                        _SectionHeader(
                          icon: Icons.bug_report,
                          title: 'Debug',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        _ActionButton(
                          icon: Icons.bug_report,
                          label: 'Open Debug Panel',
                          color: theme.negative,
                          theme: theme,
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DebugPanel()),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final AppThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: theme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.primary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SubSectionTitle extends StatelessWidget {
  final String title;
  final AppThemeData theme;

  const _SubSectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: theme.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  final List<AppThemeData> themes;
  final String currentThemeId;
  final Function(String) onSelect;
  final AppThemeData theme;

  const _ThemeGrid({
    required this.themes,
    required this.currentThemeId,
    required this.onSelect,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: themes.map((t) {
        final isSelected = t.id == currentThemeId;
        return GestureDetector(
          onTap: () => onSelect(t.id),
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? t.primary.withValues(alpha: 0.2) : theme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? t.primary : theme.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                // Color preview
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [t.primary, t.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: t.border,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      t.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.name,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? t.primary : theme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final List<LanguageOption> languages;
  final String currentLanguage;
  final Function(String) onSelect;
  final AppThemeData theme;

  const _LanguageSelector({
    required this.languages,
    required this.currentLanguage,
    required this.onSelect,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: languages.map((lang) {
        final isSelected = lang.code == currentLanguage;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(lang.code),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? theme.primary.withValues(alpha: 0.2) : theme.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? theme.primary : theme.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    lang.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.primary : theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SaveLoadButtons extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _SaveLoadButtons({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Export button
        _ActionButton(
          icon: Icons.upload_file,
          label: l10n.exportSave,
          color: theme.cyan,
          theme: theme,
          onTap: () => _exportSave(context),
        ),
        const SizedBox(height: 8),
        // Import button
        _ActionButton(
          icon: Icons.download,
          label: l10n.importSave,
          color: theme.orange,
          theme: theme,
          onTap: () => _importSave(context),
        ),
        const SizedBox(height: 8),
        // Reset button
        _ActionButton(
          icon: Icons.delete_forever,
          label: l10n.get('reset_save'),
          color: theme.negative,
          theme: theme,
          onTap: () => _resetSave(context),
        ),
      ],
    );
  }

  Future<void> _exportSave(BuildContext context) async {
    final game = context.read<GameService>();
    final tutorial = context.read<TutorialService>();

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.background,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Exporting...'),
          ],
        ),
        backgroundColor: theme.cyan,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );

    final result = await SaveService.exportSave(game, tutorial: tutorial);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.cancelled) {
      // User cancelled, no message needed
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success ? l10n.exportSuccess : (result.error ?? l10n.importError)),
        backgroundColor: result.success ? theme.positive : theme.negative,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _importSave(BuildContext context) async {
    final game = context.read<GameService>();
    final tutorial = context.read<TutorialService>();

    // Show warning dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.card,
        title: Text(
          l10n.warning,
          style: TextStyle(color: theme.textPrimary),
        ),
        content: Text(
          'This will replace your current game progress. Are you sure?',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm, style: TextStyle(color: theme.orange)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await SaveService.importSave(game, tutorial: tutorial);

    if (!context.mounted) return;

    if (result.cancelled) {
      // User cancelled, no message needed
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success ? l10n.importSuccess : (result.error ?? l10n.importError)),
        backgroundColor: result.success ? theme.positive : theme.negative,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Close the drawer after successful import
    if (result.success) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _resetSave(BuildContext context) async {
    // Show warning dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.card,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.negative),
            const SizedBox(width: 8),
            Text(
              l10n.warning,
              style: TextStyle(color: theme.textPrimary),
            ),
          ],
        ),
        content: Text(
          l10n.get('reset_save_warning'),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm, style: TextStyle(color: theme.negative)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Reset the game
    final game = context.read<GameService>();
    final tutorial = context.read<TutorialService>();
    final autoSave = context.read<AutoSaveService>();
    final achievements = context.read<AchievementService>();
    final notifications = context.read<NotificationService>();

    // Reset all services
    game.reset();
    tutorial.reset();
    achievements.resetAll();
    notifications.resetAll();
    await autoSave.deleteSave();

    if (!context.mounted) return;

    // Close the drawer
    Navigator.of(context).pop();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.get('reset_save_success')),
        backgroundColor: theme.positive,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiveUpButton extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _GiveUpButton({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _ActionButton(
      icon: Icons.flag_outlined,
      label: l10n.get('give_up'),
      color: theme.orange,
      theme: theme,
      onTap: () => _confirmGiveUp(context),
    );
  }

  Future<void> _confirmGiveUp(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.card,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.get('give_up_confirm_title'),
                style: TextStyle(color: theme.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.get('give_up_confirm_message'),
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.get('give_up_confirm'), style: TextStyle(color: theme.orange)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final game = context.read<GameService>();
    game.giveUp();

    if (!context.mounted) return;

    // Close the drawer - prestige shop will show automatically
    Navigator.of(context).pop();
  }
}

class _RestartTutorialButton extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _RestartTutorialButton({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _restartTutorial(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.purple.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.replay, color: theme.purple, size: 20),
            const SizedBox(width: 12),
            Text(
              l10n.restartTutorial,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _restartTutorial(BuildContext context) {
    final tutorial = context.read<TutorialService>();
    tutorial.restart();

    // Close the drawer
    Navigator.of(context).pop();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tutorial restarted!'),
        backgroundColor: theme.purple,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _FullscreenToggle extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback onToggle;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _FullscreenToggle({
    required this.isFullscreen,
    required this.onToggle,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Icon(
              isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: theme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.get('fullscreen'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ),
            Switch(
              value: isFullscreen,
              onChanged: (_) => onToggle(),
              activeThumbColor: theme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceAlertThresholdSlider extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;
  final double value;
  final ValueChanged<double> onChanged;

  const _PriceAlertThresholdSlider({
    required this.theme,
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: theme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.get('price_alert_threshold'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${value.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.get('price_alert_threshold_desc'),
            style: TextStyle(
              fontSize: 11,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.primary,
              inactiveTrackColor: theme.border,
              thumbColor: theme.primary,
              overlayColor: theme.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: 5,
              max: 50,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

