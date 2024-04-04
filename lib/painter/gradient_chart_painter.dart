import 'package:flutter/material.dart';

import '../common/utils/kline_util.dart';


/// 渐变色图
class GradientChartPainter extends CustomPainter {
  const GradientChartPainter({
    required this.gradient,
    required this.heightList,
    required this.pointWidth,
    this.pointGap = 0,
  });

  /// 高度列表 / Y轴值
  final List<double?> heightList;
  final double pointWidth;
  final double pointGap;

  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    if (heightList.isEmpty) {
      return;
    }

    final Paint paint = Paint()..strokeWidth = 1.0;

    // 创建一个矩形
    final Rect gradientRect =
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));

    // 创建渐变的 Shader
    final Shader shader = gradient.createShader(gradientRect);

    // 将渐变的 Shader 应用到矩形上
    paint.shader = shader;

    // 定义路径
    var startX = KlineUtil.computeXAxis(
      index: 0,
      pointWidth: pointWidth,
      pointGap: pointGap,
    );
    var endX = KlineUtil.computeXAxis(
      index: heightList.length - 1,
      pointWidth: pointWidth,
      pointGap: pointGap,
    );
    final Path path = Path()
      ..moveTo(
        startX,
        heightList.first ?? size.height,
      );
    for (int i = 1; i < heightList.length; i++) {
      double x = KlineUtil.computeXAxis(
          index: i, pointWidth: pointWidth, pointGap: pointGap);
      path.lineTo(x, heightList[i] ?? size.height);
    }
    path
      ..lineTo(endX, size.height)
      ..lineTo(startX, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class GradientChartConstants {
  static LinearGradient formGradient({required Color color}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.1), Colors.white],
      stops: const [0.05, 1],
    );
  }

  /// 默认红渐变
  static final defaultRedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.red.withOpacity(0.1), Colors.white],
    stops: const [0.05, 1],
  );

  /// 默认绿渐变
  static const defaultGreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromARGB(255, 156, 247, 159), Colors.white],
    stops: [0.05, 1],
  );

  /// 默认灰渐变
  static const defaultGreyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromARGB(255, 204, 203, 203), Colors.white],
    stops: [0.05, 1],
  );
}
