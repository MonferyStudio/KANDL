import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'talent_tree_layout.dart';

/// CustomPainter that draws edges between talent tree nodes.
class TalentTreeEdgePainter extends CustomPainter {
  final List<TalentNode> nodes;
  final Map<String, Offset> positions;
  final Set<String> purchased;
  final Set<String> visibleNodes;

  TalentTreeEdgePainter({
    required this.nodes,
    required this.positions,
    required this.purchased,
    required this.visibleNodes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in nodes) {
      if (node.parentId == null) continue;
      if (!visibleNodes.contains(node.id)) continue;
      final from = positions[node.parentId];
      final to = positions[node.id];
      if (from == null || to == null) continue;

      final bothBought = purchased.contains(node.id) && purchased.contains(node.parentId);
      final color = bothBought
          ? TalentTreeLayout.branchColors[node.branch]?.withValues(alpha: 0.7) ?? const Color(0xFF2A2A3A)
          : const Color(0xFF2A2A3A);

      final paint = Paint()
        ..color = color
        ..strokeWidth = bothBought ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TalentTreeEdgePainter oldDelegate) {
    return oldDelegate.purchased != purchased ||
        oldDelegate.visibleNodes != visibleNodes;
  }
}
