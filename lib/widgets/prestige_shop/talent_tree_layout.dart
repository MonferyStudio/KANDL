import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';

/// Layout engine for the dual talent tree.
///
/// Left side: General upgrades tree (future branches radiate from general_root)
/// Right side: Sector tree (16 spokes radiate from sector_root)
class TalentTreeLayout {
  TalentTreeLayout._();

  // ── General tree center (left) ──
  static const double genCx = 400;
  static const double genCy = 800;

  // ── Sector tree center (right) ──
  static const double secCx = 2100;
  static const double secCy = 800;

  // ── Sector fan ──
  static const double hubDistance = 160;
  static const double sectorNodeSpacing = 44;

  // ── Node sizes (radius) ──
  static const Map<TalentNodeSize, double> nodeRadius = {
    TalentNodeSize.lg: 35,
    TalentNodeSize.md: 25,
    TalentNodeSize.sm: 20,
    TalentNodeSize.xs: 16,
    TalentNodeSize.xxs: 12,
  };

  // ── Branch colors ──
  static const Map<TalentBranch, Color> branchColors = {
    TalentBranch.root: Color(0xFFD4A843),
    TalentBranch.trader: Color(0xFF4A9A4A),
    TalentBranch.survival: Color(0xFF4A7AAA),
    TalentBranch.automation: Color(0xFF8A4AAA),
    TalentBranch.intelligence: Color(0xFFAA4A6A),
    TalentBranch.sectors: Color(0xFFAA7A3A),
  };

  // ── Sector tier colors ──
  static const Color tier1Color = Color(0xFF4A8ACC);
  static const Color tier2Color = Color(0xFFCCAA3A);
  static const Color tier3Color = Color(0xFFCC6A2A);
  static const Color capstoneColor = Color(0xFFCC4040);
  static const Color bonusProfitColor = Color(0xFF4AAA4A);
  static const Color bonusShieldColor = Color(0xFF4A8ACC);
  static const Color bonusIncomeColor = Color(0xFFCCAA3A);

  // ═══════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════

  /// Compute positions for every node + hub labels.
  static Map<String, Offset> computeNodePositions(List<TalentNode> nodes) {
    final positions = <String, Offset>{};

    // General tree (left)
    positions['general_root'] = const Offset(genCx, genCy);
    positions['gen_hub'] = const Offset(genCx, genCy - 55);

    // General tree branch labels (4 directions — empty for now)
    const branchDist = 120.0;
    positions['gb_trader'] = const Offset(genCx, genCy - branchDist);
    positions['gb_survival'] = const Offset(genCx, genCy + branchDist);
    positions['gb_automation'] = const Offset(genCx - branchDist, genCy);
    positions['gb_intelligence'] = const Offset(genCx + branchDist, genCy);

    // Sector tree (right)
    positions['sector_root'] = const Offset(secCx, secCy);

    // Sector hub label below sector root
    positions['sc_hub'] = Offset(secCx, secCy - 55);

    // Trader branch (up from general_root)
    _layoutTraderBranch(nodes, positions);

    // Automation branch (left from general_root)
    _layoutAutomationBranch(nodes, positions);

    // Survival branch (down from general_root)
    _layoutSurvivalBranch(nodes, positions);

    // Intelligence branch (right from general_root)
    _layoutIntelligenceBranch(nodes, positions);

    // Sector fan — full 360° circle around sector_root
    _layoutSectorFan(nodes, positions);

    return positions;
  }

