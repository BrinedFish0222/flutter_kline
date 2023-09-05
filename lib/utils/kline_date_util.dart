
/// 时间工具类
class KlineDateUtil {

  /// 格式化日期
  /// [date] 日期
  /// [spaceCharacter] 间隔符
  static String formatDate(
      {required DateTime? date, String spaceCharacter = '/'}) {
    if (date == null) {
      return '';
    }
    return '${date.year}$spaceCharacter${date.month}$spaceCharacter${date.day}';
  }
}
