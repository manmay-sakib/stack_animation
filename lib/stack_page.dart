import 'package:flutter/material.dart';
import 'package:stack_animation/stack_card.dart';

class StackPage extends StatefulWidget {
  const StackPage({super.key});

  @override
  State<StackPage> createState() => _StackPageState();
}

class _StackPageState extends State<StackPage> {
  double page = 0;

  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        page = pageController.page!;
      });
    });
  }

  double getTranslation(int index) {
    print(page);
    if (page.toInt() == index) return 0;
    return 0 + ((index - page) * 16);
  }

  double getOffsetByIndex(int index) {
    double center = 0;
    double pos = 0;
    double diff = page - index;
    pos = center + (16 * diff);

    // if

    print("index: $index :: pos $pos page :: $page");
    return pos;
  }

  double getMarginByIndex(int index) {
    if (page.toInt() == index) return 0;
    return (index - page).abs() * 6;
  }

  @override
  Widget build(BuildContext context) {
    print(page);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Stack Animation'),
      ),
      body: Stack(
        alignment: Alignment.center,
        // fit: ,
        children: <Widget>[
          for (int i = 0; i <= page.toInt(); i++)
            Transform.translate(
              offset: Offset(0, getOffsetByIndex(i)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: getMarginByIndex(i)),
                child: StackCard(pageNo: i),
              ),
            ),

          // Positioned(
          //   left: (10 - i) * 8,
          //   right: (10 - i) * 8,
          //   top: i * 16,
          //   child: StackCard(pageNo: i),
          // ),

          for (int i = 19; i > page.toInt(); i--)
            Transform.translate(
              offset: Offset(0, getOffsetByIndex(i)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: getMarginByIndex(i)),
                child: StackCard(pageNo: i),
              ),
            ),
          // Positioned(
          //   left: (10 - i) * -8,
          //   right: (10 - i) * -8,
          //   top: i * 16,
          //   child: StackCard(pageNo: i),
          // ),

          PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: 20,
            reverse: true,
            itemBuilder: (_, __) => Container(
              // color: Colors.red.withOpacity(0.2),
              margin: const EdgeInsets.all(16),
            ),
          ),
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   child: Transform(
          //     transform: Matrix4.identity()
          //       ..scale(0.0, 1 - ((10 - i) * 0.05))
          //       ..translate((10 - i) * 16.0, (10 - i) * 50.0),
          //     child: StackCard(pageNo: i),
          //   ),
          // ),
        ],
      ),
    );
  }
}
