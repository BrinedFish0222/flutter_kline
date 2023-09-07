import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kline/common/widget/double_back_exit_app_widget.dart';
import 'package:flutter_kline/example/example_candlestick_data.dart';
import 'package:flutter_kline/example/example_ess_data.dart';
import 'package:flutter_kline/example/example_line_data.dart';
import 'package:flutter_kline/example/example_macd_data.dart';
import 'package:flutter_kline/example/example_minute_data.dart';
import 'package:flutter_kline/example/example_rmo_data.dart';
import 'package:flutter_kline/example/example_vol_data.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/bar_chart_vo.dart';
import 'package:flutter_kline/vo/line_chart_vo.dart';
import 'package:flutter_kline/vo/mask_layer.dart';
import 'package:flutter_kline/widget/k_chart_widget.dart';
import 'package:flutter_kline/widget/k_minute_chart_widget.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ExampleCandlestickData.getCandlestickData();
  // 设置应用程序的方向为竖屏（只允许竖屏显示）
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
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
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
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
            Expanded(
              child: TabBarView(children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: ListView(
                      children: [
                        KMinuteChartWidget(
                          size: Size(MediaQuery.of(context).size.width - 20,
                              MediaQuery.of(context).size.height * 0.6),
                          minuteChartData: ExampleMinuteData.lineData2,
                          minuteChartSubjoinData:
                              ExampleMinuteData.generateLineData(),
                          middleNum: 11.39,
                          differenceNumbers: const [11.48, 11.30],
                          subChartData: [
                            [ExampleRmoData.barChartData..barWidth = 4],
                            ExampleMacdData.macd,
                          ],
                        ),
                        ...List.generate(
                            5,
                            (index) => Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Container(
                                    color: index % 2 == 0
                                        ? Colors.red
                                        : Colors.green,
                                    height: 100,
                                  ),
                                )).toList(),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: _buildCustomPaint(),
                ),
              ]),
            )
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
      child: ListView(
        children: [
          KChartWidget(
            showDataNum: 30,
            size: size,
            lineChartData:
                ExampleLineData.getLineChartMA13().cast<LineChartVo>(),
            candlestickChartData: ExampleCandlestickData.getCandlestickData(),
            onTapIndicator: (index) {
              KlineUtil.showToast(context: context, text: '点击指标索引：$index');
            },
            margin: const EdgeInsets.all(5),
            subChartData: [
              [
                ExampleVolData.barChartData..minValue = 0,
                ...ExampleVolData.lineChartData
              ],
              [ExampleRmoData.barChartData..barWidth = 4],
              ExampleMacdData.macd,
              [
                ExampleEssData.barChartData
                  ..barWidth = 2
                  ..minValue = 0,
                // ExampleEssData.lineChartA.subData(start: 0, end: 600),
                ExampleEssData.lineChartB
              ],
            ],
            subChartMaskList: [
              null,
              MaskLayer(percent: 0.3),
              // MaskLayer(percent: 0.4)
            ],
          ),
          ...List.generate(
              5,
              (index) => Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      color: index % 2 == 0 ? Colors.red : Colors.green,
                      height: 100,
                    ),
                  )).toList(),
        ],
      ),
    );
  }
}
