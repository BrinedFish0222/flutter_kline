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
}
