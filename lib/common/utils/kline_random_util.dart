import 'dart:math';

class KlineRandomUtil {
  static num generateRandomNumber(num min, num max) {
    Random random = Random();
    return min + random.nextDouble() * (max - min);
  }

  static double generateRandomDouble(num min, num max) {
    Random random = Random();
    return min + random.nextDouble() * (max - min);
  }

  static double generateDoubleInRange(
      {required double min,
      required double max,
      required double previousValue,
      required double floatRange}) {
    // 使用 Random 类生成随机数
    final random = Random();

    // 生成一个介于 -0.02 到 0.02 之间的随机浮点数
    final float = (random.nextDouble() - 0.5) * floatRange;

    // 根据上一次生成的值和浮动值计算新的值
    double newValue = previousValue + float;

    // 确保新值在指定范围内
    if (newValue < min) {
      newValue = min;
    } else if (newValue > max) {
      newValue = max;
    }

    return newValue;
  }
}
