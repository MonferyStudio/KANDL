import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../core/big_number.dart';
import '../../core/number_formatter.dart';

/// Animated counter that smoothly transitions between numbers
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;
  final int decimals;
  final bool showSign;
  final Color? positiveColor;
  final Color? negativeColor;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.decimals = 2,
    this.showSign = false,
    this.positiveColor,
    this.negativeColor,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        String text = animatedValue.toStringAsFixed(decimals);

        if (showSign && animatedValue > 0) {
          text = '+$text';
        }

        if (prefix != null) text = '$prefix$text';
        if (suffix != null) text = '$text$suffix';

        Color? textColor;
        if (positiveColor != null || negativeColor != null) {
          if (animatedValue > 0) {
            textColor = positiveColor ?? theme.positive;
          } else if (animatedValue < 0) {
            textColor = negativeColor ?? theme.negative;
          }
        }

        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(
            color: textColor ?? style?.color,
          ),
        );
      },
    );
  }
}

/// Animated BigNumber counter
class AnimatedBigNumberCounter extends StatefulWidget {
  final BigNumber value;
  final String? prefix;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;
  final bool compact;
  final bool showSign;
  final Color? positiveColor;
  final Color? negativeColor;

  const AnimatedBigNumberCounter({
    super.key,
    required this.value,
    this.prefix,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.compact = true,
    this.showSign = false,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  State<AnimatedBigNumberCounter> createState() => _AnimatedBigNumberCounterState();
}

class _AnimatedBigNumberCounterState extends State<AnimatedBigNumberCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  BigNumber _oldValue = BigNumber.zero;
  BigNumber _newValue = BigNumber.zero;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _newValue = widget.value;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(AnimatedBigNumberCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _newValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BigNumber _interpolate(double t) {
    // Linear interpolation between old and new values
    final diff = _newValue - _oldValue;
    final scaledDiff = diff * BigNumber(t);
    return _oldValue + scaledDiff;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _interpolate(_animation.value);
        String text = widget.compact
            ? NumberFormatter.formatCompact(currentValue)
            : currentValue.toString();

        if (widget.showSign && currentValue > BigNumber.zero) {
          text = '+$text';
        }

        if (widget.prefix != null) text = '${widget.prefix}$text';
        if (widget.suffix != null) text = '$text${widget.suffix}';

        Color? textColor;
        if (widget.positiveColor != null || widget.negativeColor != null) {
          if (currentValue > BigNumber.zero) {
            textColor = widget.positiveColor ?? theme.positive;
          } else if (currentValue < BigNumber.zero) {
            textColor = widget.negativeColor ?? theme.negative;
          }
        }

        return Text(
          text,
          style: (widget.style ?? const TextStyle()).copyWith(
            color: textColor ?? widget.style?.color,
          ),
        );
      },
    );
  }
}

/// Counter with slot machine style rolling numbers
class RollingCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final int minDigits;

  const RollingCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.minDigits = 1,
  });

  @override
  State<RollingCounter> createState() => _RollingCounterState();
}

class _RollingCounterState extends State<RollingCounter> {
  late List<int> _digits;

  @override
  void initState() {
    super.initState();
    _digits = _getDigits(widget.value);
  }

  @override
  void didUpdateWidget(RollingCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _digits = _getDigits(widget.value);
    }
  }

  List<int> _getDigits(int value) {
    final digits = <int>[];
    int v = value.abs();
    do {
      digits.insert(0, v % 10);
      v ~/= 10;
    } while (v > 0);

    while (digits.length < widget.minDigits) {
      digits.insert(0, 0);
    }

    return digits;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.value < 0)
          Text('-', style: widget.style),
        ...List.generate(_digits.length, (index) {
          return _RollingDigit(
            digit: _digits[index],
            style: widget.style,
            duration: widget.duration,
          );
        }),
      ],
    );
  }
}

class _RollingDigit extends StatefulWidget {
  final int digit;
  final TextStyle? style;
  final Duration duration;

  const _RollingDigit({
    required this.digit,
    this.style,
    required this.duration,
  });

  @override
  State<_RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<_RollingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _oldDigit = 0;
  int _newDigit = 0;

  @override
  void initState() {
    super.initState();
    _oldDigit = widget.digit;
    _newDigit = widget.digit;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(_RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _oldDigit = oldWidget.digit;
      _newDigit = widget.digit;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? const TextStyle();
    final height = (style.fontSize ?? 14) * 1.2;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: height,
          child: ClipRect(
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(0, -_animation.value * height),
                  child: Text('$_oldDigit', style: style),
                ),
                Transform.translate(
                  offset: Offset(0, (1 - _animation.value) * height),
                  child: Text('$_newDigit', style: style),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
