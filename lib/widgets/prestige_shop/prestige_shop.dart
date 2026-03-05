import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/number_formatter.dart';
import '../../core/big_number.dart';
import '../../data/talent_tree_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';
import 'talent_tree_layout.dart';
import 'talent_tree_painter.dart';
import 'talent_tree_nodes.dart';
import 'talent_tree_tooltip.dart';
import '../styled_background.dart';

/// Full-screen prestige talent tree shown after quota failure.
class PrestigeShop extends StatefulWidget {
  const PrestigeShop({super.key});

  @override
  State<PrestigeShop> createState() => _PrestigeShopState();
}

class _PrestigeShopState extends State<PrestigeShop> with TickerProviderStateMixin {
  late final Map<String, Offset> _positions;
  late final Rect _treeBounds;
  final TransformationController _transformController = TransformationController();
  final GlobalKey _viewerKey = GlobalKey();
  AnimationController? _hintController;
  AnimationController? _cameraController;
  Animation<Matrix4>? _cameraAnimation;
  bool _hintDismissed = false;
  bool _showRecap = true; // Start with recap, then transition to tree

  @override
  void initState() {
    super.initState();
    _positions = TalentTreeLayout.computeNodePositions(allTalentNodes);
    _treeBounds = TalentTreeLayout.getTreeBounds(_positions);

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cameraController!.addListener(() {
      if (_cameraAnimation != null) {
        _transformController.value = _cameraAnimation!.value;
      }
    });

    // Zoom/hint will be triggered when recap is dismissed (see _dismissRecap)
  }

  void _dismissHint() {
    if (_hintDismissed) return;
    _hintDismissed = true;
    _hintController?.reverse();
  }

  static const _defaultZoom = 0.6;

  void _centerOnRoot() {
    // Use the actual InteractiveViewer viewport size, not the full screen
    final renderBox = _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    final viewportSize = renderBox?.size ?? MediaQuery.of(context).size;

    final offsetPos = _offsetPositions();
    // Always start focused on general_root
    final genPos = offsetPos['general_root'];
    final centerX = genPos?.dx ?? _treeBounds.width / 2;
    final centerY = genPos?.dy ?? _treeBounds.height / 2;
    _transformController.value = _buildMatrix(centerX, centerY, _defaultZoom, viewportSize);
  }

