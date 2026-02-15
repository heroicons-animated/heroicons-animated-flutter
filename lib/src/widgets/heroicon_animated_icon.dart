import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:heroicons_animated/src/models/animation.dart';
import 'package:heroicons_animated/src/models/element.dart';
import 'package:heroicons_animated/src/models/icon_data.dart';
import 'package:heroicons_animated/src/painters/animated_path_painter.dart';
import 'package:heroicons_animated/src/widgets/controller.dart';

/// Renders an animated Heroicon.
///
/// The icon animates based on the [trigger] parameter:
/// - [AnimationTrigger.onTap]: animate on tap (default)
/// - [AnimationTrigger.onHover]: animate on mouse enter
/// - [AnimationTrigger.loop]: continuously loop
/// - [AnimationTrigger.manual]: controlled via [controller]
///
/// ```dart
/// HeroiconAnimatedIcon(
///   icon: heart,
///   size: 32,
///   color: Colors.red,
///   trigger: AnimationTrigger.onTap,
/// )
/// ```
class HeroiconAnimatedIcon extends StatefulWidget {
  const HeroiconAnimatedIcon({
    required this.icon,
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.trigger = AnimationTrigger.onTap,
    this.controller,
    this.onTap,
    this.duration,
    this.curve,
    this.strokeWidth,
  });

  /// The icon data containing paths and animation definitions.
  final HeroiconAnimatedIconData icon;

  /// The size of the icon in logical pixels.
  final double size;

  /// The stroke color of the icon.
  final Color color;

  /// How the animation is triggered.
  final AnimationTrigger trigger;

  /// Optional controller for manual animation control.
  final HeroiconAnimatedIconController? controller;

  /// Optional tap callback (fires in addition to animation on tap trigger).
  final VoidCallback? onTap;

  /// Override the default animation duration.
  final Duration? duration;

  /// Override the default animation curve.
  final Curve? curve;

  /// Override the icon's default stroke width.
  final double? strokeWidth;

  @override
  State<HeroiconAnimatedIcon> createState() => _HeroiconAnimatedIconState();
}

