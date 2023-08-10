import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kline/utils/kline_collection_util.dart';
import 'package:flutter_kline/utils/kline_util.dart';
import 'package:flutter_kline/vo/selected_chart_data_stream_vo.dart';
import 'package:flutter_kline/widget/gesture/k_chart_gesture_widget.dart';

import '../common/pair.dart';
import '../vo/candlestick_chart_vo.dart';
import '../vo/line_chart_vo.dart';

/// k线组件
/// -
class KChartWidget extends StatefulWidget {
  const KChartWidget({
    super.key,
    required this.size,
    required this.candlestickChartData,
    this.lineChartData,
    this.margin,
    this.onTapIndicator,
  });

  final Size size;
  final List<CandlestickChartVo?> candlestickChartData;
  final List<LineChartVo?>? lineChartData;
  final EdgeInsets? margin;

  /// 点击股票指标事件
  final void Function(int index)? onTapIndicator;

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> {
  final GlobalKey _masterKey = GlobalKey();

  /// 蜡烛数据流
  final StreamController<CandlestickChartVo?> _candlestickChartVoStream =
      StreamController();

  // 选中的折线数据
  final StreamController<SelectedChartDataStreamVo>
      _selectedLineChartDataStream = StreamController();

  /// 最后一根选中的折线数据
  List<SelectedLineChartDataStreamVo>? _lastSelectedLineChartData;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _initLastSelectedLineChartData();
    _candlestickChartVoStream.stream.listen((event) {
      debugPrint("_candlestickChartVoStream listen run ....");
      if (event == null) {
        debugPrint("_candlestickChartVoStream listen run, even is null ....");
        _hideOverlay();
        return;
      }

      debugPrint("_candlestickChartVoStream listen run, even is not null ....");
      var overlayLocation = _getCandlestickOverlayLocation();
      _showOverlay(
          context: context,
          left: 0,
          top: overlayLocation!.right - 50,
          vo: event);
    });
    super.initState();
  }

  @override
  void dispose() {
    _candlestickChartVoStream.close();
    _selectedLineChartDataStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: _masterKey,
      children: [
        /// 信息栏
        InkWell(
          onTap: () => _onTapIndicator(0),
          child: Row(children: [
            const Text('MA'),
            const Icon(Icons.arrow_drop_down),
            StreamBuilder<SelectedChartDataStreamVo>(
                initialData: SelectedChartDataStreamVo(
                    lineChartList: _lastSelectedLineChartData),
                stream: _selectedLineChartDataStream.stream,
                builder: (context, snapshot) {
                  var data = snapshot.data;
                  if (KlineCollectionUtil.isEmpty(widget.lineChartData)) {
                    return KlineUtil.noWidget();
                  }

                  _candlestickChartVoStream.add(data?.candlestickChartVo);

                  return Wrap(
                    children: data?.lineChartList
                            ?.map((e) => Text(
                                '${e.name} ${e.value?.toStringAsFixed(2)}   '))
                            .toList() ??
                        [],
                  );
                })
          ]),
        ),
        /// K线图
        KChartGestureWidget(
          size: widget.size,
          candlestickChartData: widget.candlestickChartData,
          lineChartData: widget.lineChartData,
          margin: widget.margin,
          selectedLineChartDataStream: _selectedLineChartDataStream,
        )
      ],
    );
  }

  _initLastSelectedLineChartData() {
    if (KlineCollectionUtil.isEmpty(widget.lineChartData)) {
      return;
    }

    _lastSelectedLineChartData ??= [];
    for (var element in widget.lineChartData!) {
      var lastData = element?.dataList?.last;
      _lastSelectedLineChartData!.add(SelectedLineChartDataStreamVo(
          color: element?.color ?? Colors.black,
          name: element?.name,
          value: lastData?.value));
    }
  }

  /// 获取蜡烛浮层地址
  Pair<double, double>? _getCandlestickOverlayLocation() {
    RenderBox? renderBox =
        _masterKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // 获取组件在页面中的位置信息
      Offset offset = renderBox.localToGlobal(Offset.zero);
      double x = offset.dx; // X坐标
      double y = offset.dy; // Y坐标
      return Pair(left: x, right: y);
    }
    return null;
  }

  void _showOverlay(
      {required BuildContext context,
      required double left,
      required double top,
      required CandlestickChartVo vo}) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }

    // 创建OverlayEntry并将其添加到Overlay中
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: top,
        left: left,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: Colors.grey,
            child: Center(
              child: Text(
                'open ${vo.open}, close ${vo.close}, high ${vo.high}, low ${vo.low}',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    debugPrint("hide overlay execute ... ");
  }

  /// 点击指标事件
  void _onTapIndicator(int index) {
    if (widget.onTapIndicator == null) {
      return;
    }

    widget.onTapIndicator!(index);
  }
}
