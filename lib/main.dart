import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/game_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'services/achievement_service.dart';
import 'services/tutorial_service.dart';
import 'services/auto_save_service.dart';
import 'services/sound_service.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings
  final settingsService = SettingsService();
  await settingsService.init();

  // Initialize auto-save service
  final autoSaveService = AutoSaveService();
  await autoSaveService.init();

  // Set orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(KandlApp(
    settingsService: settingsService,
    autoSaveService: autoSaveService,
  ));
}

class KandlApp extends StatelessWidget {
  final SettingsService settingsService;
  final AutoSaveService autoSaveService;

  const KandlApp({
    super.key,
    required this.settingsService,
    required this.autoSaveService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsService),
        Provider.value(value: autoSaveService),
        ChangeNotifierProvider(create: (_) => GameService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => AchievementService()..initialize()),
        ChangeNotifierProvider(create: (_) => TutorialService()),
        ChangeNotifierProvider(create: (_) => SoundService()),
      ],
      child: _AutoSaveInitializer(
        child: Consumer<SettingsService>(
          builder: (context, settings, _) {
            final theme = settings.currentTheme;

            // Update system UI colors based on theme
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    theme.isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor: theme.background,
                systemNavigationBarIconBrightness:
                    theme.isDark ? Brightness.light : Brightness.dark,
              ),
            );

            return MaterialApp(
              title: 'KANDL',
              debugShowCheckedModeBanner: false,
              theme: theme.toThemeData(),
              locale: settings.currentLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}

/// Widget that initializes auto-save and loads saved game on startup
class _AutoSaveInitializer extends StatefulWidget {
  final Widget child;

  const _AutoSaveInitializer({required this.child});

  @override
  State<_AutoSaveInitializer> createState() => _AutoSaveInitializerState();
}

class _AutoSaveInitializerState extends State<_AutoSaveInitializer> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Defer initialization to after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAutoSave();
      });
    }
  }

  Future<void> _initializeAutoSave() async {
    if (!mounted) return;

    final autoSave = context.read<AutoSaveService>();
    final game = context.read<GameService>();
    final tutorial = context.read<TutorialService>();
    final achievements = context.read<AchievementService>();

    // Bind services for auto-save
    autoSave.bindServices(game, tutorial, achievements);

    // Load saved game if exists
    if (autoSave.hasSavedGame) {
      await autoSave.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
