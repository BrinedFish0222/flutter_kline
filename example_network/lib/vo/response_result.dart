// To parse this JSON data, do
//
//     final responseResult = responseResultFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_kline/utils/kline_date_util.dart';
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
