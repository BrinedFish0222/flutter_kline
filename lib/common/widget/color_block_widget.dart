import 'package:flutter/material.dart';

/// 创建 [size] 个颜色块
class ColorBlockWidget extends StatelessWidget {
  const ColorBlockWidget({super.key, this.size = 5});

  final int size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(
            size,
            (index) => Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    color: index % 2 == 0 ? Colors.red : Colors.green,
                    height: 100,
                  ),
                )).toList(),
      ],
    );
  }
}
