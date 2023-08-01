import 'package:flutter/material.dart';
import 'package:flutter_kline/painter/rect_painter.dart';

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
    var size = const Size(200, 200);
    return RepaintBoundary(
      child: CustomPaint(
        size: size,
        painter: RectPainter(
            size: size,
            transverseLineNum: 4,
            maxValue: 100,
            minValue: 50,
            isDrawVerticalLine: true,
            textStyle: const TextStyle(color: Colors.grey, fontSize: 8)),
      ),
    );
  }
}
