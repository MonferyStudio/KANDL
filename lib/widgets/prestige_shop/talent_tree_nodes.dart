import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'talent_tree_layout.dart';

/// A single talent tree node widget (circle or badge pill).
/// Uses [GestureDetector] with only [onTap] (no onDoubleTap registered)
/// so Flutter fires taps immediately without the 300ms double-tap wait.
class TalentNodeWidget extends StatefulWidget {
  final TalentNode node;
  final bool purchased;
  final bool available;
  final bool canAfford;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  const TalentNodeWidget({
    super.key,
    required this.node,
    required this.purchased,
    required this.available,
    required this.canAfford,
    required this.onTap,
    this.onDoubleTap,
  });

  @override
  State<TalentNodeWidget> createState() => _TalentNodeWidgetState();
}

class _TalentNodeWidgetState extends State<TalentNodeWidget> {
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 400)) {
      _lastTapTime = null;
      widget.onDoubleTap?.call();
    } else {
      _lastTapTime = now;
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = TalentTreeLayout.nodeRadius[widget.node.size] ?? 20.0;
    final branchColor =
        TalentTreeLayout.branchColors[widget.node.branch] ?? const Color(0xFFAA7A3A);
    final nodeColor = _getNodeColor();

    if (widget.node.isBadge) {
      return _buildBadge(radius, branchColor, nodeColor);
    }
    return _buildCircle(radius, branchColor, nodeColor);
  }

  Color _getNodeColor() {
    if (widget.node.branch == TalentBranch.sectors && widget.node.id.contains('_profit')) {
      return TalentTreeLayout.bonusProfitColor;
    }
    if (widget.node.branch == TalentBranch.sectors && widget.node.id.contains('_shield')) {
      return TalentTreeLayout.bonusShieldColor;
    }
    if (widget.node.branch == TalentBranch.sectors && widget.node.id.contains('_income')) {
      return TalentTreeLayout.bonusIncomeColor;
    }
    if (widget.node.id.contains('_cap')) return TalentTreeLayout.capstoneColor;
    if (widget.node.id.contains('_t3')) return TalentTreeLayout.tier3Color;
    if (widget.node.id.contains('_t2')) return TalentTreeLayout.tier2Color;
    if (widget.node.id.contains('_t1')) return TalentTreeLayout.tier1Color;
    return TalentTreeLayout.branchColors[widget.node.branch] ?? const Color(0xFFAA7A3A);
  }

  double get _opacity {
    if (widget.purchased) return 1.0;
    if (widget.available && widget.canAfford) return 0.7;
    if (widget.available) return 0.5;
    return 0.15;
  }

  Widget _buildCircle(double radius, Color branchColor, Color nodeColor) {
    final size = radius * 2;
    final fontSize = _fontSizeForNode();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Opacity(
        opacity: _opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.purchased
                ? nodeColor.withValues(alpha: 0.15)
                : const Color(0xFF1A1A2E),
            border: Border.all(
              color: widget.purchased
                  ? nodeColor
                  : widget.available
                      ? const Color(0xFF555555)
                      : const Color(0xFF333333),
              width: widget.purchased ? 2.5 : 1.5,
            ),
            boxShadow: widget.purchased
                ? [BoxShadow(color: nodeColor.withValues(alpha: 0.3), blurRadius: 12)]
                : [],
          ),
          child: Center(
            child: Text(
              widget.node.icon,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(double radius, Color branchColor, Color nodeColor) {
    final height = radius * 2;
    final fontSize = _fontSizeForNode();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Opacity(
        opacity: _opacity,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: widget.purchased
                ? nodeColor.withValues(alpha: 0.15)
                : const Color(0xFF1A1A2E),
            border: Border.all(
              color: widget.purchased
                  ? nodeColor
                  : widget.available
                      ? const Color(0xFF555555)
                      : const Color(0xFF333333),
              width: widget.purchased ? 2.5 : 1.5,
            ),
            boxShadow: widget.purchased
                ? [BoxShadow(color: nodeColor.withValues(alpha: 0.3), blurRadius: 12)]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.node.icon, style: TextStyle(fontSize: fontSize)),
              const SizedBox(width: 6),
              Text(
                widget.node.name,
                style: TextStyle(
                  fontSize: fontSize * 0.7,
                  fontWeight: FontWeight.bold,
                  color: widget.purchased ? nodeColor : const Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _fontSizeForNode() {
    switch (widget.node.size) {
      case TalentNodeSize.lg: return 26;
      case TalentNodeSize.md: return 20;
      case TalentNodeSize.sm: return 16;
      case TalentNodeSize.xs: return 13;
      case TalentNodeSize.xxs: return 10;
    }
  }
}
