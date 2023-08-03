import 'package:flutter/material.dart';
import 'package:stack_animation/stack_card.dart';
import 'package:stack_animation/stack_page.dart';

class LinearPage extends StatefulWidget {
  const LinearPage({super.key});

  @override
  State<LinearPage> createState() => _LinearPageState();
}

class _LinearPageState extends State<LinearPage> {
  final PageController pageController = PageController();
  double page = 0;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      page = pageController.page!;
      // print(page);
      setState(() {});
    });
  }

  double getHeightFactor(int index) {
    double heightFactor = (1 - (index - page).abs()).clamp(0.2, 1);
    print("Index: $index, page: $page, heightFactor: $heightFactor");
    return heightFactor;
  }

  double getScale(int index) {
    return 1 - (index - page).abs() * 0.05;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Linear Animation'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              for (int i = 0; i < 20; i++)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Align(
                    alignment: Alignment.center,
                    child: Transform.scale(
                      scale: getScale(i),
                      child: StackCard(pageNo: i),
                    ),
                    heightFactor: getHeightFactor(i),
                  ),
                ),
            ],
          ),
          PageView.builder(
            itemCount: 20,
            scrollDirection: Axis.vertical,
            controller: pageController,
            reverse: true,
            itemBuilder: (_, __) => Container(),
          ),
        ],
      ),
    );
  }
}
