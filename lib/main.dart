import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stack_animation/stack_card.dart';
import 'package:stack_animation/stacked_list_view.dart';
import 'package:stack_animation/swipe_stack.dart';

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
      body: SwipeStack(
        itemCount: 10,
        itemBuilder: (context, index) => StackCard(pageNo: index),
      ),
      // body: StackedListView(
      //   itemCount: 20,
      //   initialIndex: 10,
      //   itemBuilder: (_, index) => StackCard(pageNo: index),
      // ),
    );
  }
}
