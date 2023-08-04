import 'dart:convert';

/// 集合工具
class CollectionUtil {
  static List<T> copy<T>(List<T> dataList) {
    if (CollectionUtil.isEmpty(dataList)) {
      return [];
    }

    List<T> result = [];

    for (var element in dataList) {
      var copyData = jsonDecode(jsonEncode(element));
      result.add(copyData);
    }

    return result;
  }

  /// 是否为空
  static bool isEmpty(List? dataList) {
    return dataList == null || dataList.isEmpty;
  }

  /// 是否不为空
  static bool isNotEmpty(List? dataList) {
    return !isEmpty(dataList);
  }

  static bool contains<E>({List<E>? list, E? element}) {
    if (CollectionUtil.isEmpty(list) || element == null) {
      return false;
    }

    for (E e in list!) {
      if (e == element) return true;
    }

    return false;
  }

  static E? firstWhere<E>(List<E>? list, bool Function(E element) test,
      {E Function()? orElse}) {
    if (CollectionUtil.isEmpty(list)) {
      return null;
    }

    for (E element in list!) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();

    return null;
  }

  static E? last<E>(List<E>? list) {
    if (CollectionUtil.isEmpty(list)) {
      return null;
    }
    return list?.last;
  }

  static E? first<E>(List<E>? list) {
    if (CollectionUtil.isEmpty(list)) {
      return null;
    }
    return list?.first;
  }
}
