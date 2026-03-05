/// Represents an active gameplay effect for UI display
class ActiveEffect {
  final String name;
  final String description;
  final int daysLeft; // 0 = ends today or instant
  final bool isPositive; // Green if positive, red if negative
  final String icon;

  const ActiveEffect({
    required this.name,
    required this.description,
    required this.daysLeft,
    required this.isPositive,
    required this.icon,
  });

  String get daysLeftText {
    if (daysLeft <= 0) return 'Today';
    if (daysLeft == 1) return '1 day';
    return '$daysLeft days';
  }
}
