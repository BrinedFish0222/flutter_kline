import 'dart:convert';

/// 集合工具
class KlineCollectionUtil {
  static List<T> copy<T>(List<T> dataList) {
    if (KlineCollectionUtil.isEmpty(dataList)) {
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
    if (KlineCollectionUtil.isEmpty(list) || element == null) {
      return false;
    }

    for (E e in list!) {
      if (e == element) return true;
    }

    return false;
  }

  static E? getByIndex<E>(List<E?>? list, int index, {E? indexMinZeroValue}) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }

    if (index >= list!.length) {
      return null;
    }

    if (index < 0) {
      return indexMinZeroValue;
    }

    return list[index];
  }

  static E? firstWhere<E>(List<E>? list, bool Function(E element) test,
      {E Function()? orElse}) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }

    for (E element in list!) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();

    return null;
  }

  static E? last<E>(List<E>? list) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }
    return list?.last;
  }

  static List<E>? lastN<E>(List<E>? list, int n) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }

    if (list!.length < n) {
      return list;
    }
    return list.sublist(list.length - n);
  }

  static List<E>? sublist<E>(
      {required List<E>? list, required int startIndex, int? endIndex}) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }
    endIndex ??= list!.length - 1;
    startIndex = startIndex.clamp(0, list!.length);
    endIndex = endIndex.clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }

  static E? first<E>(List<E>? list) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }
    return list?.first;
  }
}
