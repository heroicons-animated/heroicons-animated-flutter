import 'package:flutter/animation.dart';

/// Base class for all element animations.
sealed class ElementAnimation {
  const ElementAnimation({
    required this.duration,
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  final Duration duration;
  final Duration delay;
  final Curve curve;
}

/// Animates the stroke drawing from [from] to [to] (0.0 to 1.0).
///
/// Uses `Path.computeMetrics()` and `extractPath()` under the hood.
class PathLengthAnimation extends ElementAnimation {
  const PathLengthAnimation({
    required this.from,
    required this.to,
    required super.duration,
    super.delay,
    super.curve,
    this.fromOffset = 0,
    this.toOffset = 0,
  });

  final double from;
  final double to;

  /// Path offset start value (0.0 to 1.0). Maps to framer-motion's
  /// `pathOffset`.
  final double fromOffset;

  /// Path offset end value (0.0 to 1.0).
  final double toOffset;
}

/// Animates opacity from [from] to [to].
class OpacityAnimation extends ElementAnimation {
  const OpacityAnimation({
    required this.from,
    required this.to,
    required super.duration,
    super.delay,
    super.curve,
  });

  final double from;
  final double to;
}

/// Simple rotation animation from [fromDegrees] to [toDegrees].
class RotateAnimation extends ElementAnimation {
  const RotateAnimation({
    required this.fromDegrees,
    required this.toDegrees,
    required super.duration,
    super.delay,
    super.curve,
    this.originX = 0.5,
    this.originY = 0.5,
  });

  final double fromDegrees;
  final double toDegrees;

  /// Rotation origin X as fraction (0.0 = left, 0.5 = center, 1.0 = right).
  final double originX;

  /// Rotation origin Y as fraction (0.0 = top, 0.5 = center, 1.0 = bottom).
  final double originY;
}

/// Keyframe-based rotation animation for shake effects.
///
/// Example: `keyframes: [0, -10, 10, -10, 0]` creates a shake.
class RotateKeyframeAnimation extends ElementAnimation {
  const RotateKeyframeAnimation({
    required this.keyframes,
    required super.duration,
    super.delay,
    super.curve,
    this.originX = 0.5,
    this.originY = 0.5,
  });

  /// List of rotation values in degrees at evenly spaced intervals.
  final List<double> keyframes;

  final double originX;
  final double originY;
}

/// Simple scale animation from [from] to [to].
class ScaleAnimation extends ElementAnimation {
  const ScaleAnimation({
    required this.from,
    required this.to,
    required super.duration,
    super.delay,
    super.curve,
  });

  final double from;
  final double to;
}

/// Keyframe-based scale animation for pulse effects.
///
/// Example: `keyframes: [1, 1.08, 1]` creates a pulse.
class ScaleKeyframeAnimation extends ElementAnimation {
  const ScaleKeyframeAnimation({
    required this.keyframes,
    required super.duration,
    super.delay,
    super.curve,
  });

  /// List of scale values at evenly spaced intervals.
  final List<double> keyframes;
}

/// Simple translate animation.
class TranslateAnimation extends ElementAnimation {
  const TranslateAnimation({
    required super.duration,
    super.delay,
    super.curve,
    this.fromX = 0,
    this.fromY = 0,
    this.toX = 0,
    this.toY = 0,
  });

  final double fromX;
  final double fromY;
  final double toX;
  final double toY;
}

/// Keyframe-based translate animation.
class TranslateKeyframeAnimation extends ElementAnimation {
  const TranslateKeyframeAnimation({
    required this.keyframesX,
    required this.keyframesY,
    required super.duration,
    super.delay,
    super.curve,
  });

  /// X translation keyframes. Empty list means no X translation.
  final List<double> keyframesX;

  /// Y translation keyframes. Empty list means no Y translation.
  final List<double> keyframesY;
}

/// Combines multiple animation types on a single element.
class CombinedAnimation extends ElementAnimation {
  const CombinedAnimation({
    required super.duration,
    super.delay,
    super.curve,
    this.pathLength,
    this.opacity,
    this.rotate,
    this.rotateKeyframe,
    this.scale,
    this.scaleKeyframe,
    this.translate,
    this.translateKeyframe,
  });

  final PathLengthAnimation? pathLength;
  final OpacityAnimation? opacity;
  final RotateAnimation? rotate;
  final RotateKeyframeAnimation? rotateKeyframe;
  final ScaleAnimation? scale;
  final ScaleKeyframeAnimation? scaleKeyframe;
  final TranslateAnimation? translate;
  final TranslateKeyframeAnimation? translateKeyframe;
}
