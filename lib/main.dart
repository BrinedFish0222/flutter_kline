import 'package:flutter/material.dart';
import 'package:flutter_kline/common/widget/double_back_exit_app_widget.dart';
import 'package:flutter_kline/example/example_candlestick_data.dart';
import 'package:flutter_kline/example/example_line_data.dart';
import 'package:flutter_kline/example/example_rmo_data.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/bar_chart_vo.dart';
import 'package:flutter_kline/widget/k_chart_widget.dart';

import 'example/example_ess_data.dart';
import 'example/example_vol_data.dart';

void main() {
  ExampleCandlestickData.getCandlestickData();
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
      home: const DoubleBackExitAppWidget(
          child: MyHomePage(title: 'Flutter Demo Home Page')),
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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            const TabBar(tabs: [
              Tab(
                child: Text(
                  '分时',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  '日K',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ]),
            Center(
              child: _buildCustomPaint(),
            ),
          ],
        ),
      ),
    );
  }

  _buildCustomPaint() {
    var size = Size(MediaQuery.of(context).size.width - 20,
        MediaQuery.of(context).size.height * 0.6);
    BarChartVo barChartVo = ExampleVolData.barChartData..barWidth = 2;
    for (var element in barChartVo.data) {
      element.isFill = true;
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: KChartWidget(
        showDataNum: 30,
        size: size,
        lineChartData: ExampleLineData.getLineChartMA13(),
        candlestickChartData: ExampleCandlestickData.getCandlestickData(),
        onTapIndicator: (index) {
          KlineUtil.showToast(context: context, text: '点击指标索引：$index');
        },
        margin: const EdgeInsets.all(5),
        subChartData: [
          [ExampleVolData.barChartData..minValue = 0, ...ExampleVolData.lineChartData],
          [ExampleRmoData.barChartData..barWidth = 4],
          [
            ExampleEssData.barChartData..barWidth = 2,
            ExampleEssData.lineChartA,
            ExampleEssData.lineChartB
          ],
        ],
      ),
    );
  }
}
