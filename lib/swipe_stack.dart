import 'dart:math';

import 'package:flutter/material.dart';

class _StackItem {
  Widget child;
  int index;
  bool visible;

  _StackItem({required this.child, required this.index, this.visible = true});
}

/// A widget that provides a stack of cards that can be swiped vertically.
/// It is similar to the Tinder app's stack of cards.
/// The [itemCount] and [itemBuilder] arguments must not be null.
class SwipeStack extends StatefulWidget {
  const SwipeStack({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    // this.itemExtent = 200,
    this.displacement = 60,
    this.initialIndex = 0,
    this.minimumDragDistance = 200,
    this.maxVisibleTopStackItem = 2,
    this.maxVisibleBottomStackItem = 2,
    this.opacityAnimationDuration = const Duration(milliseconds: 250),
    this.transitionDuration = const Duration(milliseconds: 500),
    this.scaleFactor = 0.3,
  })  : assert(itemCount > 0, "Item count must be greater than 0"),
        assert(initialIndex >= 0, "Initial index can not be negative"),
        assert(initialIndex < itemCount, "Initial index out of range"),
        assert(minimumDragDistance > 0,
            "Minimum drag distance must be greater than 0"),
        assert(maxVisibleTopStackItem >= 0,
            "Maximum visible top stack item can not be negative"),
        assert(maxVisibleBottomStackItem >= 0,
            "Maximum visible bottom stack item can not be negative");

  /// The builder functions that builds the widget at the given index.
  final IndexedWidgetBuilder itemBuilder;

  /// The number of items in the stack.
  final int itemCount;

  /// The distance between each item in the stack.
  final double displacement;

  /// The initial index of the item to be shown.
  final int initialIndex;

  /// The minimum distance that the item must be dragged to be considered as swiped.
  final double minimumDragDistance;

  /// The maximum number of items that can be visible at the top of the stack.
  final int maxVisibleTopStackItem;

  /// The maximum number of items that can be visible at the bottom of the stack.
  final int maxVisibleBottomStackItem;

  /// The duration of the opacity animation when the item is being swiped.
  final Duration opacityAnimationDuration;

  /// The duration of the transition animation when the item is being swiped.
  final Duration transitionDuration;

  /// The scale factor of the item when it is being swiped.
  final double scaleFactor;

  @override
  State<SwipeStack> createState() => _SwipeStackState();
}

class _SwipeStackState extends State<SwipeStack> with TickerProviderStateMixin {
  final List<_StackItem> _topCards = [];
  final List<_StackItem> _bottomCards = [];
  late final List<double> _positions;
  late final List<double> _currentPositions;
  late _StackItem currentWidget;
  int _currentIndex = 0;
  double _dragDelta = 0;

  late final AnimationController _animationController;

  void _calculatePositions() {
    for (int i = 0; i < _currentIndex; i++) {
      _positions[i] = (_currentIndex - i) * widget.displacement;
    }
    for (int i = 0; i < widget.itemCount - _currentIndex - 1; i++) {
      _positions[i + _currentIndex + 1] = (i + 1) * -widget.displacement;
    }
    _positions[_currentIndex] = 0;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _positions = List.generate(widget.itemCount, (_) => 0.0);
    _calculatePositions();
    _currentPositions = List.from(_positions);

    _arrangeWidgets();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.addListener(_currentPositionUpdater);
  }

  void _arrangeWidgets() {
    _topCards.clear();
    _bottomCards.clear();

    for (int i = 0; i < _currentIndex; i++) {
      // if (_currentIndex - i > _maxVisibleWidget) continue;
      if (_currentIndex - i > widget.maxVisibleBottomStackItem + 1) continue;
      _bottomCards.add(
        _StackItem(
          child: widget.itemBuilder(context, i),
          index: i,
          visible: true,
        ),
      );
    }

    for (int i = widget.itemCount - 1; i > _currentIndex; i--) {
      // if (i - _currentIndex > _maxVisibleWidget) continue;
      if (i - _currentIndex > widget.maxVisibleTopStackItem + 1) continue;
      _topCards.add(
        _StackItem(
          child: widget.itemBuilder(context, i),
          index: i,
          visible: true,
        ),
      );
    }

    currentWidget = _StackItem(
      child: widget.itemBuilder(context, _currentIndex),
      index: _currentIndex,
    );
  }

  void _addDeltaToCurrentPositions() {
    for (int i = 0; i < _currentPositions.length; i++) {
      if (i != _currentIndex) {
        _currentPositions[i] = _positions[i] + _dragDelta / 10;
      } else {
        _currentPositions[i] = _positions[i] + (_dragDelta);
      }
    }
  }

  void _resetPositions() {
    setState(() {
      // print(_dragDelta);
      if (_dragDelta.abs() > widget.minimumDragDistance) {
        int direction = _dragDelta > 0 ? 1 : -1;
        _currentIndex = min(_currentIndex + direction, widget.itemCount - 1);
      }
      _calculatePositions();
      _arrangeWidgets();
    });
    _updateCurrentPositions();
  }

  void _updateCurrentPositions() async {
    _dragDelta = 0;
    _animationController.reset();
    await _animationController.forward();
  }

  void _currentPositionUpdater() {
    setState(() {
      for (int i = 0; i < widget.itemCount; i++) {
        _currentPositions[i] =
            Tween<double>(begin: _currentPositions[i], end: _positions[i])
                .animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.easeInOut))
                .value;
        // if (_animationController.value > 0.8 && !_canDrag) {
        //   _canDrag = true;
        // }
      }
    });
  }

  double _calculateScaleByCurrentPosition(int index) {
    return 1.0 - (widget.scaleFactor * _currentPositions[index].abs() / 100);
  }

  @override
  Widget build(BuildContext context) {
    // print(_canDrag);
    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          _dragDelta += details.delta.dy;
          _addDeltaToCurrentPositions();
        });
      },
      onVerticalDragStart: (details) {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        _resetPositions();
      },
      onVerticalDragCancel: () {
        _resetPositions();
      },
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center, // fit: StackFit.expand,
          children: [
            ..._bottomCards.map(
              (e) => AnimatedOpacity(
                key: ValueKey(e.index),
                duration: const Duration(milliseconds: 300),
                opacity:
                    _currentIndex - e.index > widget.maxVisibleBottomStackItem
                        ? 0
                        : 1,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(
                      0.0,
                      _currentPositions[e.index],
                    )
                    ..scale(_calculateScaleByCurrentPosition(e.index)),
                  alignment: Alignment.center,
                  child: e.child,
                ),
              ),
            ),
            ..._topCards.map(
              (e) => AnimatedOpacity(
                key: ValueKey(e.index),
                duration: const Duration(milliseconds: 300),
                opacity: e.index - _currentIndex > widget.maxVisibleTopStackItem
                    ? 0
                    : 1,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, _currentPositions[e.index])
                    ..scale(_calculateScaleByCurrentPosition(e.index)),
                  alignment: Alignment.center,
                  child: e.child,
                ),
              ),
            ),
            AnimatedOpacity(
              key: ValueKey(_currentIndex),
              duration: const Duration(milliseconds: 300),
              opacity: 1,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, _currentPositions[_currentIndex])
                  ..scale(_calculateScaleByCurrentPosition(_currentIndex)),
                alignment: Alignment.center,
                child: currentWidget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
