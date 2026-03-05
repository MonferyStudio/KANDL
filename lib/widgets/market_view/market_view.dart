import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../sectors_view/sectors_view.dart';
import '../stocks_view/stocks_view.dart';
import '../news_view/news_view.dart';

/// Composite Market view with 3 sub-tabs: Sectors, Stocks, News
class MarketView extends StatefulWidget {
  const MarketView({super.key});

  @override
  State<MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<MarketView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GameService _game;
  int _lastKnownGameTab = 0;

  @override
  void initState() {
    super.initState();
    _game = context.read<GameService>();
    _lastKnownGameTab = _game.marketSubTab;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _game.marketSubTab,
    );
    _tabController.addListener(_onTabChanged);
    _game.addListener(_onGameChanged);
  }

  void _onTabChanged() {
    // Push user tab change to game state (fires on tap + swipe completion)
    if (!_tabController.indexIsChanging) {
      final index = _tabController.index;
      if (_game.marketSubTab != index) {
        _game.setMarketSubTab(index);
        _lastKnownGameTab = index;
      }
    }
  }

  void _onGameChanged() {
    // Only react when game state *actually* changed the tab (e.g. selectSector)
    final gameTab = _game.marketSubTab;
    if (gameTab != _lastKnownGameTab) {
      _lastKnownGameTab = gameTab;
      _tabController.animateTo(gameTab);
    }
  }

  @override
  void dispose() {
    _game.removeListener(_onGameChanged);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border(
              bottom: BorderSide(color: theme.border, width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.accent,
            unselectedLabelColor: theme.textMuted,
            indicatorColor: theme.accent,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
            tabs: [
              Tab(
                icon: const Icon(Icons.category, size: 18),
                text: l10n.sectors,
              ),
              Tab(
                icon: const Icon(Icons.trending_up, size: 18),
                text: l10n.stocks,
              ),
              Tab(
                icon: const Icon(Icons.newspaper, size: 18),
                text: l10n.news,
              ),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              SectorsView(),
              StocksView(),
              NewsView(),
            ],
          ),
        ),
      ],
    );
  }
}
