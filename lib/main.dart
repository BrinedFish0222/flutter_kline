import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kline/common/widget/double_back_exit_app_widget.dart';
import 'package:flutter_kline/example/example_candlestick_data.dart';
import 'package:flutter_kline/example/example_day_widget.dart';
import 'package:flutter_kline/example/example_minute_widget.dart';
import 'package:flutter_kline/example/example_volume_profile_widget.dart';

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
          child: MyHomePage(title: 'Flutter Kline')),
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
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            TabBar(key: _globalKey, tabs: const [
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
                  '筹码峰',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ]),
            Expanded(
              child: TabBarView(children: [
                ExampleMinuteWidget(
                  overlayEntryLocationKey: _globalKey,
                ),
                ExampleDayWidget(
                  overlayEntryLocationKey: _globalKey,
                ),
                const ExampleVolumeProfileWidget(),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