  /// Bounding rect with padding.
  static Rect getTreeBounds(Map<String, Offset> positions) {
    if (positions.isEmpty) return Rect.zero;
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final pos in positions.values) {
      if (pos.dx < minX) minX = pos.dx;
      if (pos.dy < minY) minY = pos.dy;
      if (pos.dx > maxX) maxX = pos.dx;
      if (pos.dy > maxY) maxY = pos.dy;
    }
    const pad = 120.0;
    return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
  }

  // ═══════════════════════════════════════════════════════════════
  // Trader branch (spine going up from general_root)
  // ═══════════════════════════════════════════════════════════════

  static void _layoutTraderBranch(List<TalentNode> nodes, Map<String, Offset> positions) {
    const x = genCx;
    const startY = genCy - 200.0; // pushed up to clear the label
    const spine = 65.0;   // vertical spacing between spine nodes
    const diagX = 32.0;   // diagonal step: horizontal
    const diagY = 28.0;   // diagonal step: vertical (going up)

    // Spine IDs in order
    const spineIds = [
      'tr_seed1', 'tr_slot1', 'tr_seed2', 'tr_slot2', 'tr_seed3',
      'tr_slot3', 'tr_slot4', 'tr_slot5', 'tr_slot6', 'tr_cap',
    ];

    // Place spine nodes going up
    for (int i = 0; i < spineIds.length; i++) {
      positions[spineIds[i]] = Offset(x, startY - spine * i);
    }

    // Helper to place a diagonal branch from a spine node
    void placeBranch(String spineId, List<String> ids, {required bool goLeft}) {
      final origin = positions[spineId]!;
      final dirX = goLeft ? -1.0 : 1.0;
      for (var i = 0; i < ids.length; i++) {
        final step = i + 1;
        positions[ids[i]] = Offset(
          origin.dx + dirX * diagX * step,
          origin.dy - diagY * step,
        );
      }
    }

    // From spine #2 (tr_slot1) — LEFT: Stop Loss / Take Profit
    placeBranch('tr_slot1', [
      'tr_sl', 'tr_tp', 'tr_trailing', 'tr_partial_tp', 'tr_safety',
    ], goLeft: true);

    // From spine #2 (tr_slot1) — RIGHT: Tempo Trading
    placeBranch('tr_slot1', [
      'tr_qf1', 'tr_qf2', 'tr_scalper', 'tr_patient1', 'tr_patient2', 'tr_diamond',
    ], goLeft: false);

    // From spine #4 (tr_slot2) — LEFT: Winning Streak
    placeBranch('tr_slot2', [
      'tr_streak', 'tr_hot_hand', 'tr_resilient',
    ], goLeft: true);

    // From spine #5 (tr_seed3) — LEFT: Limit Orders
    placeBranch('tr_seed3', [
      'tr_limit_orders', 'tr_smart_orders',
    ], goLeft: true);

    // From spine #5 (tr_seed3) — RIGHT: Profit Multipliers
    placeBranch('tr_seed3', [
      'tr_profit1', 'tr_profit2', 'tr_profit3', 'tr_eagle',
    ], goLeft: false);

    // From spine #7 (tr_slot4) — LEFT: Leverage
    placeBranch('tr_slot4', [
      'tr_margin', 'tr_lev15', 'tr_lev2', 'tr_margin_shield', 'tr_lev3',
    ], goLeft: true);

    // From spine #7 (tr_slot4) — RIGHT: Compound Interest
    placeBranch('tr_slot4', [
      'tr_interest1', 'tr_interest2', 'tr_interest3',
    ], goLeft: false);
  }

  // ═══════════════════════════════════════════════════════════════
  // Automation branch (spine going left from general_root)
  // ═══════════════════════════════════════════════════════════════

  static void _layoutAutomationBranch(List<TalentNode> nodes, Map<String, Offset> positions) {
    const startX = genCx - 200.0;
    const y = genCy;
    const spine = 65.0;
    const diagX = 28.0;
    const diagY = 32.0;

    // Spine: 10 robot slots going left
    const spineIds = [
      'auto_slot_1', 'auto_slot_2', 'auto_slot_3', 'auto_slot_4', 'auto_slot_5',
      'auto_slot_6', 'auto_slot_7', 'auto_slot_8', 'auto_slot_9', 'auto_slot_10',
    ];

    for (int i = 0; i < spineIds.length; i++) {
      positions[spineIds[i]] = Offset(startX - spine * i, y);
    }

    // Helper: diagonal branch from a spine node
    void placeBranch(String spineId, List<String> ids, {required bool goUp}) {
      final origin = positions[spineId]!;
      final dirY = goUp ? -1.0 : 1.0;
      for (var i = 0; i < ids.length; i++) {
        final step = i + 1;
        positions[ids[i]] = Offset(
          origin.dx - diagX * step,
          origin.dy + dirY * diagY * step,
        );
      }
    }

    // From #2 (Beta) — UP: Discount
    placeBranch('auto_slot_2', ['auto_disc1', 'auto_disc2', 'auto_disc3'], goUp: true);
    // From #3 (Gamma) — DOWN: Starting Level
    placeBranch('auto_slot_3', ['auto_lvl1', 'auto_lvl2', 'auto_lvl3'], goUp: false);

    // From #5 (Epsilon) — UP: Seed Money
    placeBranch('auto_slot_5', ['auto_seed1', 'auto_seed2', 'auto_seed3'], goUp: true);
    // From #6 (Zeta) — DOWN: Win Rate
    placeBranch('auto_slot_6', ['auto_wr1', 'auto_wr2', 'auto_wr3'], goUp: false);

    // From #8 (Theta) — UP: Speed
    placeBranch('auto_slot_8', ['auto_speed1', 'auto_speed2'], goUp: true);
    // From #9 (Iota) — DOWN: Auto-Collect (single node)
    placeBranch('auto_slot_9', ['auto_collect'], goUp: false);
  }

  // ═══════════════════════════════════════════════════════════════
  // Survival branch (spine going down from general_root)
  // ═══════════════════════════════════════════════════════════════

  static void _layoutSurvivalBranch(List<TalentNode> nodes, Map<String, Offset> positions) {
    const x = genCx;
    const startY = genCy + 200.0;
    const spine = 65.0;
    const diagX = 32.0;
    const diagY = 28.0;

    const spineIds = [
      'sv_day1', 'sv_life1', 'sv_day2', 'sv_quota1',
      'sv_life2', 'sv_quota2', 'sv_day3', 'sv_cap',
    ];

    for (int i = 0; i < spineIds.length; i++) {
      positions[spineIds[i]] = Offset(x, startY + spine * i);
    }

    void placeBranch(String spineId, List<String> ids, {required bool goLeft}) {
      final origin = positions[spineId]!;
      final dirX = goLeft ? -1.0 : 1.0;
      for (var i = 0; i < ids.length; i++) {
        final step = i + 1;
        positions[ids[i]] = Offset(
          origin.dx + dirX * diagX * step,
          origin.dy + diagY * step,
        );
      }
    }

    // From #2 (sv_life1) — LEFT: Skip Boost
    placeBranch('sv_life1', ['sv_skip1', 'sv_skip2', 'sv_skip3'], goLeft: true);
    // From #2 (sv_life1) — RIGHT: Loss Recovery
    placeBranch('sv_life1', ['sv_recov1', 'sv_recov2', 'sv_recov3'], goLeft: false);

    // From #4 (sv_quota1) — LEFT: Overtime
    placeBranch('sv_quota1', ['sv_grace1', 'sv_grace2', 'sv_second_wind'], goLeft: true);
    // From #4 (sv_quota1) — RIGHT: PP Boost
    placeBranch('sv_quota1', ['sv_pp1', 'sv_pp2', 'sv_pp3'], goLeft: false);

    // From #7 (sv_day3) — LEFT: Early Finish
    placeBranch('sv_day3', ['sv_early1', 'sv_early2', 'sv_speedrun'], goLeft: true);
    // From #7 (sv_day3) — RIGHT: Momentum
    placeBranch('sv_day3', ['sv_streak1', 'sv_streak2', 'sv_streak3'], goLeft: false);
  }

  // ═══════════════════════════════════════════════════════════════
  // Intelligence branch (spine going right from general_root)
  // ═══════════════════════════════════════════════════════════════

  static void _layoutIntelligenceBranch(List<TalentNode> nodes, Map<String, Offset> positions) {
    const startX = genCx + 200.0;
    const y = genCy;
    const spine = 65.0;
    const diagX = 28.0;
    const diagY = 32.0;

    // Spine: 8 nodes going right
    const spineIds = [
      'in_reroll1', 'in_luck1', 'in_reroll2', 'in_choice',
      'in_luck2', 'in_reroll3', 'in_luck3', 'in_cap',
    ];

    for (int i = 0; i < spineIds.length; i++) {
      positions[spineIds[i]] = Offset(startX + spine * i, y);
    }

    // Helper: diagonal branch from a spine node
    void placeBranch(String spineId, List<String> ids, {required bool goUp}) {
      final origin = positions[spineId]!;
      final dirY = goUp ? -1.0 : 1.0;
      for (var i = 0; i < ids.length; i++) {
        final step = i + 1;
        positions[ids[i]] = Offset(
          origin.dx + diagX * step,
          origin.dy + dirY * diagY * step,
        );
      }
    }

    // From #2 (in_luck1) — UP: Secret Informant
    placeBranch('in_luck1', [
      'in_tip_free1', 'in_tip_free2', 'in_tip_disc1', 'in_tip_disc2', 'in_tip_exact',
    ], goUp: true);

    // From #2 (in_luck1) — DOWN: FintTok
    placeBranch('in_luck1', [
      'in_ftk_acc1', 'in_ftk_acc2', 'in_ftk_slot1', 'in_ftk_slot2', 'in_ftk_flag',
    ], goUp: false);

    // From #5 (in_luck2) — UP: News & Events
    placeBranch('in_luck2', [
      'in_news1', 'in_news2', 'in_block1', 'in_disinfo',
    ], goUp: true);

    // From #5 (in_luck2) — DOWN: Advanced Informant
    placeBranch('in_luck2', [
      'in_tip_prec1', 'in_tip_prec2', 'in_tip_free3',
    ], goUp: false);
  }

  // ═══════════════════════════════════════════════════════════════
  // Sector fan (full circle around sector_root)
  // ═══════════════════════════════════════════════════════════════

  static void _layoutSectorFan(List<TalentNode> nodes, Map<String, Offset> positions) {
    const sectorIds = [
      'tech', 'healthcare', 'finance', 'energy',
      'consumer', 'industrial', 'realestate', 'telecom',
      'materials', 'utilities', 'gaming', 'crypto',
      'aerospace', 'commodities', 'forex', 'indices',
    ];

    // Full circle: 2π spread across 16 spokes
    const fullCircle = 2 * pi;
    // Start at top (-π/2) so first spoke points up
    const startAngle = -pi / 2;

    for (var si = 0; si < sectorIds.length; si++) {
      final sectorId = sectorIds[si];
      final spokeAngle = startAngle + (fullCircle * si / sectorIds.length);

      // 13 nodes per spoke, all in-line along the spoke direction
      final spokeNodeIds = <String>[
        '${sectorId}_t1',
        '${sectorId}_t1_profit', '${sectorId}_t1_shield', '${sectorId}_t1_income',
        '${sectorId}_t2',
        '${sectorId}_t2_profit', '${sectorId}_t2_shield', '${sectorId}_t2_income',
        '${sectorId}_t3',
        '${sectorId}_t3_profit', '${sectorId}_t3_shield', '${sectorId}_t3_income',
        '${sectorId}_cap',
      ];

      for (var i = 0; i < spokeNodeIds.length; i++) {
        final dist = hubDistance + sectorNodeSpacing * (i + 1);
        positions[spokeNodeIds[i]] = Offset(
          secCx + dist * cos(spokeAngle),
          secCy + dist * sin(spokeAngle),
        );
      }

      // Sector label at start of spoke (between hub and T1)
      final labelDist = hubDistance * 0.7;
      positions['sl_$sectorId'] = Offset(
        secCx + labelDist * cos(spokeAngle),
        secCy + labelDist * sin(spokeAngle),
      );
    }
  }
}
