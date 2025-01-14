import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';

extension OffsetExt on Offset {
  Pair<Offset, Offset> increaseSize(Size size) {
    Offset start = Offset(dx - size.width, dy - size.height);
    Offset end = Offset(dx + size.width, dy + size.height);
    return Pair(left: start, right: end);
  }
}
