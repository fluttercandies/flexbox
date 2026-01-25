import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A widget that coordinates scale (pinch-to-zoom) gestures with scrollable content.
///
/// This widget solves the common problem of gesture conflicts between
/// pinch-to-zoom and scroll gestures. When a multi-touch gesture is detected,
/// scrolling is automatically disabled to allow smooth scaling.
///
/// ## Features
/// - Automatic pointer tracking to detect multi-touch gestures
/// - Eager scale gesture recognition that wins over scroll gestures
/// - Optional double-tap support
/// - Provides scaling state via [ScaleScrollState] for conditional rendering
///
/// ## Usage
/// ```dart
/// ScaleScrollCoordinator(
///   onScaleStart: controller.onScaleStart,
///   onScaleUpdate: controller.onScaleUpdate,
///   onScaleEnd: controller.onScaleEnd,
///   onDoubleTap: controller.onDoubleTap,
///   builder: (context, state) {
///     return CustomScrollView(
///       physics: state.isScaling
///           ? const NeverScrollableScrollPhysics()
///           : null,
///       slivers: [...],
///     );
///   },
/// )
/// ```
class ScaleScrollCoordinator extends StatefulWidget {
  const ScaleScrollCoordinator({
    super.key,
    required this.builder,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onDoubleTap,
    this.debugOwner,
  });

  /// Builder function that receives the current [ScaleScrollState].
  ///
  /// Use the state to conditionally disable scrolling when scaling is active.
  final Widget Function(BuildContext context, ScaleScrollState state) builder;

  /// Called when a scale gesture starts.
  final GestureScaleStartCallback? onScaleStart;

  /// Called when a scale gesture updates.
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// Called when a scale gesture ends.
  final GestureScaleEndCallback? onScaleEnd;

  /// Called when a double-tap is detected.
  final GestureTapCallback? onDoubleTap;

  /// Debug owner for the gesture recognizers.
  final Object? debugOwner;

  @override
  State<ScaleScrollCoordinator> createState() => _ScaleScrollCoordinatorState();

  /// Gets the [ScaleScrollState] from the nearest [ScaleScrollCoordinator] ancestor.
  ///
  /// Returns null if no ancestor is found.
  static ScaleScrollState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ScaleScrollInheritedWidget>()
        ?.state;
  }

  /// Gets the [ScaleScrollState] from the nearest [ScaleScrollCoordinator] ancestor.
  ///
  /// Throws if no ancestor is found.
  static ScaleScrollState of(BuildContext context) {
    final state = maybeOf(context);
    assert(state != null, 'No ScaleScrollCoordinator found in context');
    return state!;
  }
}

/// Represents the current state of scale-scroll coordination.
class ScaleScrollState {
  const ScaleScrollState({required this.pointerCount});

  /// The number of active pointers (touch points) on the screen.
  final int pointerCount;

  /// Returns true if multiple pointers are detected (scaling is active).
  bool get isScaling => pointerCount >= 2;

  /// Returns true if a single pointer is active.
  bool get isSingleTouch => pointerCount == 1;

  /// Returns true if no pointers are active.
  bool get isIdle => pointerCount == 0;
}

class _ScaleScrollCoordinatorState extends State<ScaleScrollCoordinator> {
  int _pointerCount = 0;

  ScaleScrollState get _state => ScaleScrollState(pointerCount: _pointerCount);

  void _onPointerDown(PointerDownEvent event) {
    final wasScaling = _pointerCount >= 2;
    _pointerCount++;
    final isScaling = _pointerCount >= 2;

    // Only rebuild if scaling state changed
    if (wasScaling != isScaling) {
      setState(() {});
    }
  }

  void _onPointerUp(PointerEvent event) {
    final wasScaling = _pointerCount >= 2;
    _pointerCount = (_pointerCount - 1).clamp(0, 10);
    final isScaling = _pointerCount >= 2;

    // Only rebuild if scaling state changed
    if (wasScaling != isScaling) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: RawGestureDetector(
        gestures: _buildGestures(),
        child: _ScaleScrollInheritedWidget(
          state: _state,
          child: Builder(builder: (context) => widget.builder(context, _state)),
        ),
      ),
    );
  }

  Map<Type, GestureRecognizerFactory> _buildGestures() {
    final gestures = <Type, GestureRecognizerFactory>{};

    // Add eager scale gesture recognizer
    if (widget.onScaleStart != null ||
        widget.onScaleUpdate != null ||
        widget.onScaleEnd != null) {
      gestures[_EagerScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<_EagerScaleGestureRecognizer>(
            () => _EagerScaleGestureRecognizer(debugOwner: widget.debugOwner),
            (_EagerScaleGestureRecognizer instance) {
              instance
                ..onStart = widget.onScaleStart
                ..onUpdate = widget.onScaleUpdate
                ..onEnd = widget.onScaleEnd;
            },
          );
    }

    // Add double-tap gesture recognizer
    if (widget.onDoubleTap != null) {
      gestures[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
            () => DoubleTapGestureRecognizer(debugOwner: widget.debugOwner),
            (DoubleTapGestureRecognizer instance) {
              instance.onDoubleTap = widget.onDoubleTap;
            },
          );
    }

    return gestures;
  }
}

/// Custom scale gesture recognizer that wins immediately when multiple pointers are detected.
///
/// This ensures pinch-to-zoom gestures take priority over scroll gestures in the
/// gesture arena. Single-finger drags are rejected to allow scrolling.
class _EagerScaleGestureRecognizer extends ScaleGestureRecognizer {
  _EagerScaleGestureRecognizer({super.debugOwner});

  bool _hasMultiplePointers = false;

  @override
  void addPointer(PointerDownEvent event) {
    super.addPointer(event);
    // Track if we have multiple pointers
    _hasMultiplePointers = pointerCount >= 2;
  }

  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);
    // Update tracking as pointers change
    _hasMultiplePointers = pointerCount >= 2;
  }

  @override
  void rejectGesture(int pointer) {
    // Only accept if we have multiple pointers (pinch gesture)
    // Single pointer should be rejected to allow scroll gestures
    if (_hasMultiplePointers) {
      acceptGesture(pointer);
    } else {
      super.rejectGesture(pointer);
    }
  }

  @override
  void dispose() {
    _hasMultiplePointers = false;
    super.dispose();
  }
}

/// InheritedWidget to provide [ScaleScrollState] to descendants.
class _ScaleScrollInheritedWidget extends InheritedWidget {
  const _ScaleScrollInheritedWidget({
    required this.state,
    required super.child,
  });

  final ScaleScrollState state;

  @override
  bool updateShouldNotify(_ScaleScrollInheritedWidget oldWidget) {
    return state.pointerCount != oldWidget.state.pointerCount;
  }
}
