
extension StringExt on String {

  bool get isNumber {
    try {
      num.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

}