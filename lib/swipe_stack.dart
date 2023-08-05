import 'dart:math';

import 'package:flutter/material.dart';

class StackItem {
  Widget child;
  int index;
  bool visible;

  StackItem({required this.child, required this.index, this.visible = true});
}

class SwipeStack extends StatefulWidget {
  const SwipeStack({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    // this.itemExtent = 200,
    this.displacement = 60,
    this.initialIndex = 0,
    this.minimumDragDistance = 200,
    this.maxVisibleStackItem = 5,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  // final double itemExtent;
  final double displacement;
  final int initialIndex;
  final double minimumDragDistance;
  final double maxVisibleStackItem;

  @override
  State<SwipeStack> createState() => _SwipeStackState();
}

class _SwipeStackState extends State<SwipeStack> with TickerProviderStateMixin {
  final List<StackItem> _topCards = [];
  final List<StackItem> _bottomCards = [];
  late final List<double> _positions;
  late final List<double> _currentPositions;
  late StackItem currentWidget;
  int _currentIndex = 0;
  double _dragDelta = 0;
  int get _maxVisibleWidget => (widget.maxVisibleStackItem - 1) ~/ 2;

  late final AnimationController _animationController;

  void _calculatePositions() {
    for (int i = 0; i < _currentIndex; i++) {
      _positions[i] = (_currentIndex - i) * widget.displacement;
    }
    for (int i = 0; i < widget.itemCount - _currentIndex - 1; i++) {
      _positions[i + _currentIndex + 1] = (i + 1) * -widget.displacement;
    }
    _positions[_currentIndex] = 0;
    print(_positions);
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
    _animationController.addListener(_currentPositionListener);
  }

  void _arrangeWidgets() {
    _topCards.clear();
    _bottomCards.clear();

    for (int i = 0; i < _currentIndex; i++) {
      // if (_currentIndex - i > _maxVisibleWidget) continue;
      _bottomCards.add(
        StackItem(
          child: widget.itemBuilder(context, i),
          index: i,
          visible: _currentIndex - i != _maxVisibleWidget,
        ),
      );
    }

    for (int i = widget.itemCount - 1; i > _currentIndex; i--) {
      // if (i - _currentIndex > _maxVisibleWidget) continue;
      _topCards.add(
        StackItem(
          child: widget.itemBuilder(context, i),
          index: i,
          visible: i - _currentIndex != _maxVisibleWidget,
        ),
      );
    }

    currentWidget = StackItem(
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
      print(_dragDelta);
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
    // setState(() {
    //   _canDrag = true;
    // });
  }

  void _currentPositionListener() {
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
    return 1.0 - (0.1 * _currentPositions[index].abs() / 100);
  }

  double _calculateOpacityByCurrentPosition(int index, bool visible) {
    // int indexDistance = _currentIndex - index;
    // if (indexDistance.abs() != _maxVisibleWidget) return 1.0;
    // int nextIndex = indexDistance > 0 ? index + 1 : index - 1;
    // if (nextIndex < 0 || nextIndex >= widget.itemCount) return 1.0;
    // if (_currentPositions[nextIndex].abs() > widget.displacement) return 1.0;
    // double diff = (_currentPositions[nextIndex] - _currentPositions[index])
    //     .clamp(-widget.displacement, widget.displacement);
    if (visible) return 1.0;

    double currentPosition = _currentPositions[index];
    double previousPosition = _positions[index];
    double diff = (currentPosition - previousPosition)
        // .abs()
        .clamp(-widget.displacement, widget.displacement);
    double opacity = (diff / widget.displacement).clamp(-1.0, 1.0);

    opacity = (opacity >= 0) ? opacity : opacity * -1;
    opacity = diff < 0 ? 1 - opacity : opacity;

    return opacity;
  }

  @override
  Widget build(BuildContext context) {
    // print(_canDrag);
    return GestureDetector(
      onVerticalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          _dragDelta += details.delta.dy;
          // print(_dragDelta);
          _addDeltaToCurrentPositions();
        });
        // print(_dragDelta);
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
        // print("Local position cancel");
        _resetPositions();
      },
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center, // fit: StackFit.expand,
          children: [
            ..._bottomCards.map(
              (e) => Transform(
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
            ..._topCards.map(
              (e) => Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, _currentPositions[e.index])
                  ..scale(_calculateScaleByCurrentPosition(e.index)),
                alignment: Alignment.center,
                child: e.child,
              ),
            ),
            Transform(
              transform: Matrix4.identity()
                ..translate(0.0, _currentPositions[_currentIndex])
                ..scale(_calculateScaleByCurrentPosition(_currentIndex)),
              alignment: Alignment.center,
              child: currentWidget.child,
            ),
          ],
        ),
      ),
    );
  }
}
