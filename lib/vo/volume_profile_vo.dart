import 'package:flutter/material.dart';

/// 筹码峰
class VolumeProfileVo {
  /// 价格
  double price;

  /// 占比。范围：0~1
  double percent;

  /// 颜色
  Color color;

  VolumeProfileVo({
    this.price = 0,
    this.percent = 0,
    this.color = Colors.red,
  });

  VolumeProfileVo copyWith({
    double? price,
    double? percent,
    Color? color,
  }) =>
      VolumeProfileVo(
        price: price ?? this.price,
        percent: percent ?? this.percent,
        color: color ?? this.color,
      );

  static List<VolumeProfileVo> copyWithList(List<VolumeProfileVo> dataList) {
    if (dataList.isEmpty) {
      return [];
    }

    return dataList.map((e) => e.copyWith()).toList();
  }

  /// 根据价格排序
  static void sortByPrice({required List<VolumeProfileVo> dataList}) {
    dataList.sort((a, b) => b.price.compareTo(a.price));
  }

}