class _HeroiconAnimatedIconState extends State<HeroiconAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isForward = true;

  Duration get _effectiveDuration {
    if (widget.duration != null) return widget.duration!;
    final iconAnim = widget.icon.animation;
    if (iconAnim != null) return iconAnim.duration;
    // Find the longest element animation duration + delay.
    var maxDuration = const Duration(milliseconds: 500);
    for (final element in widget.icon.elements) {
      final anim = element.animation;
      if (anim != null) {
        final total = anim.duration + anim.delay;
        if (total > maxDuration) maxDuration = total;
      }
    }
    return maxDuration;
  }

  double get _scaleFactor => widget.size / widget.icon.viewBoxWidth;

  double get _effectiveStrokeWidth =>
      widget.strokeWidth ?? widget.icon.strokeWidth;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _effectiveDuration,
    );

    _animationController.addStatusListener(_onAnimationStatus);

    widget.controller?.addListener(_onControllerChanged);

    if (widget.trigger == AnimationTrigger.loop) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HeroiconAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }

    if (oldWidget.duration != widget.duration ||
        oldWidget.icon != widget.icon) {
      _animationController.duration = _effectiveDuration;
    }

    if (oldWidget.trigger != widget.trigger) {
      if (widget.trigger == AnimationTrigger.loop) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.controller?.setAnimating(animating: false);
    }
  }

  void _onControllerChanged() {
    final ctrl = widget.controller;
    if (ctrl == null) return;

    if (ctrl.shouldAnimate) {
      ctrl
        ..consumeRequests()
        ..setAnimating(animating: true);
      _animationController
        ..reset()
        ..forward();
    } else if (ctrl.shouldReverse) {
      ctrl
        ..consumeRequests()
        ..setAnimating(animating: true);
      _animationController.reverse();
    } else if (ctrl.shouldReset) {
      ctrl
        ..consumeRequests()
        ..setAnimating(animating: false);
      _animationController.reset();
    }
  }

  void _triggerAnimation() {
    if (_animationController.isAnimating) return;

    if (_isForward) {
      _animationController
        ..reset()
        ..forward();
    } else {
      _animationController.reverse(from: 1);
    }
    _isForward = !_isForward;
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) => _buildIcon(),
      ),
    );

    // Wrap in icon-level animation transforms.
    if (widget.icon.animation != null) {
      icon = RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => _applyIconAnimation(
            child: child!,
            animation: widget.icon.animation!,
            t: _animationController.value,
          ),
          child: icon,
        ),
      );
    }

    switch (widget.trigger) {
      case AnimationTrigger.onTap:
        return GestureDetector(
          onTap: () {
            _triggerAnimation();
            widget.onTap?.call();
          },
          child: icon,
        );
      case AnimationTrigger.onHover:
        return MouseRegion(
          onEnter: (_) => _triggerAnimation(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: icon,
          ),
        );
      case AnimationTrigger.loop:
      case AnimationTrigger.manual:
        return GestureDetector(
          onTap: widget.onTap,
          child: icon,
        );
    }
  }

  Widget _buildIcon() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          for (final element in widget.icon.elements)
            _buildElement(element),
        ],
      ),
    );
  }

  Widget _buildElement(IconElement element) {
    switch (element) {
      case PathElement():
        return _buildPathElement(element);
      case CircleElement():
        return _buildCircleElement(element);
      case RectElement():
        return _buildRectElement(element);
      case LineElement():
        return _buildLineElement(element);
      case PolylineElement():
        return _buildPolylineElement(element);
    }
  }

  Widget _buildPathElement(PathElement element) {
    final anim = element.animation;
    final t = _getAnimationValue(anim);

    Widget child;

    if (_hasPathLengthAnimation(anim)) {
      final plAnim = _getPathLengthAnimation(anim);
      final progress = _lerpValue(plAnim!.from, plAnim.to, t);
      final offset = _lerpValue(plAnim.fromOffset, plAnim.toOffset, t);
      final opacity = _getOpacityValue(anim, t);

      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: AnimatedPathPainter(
          pathData: element.d,
          progress: progress,
          pathOffset: offset,
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    } else {
      final opacity = _getOpacityValue(anim, t);

      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: StaticPathPainter(
          pathDataList: [element.d],
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    }

    return _applyElementTransforms(
      child: child,
      animation: anim,
      t: t,
    );
  }

  Widget _buildCircleElement(CircleElement element) {
    final anim = element.animation;
    final t = _getAnimationValue(anim);

    Widget child;

    if (_hasPathLengthAnimation(anim)) {
      final plAnim = _getPathLengthAnimation(anim);
      final progress = _lerpValue(plAnim!.from, plAnim.to, t);
      final opacity = _getOpacityValue(anim, t);

      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: AnimatedCirclePainter(
          cx: element.cx,
          cy: element.cy,
          r: element.r,
          progress: progress,
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    } else {
      final opacity = _getOpacityValue(anim, t);

      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: CirclePainter(
          cx: element.cx,
          cy: element.cy,
          r: element.r,
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    }

    return _applyElementTransforms(
      child: child,
      animation: anim,
      t: t,
    );
  }

  Widget _buildRectElement(RectElement element) {
    // Convert rect to a path for rendering.
    final rx = element.rx;
    final ry = element.ry;
    final pathData = rx > 0 || ry > 0
        ? 'M${element.x + rx},${element.y}'
            'L${element.x + element.width - rx},${element.y}'
            'Q${element.x + element.width},${element.y}'
            ' ${element.x + element.width},${element.y + ry}'
            'L${element.x + element.width},${element.y + element.height - ry}'
            'Q${element.x + element.width},${element.y + element.height}'
            ' ${element.x + element.width - rx},${element.y + element.height}'
            'L${element.x + rx},${element.y + element.height}'
            'Q${element.x},${element.y + element.height}'
            ' ${element.x},${element.y + element.height - ry}'
            'L${element.x},${element.y + ry}'
            'Q${element.x},${element.y}'
            ' ${element.x + rx},${element.y}Z'
        : 'M${element.x},${element.y}'
            'L${element.x + element.width},${element.y}'
            'L${element.x + element.width},${element.y + element.height}'
            'L${element.x},${element.y + element.height}Z';

    final anim = element.animation;
    final t = _getAnimationValue(anim);
    final opacity = _getOpacityValue(anim, t);

    Widget child;
    if (_hasPathLengthAnimation(anim)) {
      final plAnim = _getPathLengthAnimation(anim);
      final progress = _lerpValue(plAnim!.from, plAnim.to, t);

      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: AnimatedPathPainter(
          pathData: pathData,
          progress: progress,
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    } else {
      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: StaticPathPainter(
          pathDataList: [pathData],
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    }

    return _applyElementTransforms(child: child, animation: anim, t: t);
  }

  Widget _buildLineElement(LineElement element) {
    final pathData = 'M${element.x1},${element.y1}'
        'L${element.x2},${element.y2}';

    final anim = element.animation;
    final t = _getAnimationValue(anim);
    final opacity = _getOpacityValue(anim, t);

    Widget child;
    if (_hasPathLengthAnimation(anim)) {
      final plAnim = _getPathLengthAnimation(anim);
      final progress = _lerpValue(plAnim!.from, plAnim.to, t);

      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: AnimatedPathPainter(
          pathData: pathData,
          progress: progress,
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    } else {
      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: StaticPathPainter(
          pathDataList: [pathData],
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    }

    return _applyElementTransforms(child: child, animation: anim, t: t);
  }

  Widget _buildPolylineElement(PolylineElement element) {
    // Convert points to path data.
    final points = element.points.trim().split(RegExp(r'\s+'));
    if (points.isEmpty) return const SizedBox.shrink();

    final buffer = StringBuffer('M${points[0]}');
    for (var i = 1; i < points.length; i++) {
      buffer.write('L${points[i]}');
    }
    final pathData = buffer.toString();

    final anim = element.animation;
    final t = _getAnimationValue(anim);
    final opacity = _getOpacityValue(anim, t);

    Widget child;
    if (_hasPathLengthAnimation(anim)) {
      final plAnim = _getPathLengthAnimation(anim);
      final progress = _lerpValue(plAnim!.from, plAnim.to, t);

      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: AnimatedPathPainter(
          pathData: pathData,
          progress: progress,
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    } else {
      child = CustomPaint(
        size: Size(widget.size, widget.size),
        painter: StaticPathPainter(
          pathDataList: [pathData],
          color: widget.color,
          strokeWidth: _effectiveStrokeWidth,
          scaleFactor: _scaleFactor,
          opacity: opacity,
        ),
      );
    }

    return _applyElementTransforms(child: child, animation: anim, t: t);
  }

  // ── Animation helpers ──────────────────────────────────────────

  /// Gets the animation progress value, accounting for delay.
  double _getAnimationValue(ElementAnimation? anim) {
    if (anim == null) return _animationController.value;

    final totalMs = _effectiveDuration.inMicroseconds.toDouble();
    if (totalMs <= 0) return _animationController.value;

    final delayMs = anim.delay.inMicroseconds.toDouble();
    final durationMs = anim.duration.inMicroseconds.toDouble();
    final rawT = _animationController.value;

    // Map the global progress to this element's local progress.
    final elementStart = delayMs / totalMs;
    final elementEnd = (delayMs + durationMs) / totalMs;
    final range = elementEnd - elementStart;

    if (range <= 0) return rawT;

    final localT = ((rawT - elementStart) / range).clamp(0.0, 1.0);
    return anim.curve.transform(localT.toDouble());
  }

  /// Checks if the animation includes pathLength.
  bool _hasPathLengthAnimation(ElementAnimation? anim) {
    if (anim == null) return false;
    if (anim is PathLengthAnimation) return true;
    if (anim is CombinedAnimation) return anim.pathLength != null;
    return false;
  }

  /// Extracts the PathLengthAnimation from the animation.
  PathLengthAnimation? _getPathLengthAnimation(ElementAnimation? anim) {
    if (anim is PathLengthAnimation) return anim;
    if (anim is CombinedAnimation) return anim.pathLength;
    return null;
  }

  /// Gets opacity value from the animation at progress [t].
  double _getOpacityValue(ElementAnimation? anim, double t) {
    if (anim == null) return 1;
    if (anim is OpacityAnimation) {
      return _lerpValue(anim.from, anim.to, t);
    }
    if (anim is CombinedAnimation && anim.opacity != null) {
      return _lerpValue(anim.opacity!.from, anim.opacity!.to, t);
    }
    return 1;
  }

  /// Applies transform-based animations (rotate, scale, translate).
  Widget _applyElementTransforms({
    required Widget child,
    required ElementAnimation? animation,
    required double t,
  }) {
    if (animation == null) return child;

    var result = child;

    // Scale.
    final scaleValue = _getScaleValue(animation, t);
    if (scaleValue != null && scaleValue != 1.0) {
      result = Transform.scale(
        scale: scaleValue,
        child: result,
      );
    }

    // Rotate.
    final rotateValue = _getRotateValue(animation, t);
    if (rotateValue != null && rotateValue != 0.0) {
      final originX = _getRotateOriginX(animation);
      final originY = _getRotateOriginY(animation);
      result = Transform.rotate(
        angle: rotateValue * math.pi / 180,
        origin: Offset(
          (originX - 0.5) * widget.size,
          (originY - 0.5) * widget.size,
        ),
        child: result,
      );
    }

    // Translate.
    final translateOffset = _getTranslateValue(animation, t);
    if (translateOffset != null && translateOffset != Offset.zero) {
      result = Transform.translate(
        offset: translateOffset * _scaleFactor,
        child: result,
      );
    }

    return result;
  }

  /// Applies icon-level animation transforms.
  Widget _applyIconAnimation({
    required Widget child,
    required ElementAnimation animation,
    required double t,
  }) {
    final curvedT = animation.curve.transform(t.clamp(0, 1));
    return _applyElementTransforms(
      child: child,
      animation: animation,
      t: curvedT,
    );
  }

  double? _getScaleValue(ElementAnimation anim, double t) {
    if (anim is ScaleAnimation) {
      return _lerpValue(anim.from, anim.to, t);
    }
    if (anim is ScaleKeyframeAnimation) {
      return _interpolateKeyframes(anim.keyframes, t);
    }
    if (anim is CombinedAnimation) {
      if (anim.scale != null) {
        return _lerpValue(anim.scale!.from, anim.scale!.to, t);
      }
      if (anim.scaleKeyframe != null) {
        return _interpolateKeyframes(anim.scaleKeyframe!.keyframes, t);
      }
    }
    return null;
  }

  double? _getRotateValue(ElementAnimation anim, double t) {
    if (anim is RotateAnimation) {
      return _lerpValue(anim.fromDegrees, anim.toDegrees, t);
    }
    if (anim is RotateKeyframeAnimation) {
      return _interpolateKeyframes(anim.keyframes, t);
    }
    if (anim is CombinedAnimation) {
      if (anim.rotate != null) {
        return _lerpValue(
          anim.rotate!.fromDegrees,
          anim.rotate!.toDegrees,
          t,
        );
      }
      if (anim.rotateKeyframe != null) {
        return _interpolateKeyframes(anim.rotateKeyframe!.keyframes, t);
      }
    }
    return null;
  }

  double _getRotateOriginX(ElementAnimation anim) {
    if (anim is RotateAnimation) return anim.originX;
    if (anim is RotateKeyframeAnimation) return anim.originX;
    if (anim is CombinedAnimation) {
      if (anim.rotate != null) return anim.rotate!.originX;
      if (anim.rotateKeyframe != null) return anim.rotateKeyframe!.originX;
    }
    return 0.5;
  }

  double _getRotateOriginY(ElementAnimation anim) {
    if (anim is RotateAnimation) return anim.originY;
    if (anim is RotateKeyframeAnimation) return anim.originY;
    if (anim is CombinedAnimation) {
      if (anim.rotate != null) return anim.rotate!.originY;
      if (anim.rotateKeyframe != null) return anim.rotateKeyframe!.originY;
    }
    return 0.5;
  }

  Offset? _getTranslateValue(ElementAnimation anim, double t) {
    if (anim is TranslateAnimation) {
      return Offset(
        _lerpValue(anim.fromX, anim.toX, t),
        _lerpValue(anim.fromY, anim.toY, t),
      );
    }
    if (anim is TranslateKeyframeAnimation) {
      return Offset(
        anim.keyframesX.isNotEmpty
            ? _interpolateKeyframes(anim.keyframesX, t)
            : 0,
        anim.keyframesY.isNotEmpty
            ? _interpolateKeyframes(anim.keyframesY, t)
            : 0,
      );
    }
    if (anim is CombinedAnimation) {
      if (anim.translate != null) {
        return Offset(
          _lerpValue(anim.translate!.fromX, anim.translate!.toX, t),
          _lerpValue(anim.translate!.fromY, anim.translate!.toY, t),
        );
      }
      if (anim.translateKeyframe != null) {
        final tk = anim.translateKeyframe!;
        return Offset(
          tk.keyframesX.isNotEmpty
              ? _interpolateKeyframes(tk.keyframesX, t)
              : 0,
          tk.keyframesY.isNotEmpty
              ? _interpolateKeyframes(tk.keyframesY, t)
              : 0,
        );
      }
    }
    return null;
  }

  /// Linearly interpolates between [a] and [b] at progress [t].
  double _lerpValue(double a, double b, double t) => a + (b - a) * t;

  /// Interpolates through a list of keyframe values at progress [t].
  double _interpolateKeyframes(List<double> keyframes, double t) {
    if (keyframes.isEmpty) return 0;
    if (keyframes.length == 1) return keyframes[0];

    final segments = keyframes.length - 1;
    final segmentIndex = (t * segments).floor().clamp(0, segments - 1);
    final segmentT = (t * segments) - segmentIndex;

    return keyframes[segmentIndex] +
        (keyframes[segmentIndex + 1] - keyframes[segmentIndex]) * segmentT;
  }
}
