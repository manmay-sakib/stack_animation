import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stack_animation/stack_card.dart';
import 'package:stack_animation/stacked_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stack Animation'),
      ),
      body: StackedListView(
        itemCount: 20,
        initialIndex: 0,
        itemBuilder: (_, index) => StackCard(pageNo: index),
      ),
    );
  }
}

// class StackPage extends StatefulWidget {
//   const StackPage({Key? key}) : super(key: key);
//
//   @override
//   State<StackPage> createState() => _StackPageState();
// }
//
// class _StackPageState extends State<StackPage> {
//   final PageController _pageController = PageController();
//   double page = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController.addListener(() {
//       print(page);
//       page = _pageController.page ?? 0;
//       setState(() {});
//     });
//   }
//
//   double getOffsetByIndex(int index) {
//     double center = 0;
//     double pos = 0;
//     if (page.toInt() == index) {
//       pos = center;
//     } else {
//       double diff = index - page;
//       pos = center + (16 * diff);
//     }
//     // if (index < page) {
//     //   double diff = page - index;
//     //   pos = center + (16 * diff);
//     // } else {
//     //   double diff = index - page;
//     //   pos = center + (16 * diff);
//     // }
//
//     print("index: $index :: pos $pos page :: $page");
//     return pos;
//   }
//
//   double getOffsetForCurrentItem() {}
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Stack(
//           children: [
//             for (int i = 1; i < page.toInt(); i++)
//               Transform.translate(
//                 offset: Offset(0, getOffsetByIndex(i)),
//                 child: CouponCard(),
//               ),
//             for (int i = 20; i > page.toInt(); i--)
//               Transform.translate(
//                 offset: Offset(0, getOffsetByIndex(i)),
//                 child: CouponCard(),
//               ),
//             Transform.translate(
//               offset: Offset(0, getOffsetByIndex(page.toInt())),
//               child: CouponCard(),
//             ),
//             PageView.builder(
//               scrollDirection: Axis.vertical,
//               controller: _pageController,
//               itemCount: 20,
//               itemBuilder: (context, index) => Container(
//                   // margin: const EdgeInsets.all(24),
//                   // color: Colors.red,
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CouponCard extends StatelessWidget {
//   const CouponCard({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: SizedBox(
//         width: double.maxFinite,
//         height: 240,
//         child: Card(
//           elevation: 4,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 FlutterLogo(
//                   size: 60,
//                 ),
//                 Text("Starbucks"),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
