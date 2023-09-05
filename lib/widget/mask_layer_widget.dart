import 'package:flutter/material.dart';

/// 遮罩层
class MaskLayerWidget extends StatelessWidget {
  const MaskLayerWidget({super.key, this.width, this.height, this.onTap});

  final double? width;
  final double? height;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf7f373), Color(0xFFc5b9ab)],
          ),
        ),
      ),
    );
  }
}
