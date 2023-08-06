import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/example/example_line_data.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/k_chart_renderer_vo.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';
import 'package:flutter_kline/widget/k_chart_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late KChartRendererVo kChartRendererVo;

  final StreamController<KChartRendererVo> _streamController =
      StreamController();

  late Timer _updateDataTimer;

  int dataIndex = 799;
  int showDataNum = 60;

  @override
  void initState() {
    var candlestickChartData =
        ExampleLineData.getCandlestickData().sublist(0, dataIndex);

    kChartRendererVo = KChartRendererVo(
        candlestickChartData: candlestickChartData,
        lineChartData: [
          LineChartVo(
              dataList: ExampleLineData.lineData1
                  .sublist(0, dataIndex)
                  .map((e) => LineChartData(value: e))
                  .toList(),
              color: Colors.red),
        ]);

    _updateDataTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) {
      var num1 = ExampleLineData.lineData1[dataIndex];
      kChartRendererVo.lineChartData![0]!.dataList!
          .add(LineChartData(value: num1));
      kChartRendererVo.candlestickChartData
          .add(ExampleLineData.getCandlestickData()[dataIndex]);
      _streamController.add(kChartRendererVo);
      dataIndex += 1;
      if (dataIndex == ExampleLineData.getCandlestickData().length) {
        _updateDataTimer.cancel();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    _updateDataTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _buildCustomPaint(),
      ),
    );
  }

  _buildCustomPaint() {
    var size = Size(MediaQuery.of(context).size.width - 20, 300);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: StreamBuilder(
          initialData: kChartRendererVo,
          stream: _streamController.stream,
          builder: (context, snapshot) {
            // 只展示5条数据。
            var lastN = KlineCollectionUtil.lastN(
                snapshot.data!.candlestickChartData, showDataNum);
            snapshot.data!.candlestickChartData.clear();
            snapshot.data!.candlestickChartData.addAll(lastN!);
            for (var element in snapshot.data!.lineChartData!) {
              element!.dataList =
                  KlineCollectionUtil.lastN(element.dataList, showDataNum);
            }

            return KChartWidget(
                size: size,
                lineChartData: snapshot.data?.lineChartData,
                candlestickChartData: snapshot.data!.candlestickChartData,
                onTapIndicator: (index) {
                  KlineUtil.showToast(context: context, text: '点击指标索引：$index');
                },
                margin: const EdgeInsets.all(5));
          }),
    );
  }
}