  Matrix4 _buildMatrix(double centerX, double centerY, double zoom, Size viewportSize) {
    final tx = viewportSize.width / 2 - centerX * zoom;
    final ty = viewportSize.height / 2 - centerY * zoom;
    return Matrix4.identity()
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty)
      ..setEntry(0, 0, zoom)
      ..setEntry(1, 1, zoom)
      ..setEntry(2, 2, zoom);
  }

  /// Smoothly animate camera to center on a root node.
  void _animateToRoot(String rootId) {
    final offsetPos = _offsetPositions();
    final pos = offsetPos[rootId];
    if (pos == null) return;

    final renderBox = _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    final viewportSize = renderBox?.size ?? MediaQuery.of(context).size;

    final targetMatrix = _buildMatrix(pos.dx, pos.dy, _defaultZoom, viewportSize);
    final startMatrix = _transformController.value.clone();

    _cameraAnimation = Matrix4Tween(begin: startMatrix, end: targetMatrix)
        .animate(CurvedAnimation(parent: _cameraController!, curve: Curves.easeInOut));
    _cameraController!.forward(from: 0);
    _dismissHint();
  }

  @override
  void dispose() {
    TalentTreeTooltip.dismiss();
    _hintController?.dispose();
    _cameraController?.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _dismissRecap() {
    setState(() => _showRecap = false);
    // Trigger initial zoom/hint after switching to tree view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnRoot();
      _hintController?.forward();
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && !_hintDismissed) _dismissHint();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        if (!game.showPrestigeShop) {
          return const SizedBox.shrink();
        }

        final theme = context.watchTheme;
        final l10n = AppLocalizations.of(context);
        final purchased = game.purchasedTalentNodes;

        // Show run recap first, then talent tree
        if (_showRecap) {
          return Material(
            color: theme.background,
            child: Stack(
              children: [
                const StyledBackground(),
                SafeArea(
                  child: _RunRecap(
                    summary: game.runSummary ?? {},
                    theme: theme,
                    l10n: l10n,
                    game: game,
                    onContinue: _dismissRecap,
                  ),
                ),
              ],
            ),
          );
        }

        return Material(
          color: theme.background,
          child: Stack(
            children: [
              const StyledBackground(),
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(theme, l10n, game),
                    const SizedBox(height: 8),

                    // Talent tree
                    Expanded(
                      key: _viewerKey,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: TalentTreeTooltip.dismiss,
                            child: InteractiveViewer(
                              transformationController: _transformController,
                              constrained: false,
                              minScale: 0.15,
                              maxScale: 2.5,
                              boundaryMargin: const EdgeInsets.all(200),
                              onInteractionStart: (_) {
                                TalentTreeTooltip.dismiss();
                                _dismissHint();
                              },
                              child: SizedBox(
                                width: _treeBounds.width,
                                height: _treeBounds.height,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Edges
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: TalentTreeEdgePainter(
                                          nodes: allTalentNodes,
                                          positions: _offsetPositions(),
                                          purchased: purchased,
                                          visibleNodes: _computeVisibleNodes(purchased),
                                        ),
                                      ),
                                    ),

                                    // Branch labels (non-interactive headers)
                                    ..._buildBranchLabels(purchased),

                                    // Sector spoke labels (only when sector_root is purchased)
                                    if (purchased.contains('sector_root'))
                                      ..._buildSectorLabels(),

                                    // Nodes
                                    ..._buildNodeWidgets(game, purchased),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Off-screen root indicators
                          ValueListenableBuilder<Matrix4>(
                            valueListenable: _transformController,
                            builder: (context, matrix, _) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return _buildRootIndicators(
                                    matrix,
                                    Size(constraints.maxWidth, constraints.maxHeight),
                                    theme,
                                  );
                                },
                              );
                            },
                          ),

                          // Navigation tabs
                          Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: _TreeNavTabs(
                                onTap: _animateToRoot,
                                theme: theme,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Legend + continue button
                    _buildFooter(theme, l10n, game),
                  ],
                ),
              ),

              // Gesture hint overlay
              if (_hintController != null)
                _GestureHintOverlay(
                  animation: _hintController!,
                  onDismiss: _dismissHint,
                ),
            ],
          ),
        );
      },
    );
  }

  /// Offset all positions so the tree starts at (0,0) + padding
  Map<String, Offset> _offsetPositions() {
    final dx = -_treeBounds.left;
    final dy = -_treeBounds.top;
    return _positions.map((id, pos) => MapEntry(id, Offset(pos.dx + dx, pos.dy + dy)));
  }

  /// Non-interactive branch name labels positioned beside each branch.
  /// Hides directional labels (gb_*) until general_root is purchased.
  List<Widget> _buildBranchLabels(Set<String> purchased) {
    final offsetPos = _offsetPositions();
    final widgets = <Widget>[];
    final rootPurchased = purchased.contains('general_root');

    for (final label in branchLabels) {
      // Hide Trader/Defense/Automation/Intelligence labels until root is unlocked
      if (label.id.startsWith('gb_') && !rootPurchased) continue;

      final pos = offsetPos[label.id];
      if (pos == null) continue;

      final color = TalentTreeLayout.branchColors[label.branch] ?? const Color(0xFFAA7A3A);

      widgets.add(
        Positioned(
          left: pos.dx,
          top: pos.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label.icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      label.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color.withValues(alpha: 0.9),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Small labels at the tip of each sector spoke.
  List<Widget> _buildSectorLabels() {
    final offsetPos = _offsetPositions();
    final widgets = <Widget>[];

    for (final label in sectorSpokeLabels) {
      final pos = offsetPos[label.id];
      if (pos == null) continue;

      final color = TalentTreeLayout.branchColors[label.branch] ?? const Color(0xFFAA7A3A);

      widgets.add(
        Positioned(
          left: pos.dx,
          top: pos.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label.icon, style: const TextStyle(fontSize: 9)),
                    const SizedBox(width: 3),
                    Text(
                      label.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: color.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// A node is visible if purchased, root, or direct child of a purchased node.
  bool _isNodeVisible(TalentNode node, Set<String> purchased) {
    if (purchased.contains(node.id)) return true;
    if (node.parentId == null) return true; // root nodes always visible
    return purchased.contains(node.parentId); // direct child of purchased
  }

  Set<String> _computeVisibleNodes(Set<String> purchased) {
    return allTalentNodes
        .where((n) => _isNodeVisible(n, purchased))
        .map((n) => n.id)
        .toSet();
  }

  List<Widget> _buildNodeWidgets(GameService game, Set<String> purchased) {
    final offsetPos = _offsetPositions();
    final widgets = <Widget>[];

    for (final node in allTalentNodes) {
      if (!_isNodeVisible(node, purchased)) continue;

      final pos = offsetPos[node.id];
      if (pos == null) continue;

      final radius = TalentTreeLayout.nodeRadius[node.size] ?? 20.0;
      final isPurchased = purchased.contains(node.id);
      final isAvailable = isNodeUnlockable(node.id, purchased);
      final canAfford = game.prestigePoints >= node.cost;

      widgets.add(
        Positioned(
          left: pos.dx - radius,
          top: pos.dy - radius,
          child: TalentNodeWidget(
            node: node,
            purchased: isPurchased,
            available: isAvailable,
            canAfford: canAfford,
            onTap: () {
              // Single tap: always show tooltip
              _showTooltip(node, isPurchased, isAvailable, canAfford, game);
            },
            onDoubleTap: () {
              // Double tap: purchase directly if possible
              if (!isPurchased && isAvailable && canAfford) {
                TalentTreeTooltip.dismiss();
                SoundService().playMoney();
                game.purchaseTalentNode(node.id);
              }
            },
          ),
        ),
      );
    }

    return widgets;
  }

  void _showTooltip(TalentNode node, bool purchased, bool available, bool canAfford, GameService game) {
    // Get approximate global position from the transform controller
    final matrix = _transformController.value;
    final offsetPos = _offsetPositions();
    final pos = offsetPos[node.id];
    if (pos == null) return;

    final transformed = MatrixUtils.transformPoint(matrix, pos);

    TalentTreeTooltip.show(
      context: context,
      node: node,
      purchased: purchased,
      available: available,
      canAfford: canAfford,
      prestigePoints: game.prestigePoints,
      globalPosition: transformed,
      onPurchase: () {
        SoundService().playMoney();
        game.purchaseTalentNode(node.id);
      },
    );
  }

  /// Builds off-screen directional indicators for root nodes (tappable).
  Widget _buildRootIndicators(Matrix4 matrix, Size viewportSize, dynamic theme) {
    final offsetPos = _offsetPositions();
    final indicators = <Widget>[];
    const padding = 36.0;
    const indicatorSize = 56.0;

    final roots = [
      ('general_root', '\u2B50', const Color(0xFFD4A843)),
      ('sector_root', '\u{1F310}', const Color(0xFFAA7A3A)),
    ];

    for (final (id, icon, color) in roots) {
      final pos = offsetPos[id];
      if (pos == null) continue;

      final screenPos = MatrixUtils.transformPoint(matrix, pos);

      // Skip if on screen
      if (screenPos.dx >= -30 && screenPos.dx <= viewportSize.width + 30 &&
          screenPos.dy >= -30 && screenPos.dy <= viewportSize.height + 30) {
        continue;
      }

      // Clamp to viewport edge
      final clampedX = screenPos.dx.clamp(padding, viewportSize.width - padding);
      final clampedY = screenPos.dy.clamp(padding, viewportSize.height - padding);

      // Arrow angle: from indicator toward the off-screen node
      final angle = (screenPos - Offset(clampedX, clampedY)).direction;

      final rootId = id;
      indicators.add(
        Positioned(
          left: clampedX - indicatorSize / 2,
          top: clampedY - indicatorSize / 2,
          child: GestureDetector(
            onTap: () => _animateToRoot(rootId),
            child: _RootIndicator(icon: icon, color: color, angle: angle, theme: theme),
          ),
        ),
      );
    }

    return Stack(children: indicators);
  }

  Widget _buildHeader(dynamic theme, AppLocalizations l10n, GameService game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Text(
            l10n.quotaFailed.toUpperCase(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.negative,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.survivedDaysYear(game.currentDay, game.currentYear),
            style: TextStyle(fontSize: 13, color: theme.textSecondary),
          ),
          const SizedBox(height: 10),
          // PP display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: theme.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.purple.withValues(alpha: 0.5), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('\u2B50', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '${game.prestigePoints}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.prestigePoints.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.purple,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(dynamic theme, AppLocalizations l10n, GameService game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Start new run
          _ContinueButton(
            onPressed: () {
              TalentTreeTooltip.dismiss();
              game.closePrestigeShopAndReset();
            },
          ),
        ],
      ),
    );
  }

}

/// Animated hint overlay telling the user how to navigate the tree.
class _GestureHintOverlay extends AnimatedWidget {
  final VoidCallback onDismiss;

  const _GestureHintOverlay({
    required Animation<double> animation,
    required this.onDismiss,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final opacity = (listenable as Animation<double>).value;
    if (opacity <= 0) return const SizedBox.shrink();

    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pinch, size: 20, color: theme.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    l10n.treeHint,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating navigation tabs to switch between General and Sector trees.
class _TreeNavTabs extends StatelessWidget {
  final void Function(String rootId) onTap;
  final dynamic theme;

  const _TreeNavTabs({required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: (theme.surface as Color).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (theme.border as Color).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavTab(
              icon: '\u2B50',
              label: 'General',
              color: const Color(0xFFD4A843),
              theme: theme,
              onTap: () => onTap('general_root'),
            ),
            const SizedBox(width: 4),
            _NavTab(
              icon: '\u{1F310}',
              label: 'Sectors',
              color: const Color(0xFFAA7A3A),
              theme: theme,
              onTap: () => onTap('sector_root'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final dynamic theme;
  final VoidCallback onTap;

  const _NavTab({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Directional indicator for an off-screen root node.
/// Shows the node icon in a circle with a small arrow pointing toward it.
class _RootIndicator extends StatelessWidget {
  final String icon;
  final Color color;
  final double angle;
  final dynamic theme;

  const _RootIndicator({
    required this.icon,
    required this.color,
    required this.angle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arrow pointing toward the off-screen node
          Transform.translate(
            offset: Offset(math.cos(angle) * 24, math.sin(angle) * 24),
            child: Transform.rotate(
              angle: angle - math.pi / 2, // Icons.navigation points up, adjust to direction
              child: Icon(Icons.navigation, size: 14, color: color),
            ),
          ),
          // Circle with node icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (theme.surface as Color).withValues(alpha: 0.9),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10),
              ],
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered ? theme.cyan : theme.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.cyan, width: 2),
            boxShadow: _isHovered
                ? [BoxShadow(color: theme.cyan.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2)]
                : [],
          ),
          child: Text(
            l10n.startNewRun,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _isHovered ? theme.background : theme.cyan,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Run recap screen shown before the talent tree on game over.
class _RunRecap extends StatelessWidget {
  final Map<String, dynamic> summary;
  final dynamic theme;
  final AppLocalizations l10n;
  final GameService game;
  final VoidCallback onContinue;

  const _RunRecap({
    required this.summary,
    required this.theme,
    required this.l10n,
    required this.game,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final days = summary['days'] ?? 0;
    final year = summary['year'] ?? 1;
    final totalTrades = summary['totalTrades'] ?? 0;
    final winningTrades = summary['winningTrades'] ?? 0;
    final losingTrades = summary['losingTrades'] ?? 0;
    final winRateVal = (summary['winRate'] ?? 0.0) as double;
    final bestTrade = (summary['bestTrade'] ?? 0.0) as double;
    final bestTradeTicker = summary['bestTradeTicker'] as String?;
    final worstTrade = (summary['worstTrade'] ?? 0.0) as double;
    final worstTradeTicker = summary['worstTradeTicker'] as String?;
    final totalProfit = (summary['totalProfit'] ?? 0.0) as double;
    final netWorth = (summary['netWorth'] ?? 0.0) as double;
    final bestNetWorth = (summary['bestNetWorth'] ?? 0.0) as double;
    final bestStreak = summary['bestStreak'] ?? 0;
    final quotasMet = summary['quotasMet'] ?? 0;
    final ppEarned = summary['ppEarned'] ?? 0;
    final playerTitle = summary['playerTitle'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Title
          Text(
            l10n.get('run_over_title'),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.negative,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            playerTitle as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.purple,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.get('days_survived')}: $days  \u2022  Year $year',
            style: TextStyle(fontSize: 13, color: theme.textSecondary),
          ),

          const SizedBox(height: 20),

          // Stats grid
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Trade stats row
                  _StatRow(theme: theme, children: [
                    _StatCard(
                      icon: '\u{1F4CA}',
                      label: l10n.totalTrades,
                      value: '$totalTrades',
                      theme: theme,
                    ),
                    _StatCard(
                      icon: '\u2705',
                      label: l10n.get('winning_trades'),
                      value: '$winningTrades',
                      valueColor: theme.positive,
                      theme: theme,
                    ),
                    _StatCard(
                      icon: '\u274C',
                      label: l10n.get('losing_trades'),
                      value: '$losingTrades',
                      valueColor: theme.negative,
                      theme: theme,
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // Win rate + streak
                  _StatRow(theme: theme, children: [
                    _StatCard(
                      icon: '\u{1F3AF}',
                      label: l10n.winRate,
                      value: '${winRateVal.toStringAsFixed(1)}%',
                      valueColor: winRateVal >= 50 ? theme.positive : theme.negative,
                      theme: theme,
                    ),
                    _StatCard(
                      icon: '\u{1F525}',
                      label: l10n.get('best_streak'),
                      value: '$bestStreak',
                      valueColor: const Color(0xFFFF9800),
                      theme: theme,
                    ),
                    _StatCard(
                      icon: '\u{1F3C6}',
                      label: l10n.get('quotas_met'),
                      value: '$quotasMet',
                      theme: theme,
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // Best / worst trade
                  _StatRow(theme: theme, children: [
                    _StatCard(
                      icon: '\u{1F4B0}',
                      label: l10n.get('best_trade_label'),
                      value: NumberFormatter.format(BigNumber(bestTrade), showSign: true),
                      subtitle: bestTradeTicker,
                      valueColor: theme.positive,
                      theme: theme,
                    ),
                    _StatCard(
                      icon: '\u{1F4B8}',
                      label: l10n.get('worst_trade_label'),
                      value: NumberFormatter.format(BigNumber(worstTrade), showSign: true),
                      subtitle: worstTradeTicker,
                      valueColor: theme.negative,
                      theme: theme,
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // Fortune stats
                  _StatRow(theme: theme, children: [
                    _StatCard(
                      icon: '\u{1F4B5}',
                      label: l10n.get('total_profit'),
                      value: NumberFormatter.format(BigNumber(totalProfit), showSign: true),
                      valueColor: totalProfit >= 0 ? theme.positive : theme.negative,
                      theme: theme,
                    ),
                    _StatCard(
                      icon: '\u{1F451}',
                      label: l10n.get('peak_fortune'),
                      value: NumberFormatter.format(BigNumber(bestNetWorth)),
                      theme: theme,
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // Final fortune + PP earned
                  _StatRow(theme: theme, children: [
                    _StatCard(
                      icon: '\u{1F4BC}',
                      label: l10n.get('final_fortune'),
                      value: NumberFormatter.format(BigNumber(netWorth)),
                      theme: theme,
                    ),
                    _StatCard(
                      icon: '\u2B50',
                      label: l10n.get('pp_earned'),
                      value: '+$ppEarned',
                      valueColor: theme.purple,
                      theme: theme,
                      highlight: true,
                    ),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Continue button
          GestureDetector(
            onTap: onContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.purple, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u2B50', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    l10n.get('continue_to_tree'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.purple,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final dynamic theme;
  final List<Widget> children;

  const _StatRow({required this.theme, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .expand((child) => [Expanded(child: child), const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final dynamic theme;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? (theme.purple as Color).withValues(alpha: 0.1)
            : (theme.surface as Color).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? (theme.purple as Color).withValues(alpha: 0.4)
              : (theme.border as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 10, color: theme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
