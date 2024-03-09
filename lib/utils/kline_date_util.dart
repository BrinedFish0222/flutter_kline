/// 时间工具类
class KlineDateUtil {
  /// 格式化日期
  /// [date] 日期
  /// [spaceCharacter] 间隔符
  static String formatDate({
    required DateTime? date,
    String spaceCharacter = '/',
    String timeSpaceCharacter = ':',
    DateTimeFormatType formatType = DateTimeFormatType.dateTimeNoSecond,
  }) {
    if (date == null) {
      return '';
    }

    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');

    if (formatType == DateTimeFormatType.date) {
      return '${date.year}$spaceCharacter$month$spaceCharacter$day';
    }

    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');

    if (formatType == DateTimeFormatType.time) {
      return '$hour$timeSpaceCharacter$minute';
    }

    if (formatType == DateTimeFormatType.dateTimeNoSecond) {
      return '${date.year}$spaceCharacter$month$spaceCharacter$day $hour$timeSpaceCharacter$minute';
    }

    String second = date.second.toString().padLeft(2, '0');
    return '${date.year}$spaceCharacter$month$spaceCharacter$day $hour$timeSpaceCharacter$minute$timeSpaceCharacter$second';
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


enum DateTimeFormatType {
  dateTime,
  time,
  date,
  dateTimeNoSecond,
}
