import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_themes.dart';
import 'talent_tree_layout.dart';

/// Shows a tooltip for a talent node (overlay on desktop, bottom sheet on mobile).
class TalentTreeTooltip {
  static OverlayEntry? _currentOverlay;

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  static void show({
    required BuildContext context,
    required TalentNode node,
    required bool purchased,
    required bool available,
    required bool canAfford,
    required int prestigePoints,
    required Offset globalPosition,
    required VoidCallback onPurchase,
  }) {
    dismiss();

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    if (isMobile) {
      _showBottomSheet(context, node, purchased, available, canAfford, prestigePoints, onPurchase);
    } else {
      _showOverlay(context, node, purchased, available, canAfford, prestigePoints, globalPosition, onPurchase);
    }
  }

  static void _showBottomSheet(
    BuildContext context,
    TalentNode node,
    bool purchased,
    bool available,
    bool canAfford,
    int prestigePoints,
    VoidCallback onPurchase,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _TooltipContent(
        node: node,
        purchased: purchased,
        available: available,
        canAfford: canAfford,
        prestigePoints: prestigePoints,
        onPurchase: () {
          Navigator.pop(ctx);
          onPurchase();
        },
      ),
    );
  }

  static void _showOverlay(
    BuildContext context,
    TalentNode node,
    bool purchased,
    bool available,
    bool canAfford,
    int prestigePoints,
    Offset globalPosition,
    VoidCallback onPurchase,
  ) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Position tooltip near the node, clamped to screen
    double left = globalPosition.dx + 20;
    double top = globalPosition.dy - 40;
    const tooltipWidth = 280.0;
    const tooltipHeight = 200.0;

    if (left + tooltipWidth > screenSize.width - 16) {
      left = globalPosition.dx - tooltipWidth - 20;
    }
    if (top + tooltipHeight > screenSize.height - 16) {
      top = screenSize.height - tooltipHeight - 16;
    }
    if (top < 16) top = 16;
    if (left < 16) left = 16;

    _currentOverlay = OverlayEntry(
      builder: (ctx) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: _TooltipContent(
            node: node,
            purchased: purchased,
            available: available,
            canAfford: canAfford,
            prestigePoints: prestigePoints,
            onPurchase: () {
              dismiss();
              onPurchase();
            },
            isOverlay: true,
          ),
        ),
      ),
    );
    overlay.insert(_currentOverlay!);
  }
}

class _TooltipContent extends StatelessWidget {
  final TalentNode node;
  final bool purchased;
  final bool available;
  final bool canAfford;
  final int prestigePoints;
  final VoidCallback onPurchase;
  final bool isOverlay;

  const _TooltipContent({
    required this.node,
    required this.purchased,
    required this.available,
    required this.canAfford,
    required this.prestigePoints,
    required this.onPurchase,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final branchColor = TalentTreeLayout.branchColors[node.branch] ?? const Color(0xFFAA7A3A);

    return Container(
      width: isOverlay ? 280 : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: branchColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: isOverlay
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20)]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + name
          Row(
            children: [
              Text(node.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.get('upgrade_${node.id}_name'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: branchColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            l10n.get('upgrade_${node.id}_desc'),
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Effect
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: branchColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              node.effectText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: branchColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cost + buy button
          if (!purchased)
            Row(
              children: [
                Text(
                  '\u2B50 ${node.cost}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? const Color(0xFFFFD700) : theme.textMuted,
                  ),
                ),
                const Spacer(),
                if (available && canAfford)
                  GestureDetector(
                    onTap: onPurchase,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: branchColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: branchColor),
                      ),
                      child: Text(
                        l10n.get('talent_buy'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: branchColor,
                        ),
                      ),
                    ),
                  )
                else if (!available)
                  Text(
                    l10n.get('node_locked'),
                    style: TextStyle(fontSize: 12, color: theme.textMuted),
                  )
                else
                  Text(
                    l10n.get('not_enough_pp'),
                    style: TextStyle(fontSize: 12, color: theme.negative),
                  ),
              ],
            )
          else
            Row(
              children: [
                Icon(Icons.check_circle, color: branchColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  l10n.get('node_purchased'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: branchColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
