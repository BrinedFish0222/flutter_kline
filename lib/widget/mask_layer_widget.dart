import 'package:flutter/material.dart';

import '../common/mask_layer.dart';

/// 遮罩层
class MaskLayerWidget extends StatelessWidget {
  const MaskLayerWidget({
    super.key,
    required this.maskLayer,
  });

  final MaskLayer maskLayer;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: maskLayer.onTap,
      child: LayoutBuilder(builder: _builderWidget),
    );
  }

  Widget _builderWidget(BuildContext context, BoxConstraints constraints) {
    double width = constraints.maxWidth * maskLayer.percent;
    double height = constraints.maxHeight;

    return SizedBox(
      width: width,
      height: height,
      child: maskLayer.widget ??  Container(
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
