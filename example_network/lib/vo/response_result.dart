// To parse this JSON data, do
//
//     final responseResult = responseResultFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_date_util.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';
import 'package:flutter_kline/vo/candlestick_chart_vo.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';

ResponseResult responseResultFromJson(String str) =>
    ResponseResult.fromJson(json.decode(str));

String responseResultToJson(ResponseResult data) => json.encode(data.toJson());

class ResponseResult {
  int? code;
  dynamic data;
  String? msg;
  String? type;

  ResponseResult({
    this.code,
    this.data,
    this.msg,
    this.type,
  });

  LineChartData? parseMinuteData() {
    if (type != 'minute') {
      return null;
    }

    return LineChartData(
        dateTime: KlineDateUtil.parseIntTime((data[0] as double).toInt()),
        value: data[1]);
  }

  List<LineChartData>? parseMinuteAllData() {
    if (type != 'minuteAll') {
      return null;
    }

    List<LineChartData> result = [];
    var dataList = data as List;
    for (var data in dataList) {
      result.add(LineChartData(
          id: KlineDateUtil.parseIntTime((data[0] as double).toInt())
              .toString(),
          dateTime: KlineDateUtil.parseIntTime((data[0] as double).toInt()),
          value: data[1]));
    }

    return result;
  }

  /// 解析日K数据
  /// type daySingle dayAll daySingleAll
  List<BaseChartVo> parseDayData({String type = 'dayAll'}) {
    if (this.type != type) {
      return [];
    }

    List<BaseChartVo> result = [];
    var dataList = jsonDecode(jsonEncode(data));

    var candlestickList = KlineCollectionUtil.first(dataList as List<dynamic>);
    if (candlestickList != null) {
      List<CandlestickChartData?> dataList = [];
      for (var data in candlestickList) {
        if (data is List? && (data?.isEmpty ?? true)) {
          dataList.add(null);
          continue;
        }

        DateTime dateTime = KlineDateUtil.parseIntDateToDateTime(int.parse(data[0]));
        dataList.add(CandlestickChartData(
          id: data[0],
          dateTime: dateTime,
          // open: data[2],
          // close: data[5],
          // high: data[3],
          // low: data[4],
          open: double.parse(data[2]),
          close: double.parse(data[5]),
          high: double.parse(data[3]),
          low: double.parse(data[4]),
        ));

      }

      result.add(CandlestickChartVo(data: dataList));
    }


    return result;
  }

  ResponseResult copyWith({
    int? code,
    double? data,
    String? msg,
    String? type,
  }) =>
      ResponseResult(
        code: code ?? this.code,
        data: data ?? this.data,
        msg: msg ?? this.msg,
        type: type ?? this.type,
      );

  factory ResponseResult.fromJson(Map<String, dynamic> json) => ResponseResult(
        code: json["code"],
        data: json["data"],
        msg: json["msg"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data,
        "msg": msg,
        "type": type,
      };


}
