import 'dart:math';

import 'package:flutter/material.dart';

class StackCard extends StatelessWidget implements PreferredSizeWidget {
  const StackCard({super.key, required this.pageNo});

  final int pageNo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      child: Card(
        color: Colors.primaries[pageNo % Colors.primaries.length],
        margin: const EdgeInsets.all(0),
        child: InkWell(
          onTap: () {
            print("Tapped on $pageNo");
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(pageNo.toString(), style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 16),
                const Text(
                  'Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(155);
}
