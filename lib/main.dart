import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/common/pair.dart';
import 'package:flutter_kline/example/example_line_data.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/candlestick_chart_vo.dart';
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

  final GlobalKey _tabKey = GlobalKey();

  int dataIndex = 799;
  int showDataNum = 60;

  @override
  void initState() {
    var candlestickChartData =
        ExampleLineData.getCandlestickData().sublist(0, dataIndex);

    kChartRendererVo = KChartRendererVo(
        candlestickChartData: candlestickChartData,
        lineChartData: ExampleLineData.getLineChartMA13(dataIndex: dataIndex));

    _updateDataTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) {
      var num1 = ExampleLineData.ma13[dataIndex];
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            TabBar(key: _tabKey, tabs: const [
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
              Tab(
                child: Text(
                  '周K',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ]),
            Center(
              child: _buildCustomPaint(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            RenderBox? renderBox =
                _tabKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              // 获取组件在页面中的位置信息
              Offset offset = renderBox.localToGlobal(Offset.zero);
              double x = offset.dx; // X坐标
              double y = offset.dy; // Y坐标
              KlineUtil.showToast(
                  context: context, text: 'tab widget location $x $y');
            }
          },
          child: const Icon(Icons.add),
        ),
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
