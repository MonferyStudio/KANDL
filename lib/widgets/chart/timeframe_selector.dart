import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';

class TimeframeSelector extends StatelessWidget {
  final TimeFrame selectedTimeframe;
  final Function(TimeFrame) onTimeframeChanged;

  const TimeframeSelector({
    super.key,
    required this.selectedTimeframe,
    required this.onTimeframeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimeframeButton(
            label: '30m',
            isActive: selectedTimeframe == TimeFrame.thirtyMinutes,
            onTap: () => onTimeframeChanged(TimeFrame.thirtyMinutes),
          ),
          _TimeframeButton(
            label: '1h',
            isActive: selectedTimeframe == TimeFrame.oneHour,
            onTap: () => onTimeframeChanged(TimeFrame.oneHour),
          ),
          _TimeframeButton(
            label: '2h',
            isActive: selectedTimeframe == TimeFrame.twoHours,
            onTap: () => onTimeframeChanged(TimeFrame.twoHours),
          ),
          _TimeframeButton(
            label: '4h',
            isActive: selectedTimeframe == TimeFrame.fourHours,
            onTap: () => onTimeframeChanged(TimeFrame.fourHours),
          ),
        ],
      ),
    );
  }
}

class _TimeframeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TimeframeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return GestureDetector(
      onTap: () {
        SoundService().playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? theme.background : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}
