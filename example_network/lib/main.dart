import 'package:example_network/example_network/example_day_network_widget.dart';
import 'package:example_network/example_network/example_minute_network_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kline/common/widget/color_block_widget.dart';
import 'package:flutter_kline/common/widget/double_back_exit_app_widget.dart';
import 'package:flutter_kline/example/example_candlestick_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String ip = '192.168.31.205:8080';

late WebSocketChannel webSocketChannel;
late Stream webSocketChannelStream;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ExampleCandlestickData.getCandlestickData();

  webSocketChannel = WebSocketChannel.connect(
    Uri.parse("ws://$ip/websocket/123"),
  );

  webSocketChannelStream = webSocketChannel.stream.asBroadcastStream();

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
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.black
        )
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
  final GlobalKey _globalKey = GlobalKey();

  @override
  void dispose() {
    webSocketChannel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            TabBar(key: _globalKey, tabs: const [
              Tab(
                text: '分时',
              ),
              Tab(
                text: '日K',
              ),
            ]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: TabBarView(children: [
                    _buildMinute(),
                    _buildDay()
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildMinute() {
    return ListView(
      children: [
        ExampleMinuteNetworkWidget(
          overlayEntryLocationKey: _globalKey,
        ),
        const ColorBlockWidget(),
      ],
    );
  }

  _buildDay() {
    return ListView(
      children: [
        ExampleDayNetworkWidget(
          overlayEntryLocationKey: _globalKey,
        ),
        const ColorBlockWidget(),
      ],
    );
  }
}
