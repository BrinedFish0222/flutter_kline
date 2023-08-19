import 'package:flutter/material.dart';
import 'package:flutter_kline/renderer/sub_chart_renderer.dart';
import 'package:flutter_kline/vo/base_chart_vo.dart';

/// 副图组件
class SubChartWidget extends StatefulWidget {
  const SubChartWidget({
    super.key,
    required this.size,
    required this.name,
    required this.chartData,
  });

  final Size size;
  final String name;
  final List<BaseChartVo> chartData;

  @override
  State<SubChartWidget> createState() => _SubChartWidgetState();
}

class _SubChartWidgetState extends State<SubChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
           InkWell(
            onTap: () => debugPrint("${widget.name} onTap"),
            child: Row(children: [
               Text(widget.name),
              const Icon(Icons.arrow_drop_down),
              /* StreamBuilder<SelectedChartDataStreamVo>(
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
                              ?.where((element) => element.value != null)
                              .map((e) => Text(
                                    '${e.name} ${e.value?.toStringAsFixed(2)}   ',
                                    style: TextStyle(color: e.color),
                                  ))
                              .toList() ??
                          [],
                    );
                  }) */
            ]),
          ),
        CustomPaint(
          size: widget.size,
          painter: SubChartRenderer(chartData: widget.chartData),
        ),
      ],
    );
  }
}
