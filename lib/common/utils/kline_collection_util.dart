import 'dart:convert';

/// 集合工具
class KlineCollectionUtil {

  /// 根据条件替换
  static bool replaceWhere<E>(
      {required List<E?>? dataList, required bool Function(E?) test, required E element}) {
    dataList ??= [];
    if (isEmpty(dataList)) {
      return false;
    }

    var index = dataList.indexWhere(test);
    if (index == -1) {
      return false;
    }

    dataList[index] = element;
    return true;
  }

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
      {required List<E>? list, required int start, int? end}) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }
    end ??= list!.length - 1;
    start = start.clamp(0, list!.length);
    end = end.clamp(0, list.length);
    return list.sublist(start, end);
  }

  static E? first<E>(List<E>? list) {
    if (KlineCollectionUtil.isEmpty(list)) {
      return null;
    }
    return list?.first;
  }
}

extension ListExt on List {

  int get maxIndex {
    if (length == 0) {
      return 0;
    }

    return length - 1;
  }

  /// 是否包含索引
  bool hasIndex(int index) {
    if (index < 0) {
      return false;
    }

    if (length - 1 < index) {
      return false;
    }

    return true;
  }
}
