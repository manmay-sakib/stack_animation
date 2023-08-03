import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class StackedListView extends StatefulWidget {
  const StackedListView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.initialIndex = 0,
    this.collapsedHeight = 20,
    this.maxVisibleItems = 6,
  });

  final int itemCount;
  final PreferredSizeWidget Function(BuildContext context, int index)
      itemBuilder;
  final int initialIndex;
  final double collapsedHeight;
  final int maxVisibleItems;

  @override
  State<StackedListView> createState() => _StackedListViewState();
}

class _StackedListViewState extends State<StackedListView> {
  late final PageController _pageController;
  double _page = 0;
  late double _childSize;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _page = widget.initialIndex.toDouble();
    _pageController.addListener(() {
      _page = _pageController.page!;
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant StackedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _pageController.animateToPage(
        widget.initialIndex,
        duration: kThemeAnimationDuration * 2,
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
  }

  // @override
  // void didUpdateWidget(covariant StackedListView oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   print("Called didUpdateWidget");
  //   _calculateChildHeight();
  // }
  //
  // void _calculateChildHeight() {
  //   double height = double.minPositive;
  //   for (int i=0; i<widget.itemCount; i++) {
  //     height = max(widget.itemBuilder(context, i).preferredSize.height, height);
  //   }
  //
  //   setState(() {
  //     _childSize = height;
  //   });
  // }

  double getHeightFactor(int index) {
    double heightFactor = (1 - (index - _page).abs()).clamp(0.2, 1);
    // print("Index: $index, page: $_page, heightFactor: $heightFactor");
    return heightFactor;
  }

  double _calculateHeightAtIndex(int index, double height) {
    double threshold = (1 - (index - _page).abs().clamp(0, 1).toDouble());
    // if (index == 0) print("T: $threshold");
    double newHeight = lerpDouble(widget.collapsedHeight, height, threshold)!;
    // print("New height: $newHeight");
    return newHeight;
  }

  double _calculateHeightFactorAtIndex(int index, double height) {
    double hf = _calculateHeightAtIndex(index, height) / height;
    // print("Index: $index, height: $height, hf: $hf");
    return hf;
  }

  double _calculatePosition() {
    List<double> heights = List.generate(
        widget.itemCount,
        (index) => _calculateHeightAtIndex(
            index, widget.itemBuilder(context, index).preferredSize.height));

    double total = heights.reduce((value, element) => value + element) -
        heights.fold(double.minPositive,
            (previousValue, element) => max(previousValue, element));
    double segment = (total) / (widget.itemCount - 1);
    double position = (total / 2) - (segment * _page);
    print("Position: $position (total: $total, segment: $segment)");
    return position;
  }

  double getScale(int index) {
    return 1 - (index - _page).abs() * 0.05;
  }

  List<Widget> _buildItems(BuildContext context) {
    List<Widget> items = [];

    int minIndex = max(0, _page.floor() - 3);
    int maxIndex = min(widget.itemCount - 1, _page.ceil() + 3);

    for (int i = 0; i < widget.itemCount; i++) {
      final Widget root = Builder(
        builder: (BuildContext context) {
          final PreferredSizeWidget item = widget.itemBuilder(context, i);
          final itemHeight = item.preferredSize.height;
          return AnimatedOpacity(
            duration: kThemeAnimationDuration,
            opacity: (i >= minIndex && i <= maxIndex) ? 1 : 0,
            child: Transform.scale(
              scaleX: getScale(i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Align(
                  alignment: Alignment.center,
                  heightFactor: _calculateHeightFactorAtIndex(i, itemHeight),
                  child: item,
                ),
              ),
            ),
          );
        },
      );
      items.add(root);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, _calculatePosition()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildItems(context),
          ),
        ),
        // Transform.translate(
        //   offset: Offset.fromDirection(-pi / 2, -100),
        //   child: Container(
        //     height: 60,
        //     width: 100,
        //     color: Colors.red,
        //   ),
        // ),
        Transform.translate(
          offset: Offset.zero,
          child: Container(
            height: 10,
            width: 10,
            color: Colors.black,
          ),
        ),
        PageView.builder(
          itemCount: widget.itemCount,
          scrollDirection: Axis.vertical,
          controller: _pageController,
          reverse: true,
          itemBuilder: (_, __) => Container(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
