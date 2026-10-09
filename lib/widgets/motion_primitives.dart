import 'package:flutter/material.dart';
import '../constants/app_tokens.dart';

/// Standard panel content transition with subtle vertical float and opacity.
class FidsPanelTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset enterOffset;

  const FidsPanelTransition({
    super.key,
    required this.child,
    this.duration = AppTokens.durationLong,
    this.enterOffset = const Offset(0.0, 0.08),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: enterOffset,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A card that pulses an ambient glow wave when [isHighlight] is active.
class PulsingGlowCard extends StatefulWidget {
  final Widget child;
  final bool isHighlight;
  final Color glowColor;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const PulsingGlowCard({
    super.key,
    required this.child,
    required this.isHighlight,
    required this.glowColor,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.transparent,
    this.padding = const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
    this.borderRadius,
  });

  @override
  State<PulsingGlowCard> createState() => _PulsingGlowCardState();
}

class _PulsingGlowCardState extends State<PulsingGlowCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppTokens.durationPulseCycle,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );

    if (widget.isHighlight) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingGlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlight != oldWidget.isHighlight) {
      if (widget.isHighlight) {
        _pulseController.forward(from: 0.0);
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.animateTo(0.0, duration: AppTokens.durationFast);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(10.0);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final double pulseVal = widget.isHighlight ? _pulseAnimation.value : 0.0;
        final double baseAlpha = widget.isHighlight ? (0.10 + 0.14 * pulseVal) : 0.0;

        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.isHighlight
                ? widget.glowColor.withValues(alpha: baseAlpha)
                : Colors.transparent,
            borderRadius: radius,
            boxShadow: widget.isHighlight
                ? [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.16 + 0.12 * pulseVal),
                      blurRadius: 28.0 + 12.0 * pulseVal,
                      spreadRadius: 1.0 + 2.0 * pulseVal,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Animated ticker roll for numbers and codes.
class AnimatedDigitText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const AnimatedDigitText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppTokens.durationNormal,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.35),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}

/// Blinking status dot for live indicators.
class BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;

  const BlinkingDot({
    super.key,
    required this.color,
    this.size = 10.0,
  });

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.6 + 0.4 * _controller.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3 + 0.4 * _controller.value),
                blurRadius: 8.0 * _controller.value + 4.0,
                spreadRadius: 2.0 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
