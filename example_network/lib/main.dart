import 'package:example_network/example_network/example_minute_network_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kline/common/widget/double_back_exit_app_widget.dart';
import 'package:flutter_kline/example/example_candlestick_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

late WebSocketChannel webSocketChannel;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ExampleCandlestickData.getCandlestickData();

  webSocketChannel = WebSocketChannel.connect(
    Uri.parse("ws://192.168.101.14:8080/websocket/123"),
  );

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
  final GlobalKey _globalKey = GlobalKey();

  @override
  void dispose() {
    webSocketChannel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: _globalKey,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: ListView(
                  children: [
                    ExampleMinuteNetworkWidget(
                      candlestickOverlayEntryLocationKey: _globalKey,
                    ),
                    ...List.generate(
                        5,
                        (index) => Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Container(
                                color:
                                    index % 2 == 0 ? Colors.red : Colors.green,
                                height: 100,
                              ),
                            )).toList(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
