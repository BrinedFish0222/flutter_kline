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
    return '${date.year}$spaceCharacter${date.month}$spaceCharacter${date.day} ${date.hour}:${date.minute}';
  }

  /// 格式化时间
  static String formatTime(
      {required DateTime? dateTime, String spaceCharacter = ':'}) {
    if (dateTime == null) {
      return '';
    }

    String minuteStr = dateTime.minute < 10
        ? '0${dateTime.minute}'
        : dateTime.minute.toString();
    return '${dateTime.hour}$spaceCharacter$minuteStr';
  }

  static DateTime parseIntDateToDateTime(int intDate) {
    var dateStr = intDate.toString();
    int year = int.parse(dateStr.substring(0, 4));
    int month = int.parse(dateStr.substring(4, 6));
    int day = int.parse(dateStr.substring(6, 8));
    return DateTime(year, month, day);
  }

  static DateTime? parseIntTime(int time) {
    if (time < 0 || time > 2359) {
      return null;
    }

    // 提取小时和分钟部分
    int hour = time ~/ 100; // 整除得到小时
    int minute = time % 100; // 取余得到分钟

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    // 构建时间字符串
    String hourStr = hour.toString().padLeft(2, '0'); // 补0，确保两位数字
    String minuteStr = minute.toString().padLeft(2, '0'); // 补0，确保两位数字

    DateTime now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(hourStr),
      int.parse(minuteStr),
    );
  }
}
