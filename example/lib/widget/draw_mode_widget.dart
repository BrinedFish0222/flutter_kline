import 'package:flutter/material.dart';

import '../data/example_day_widget.dart';

/// 画线模式组件
class DrawModeWidget extends StatefulWidget {
  const DrawModeWidget({
    super.key,
    required this.drawMode,
    this.onPressed,
  });

  /// 是否处于画线模式
  final DrawChartType drawMode;

  /// 按钮事件
  final void Function(DrawChartType type)? onPressed;

  @override
  State<DrawModeWidget> createState() => _DrawModeWidgetState();
}

class _DrawModeWidgetState extends State<DrawModeWidget> {
  late DrawChartType _drawMode;

  @override
  void initState() {
    _drawMode = widget.drawMode;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DrawModeWidget oldWidget) {
    _drawMode = widget.drawMode;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final String textContent = !_drawMode.isNone ? "画线中" : "画线";
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          ElevatedButton(onPressed: _edit, child: Text(textContent)),
          const SizedBox(
            width: 8,
          ),
          if (!_drawMode.isNone)
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _drawChartTypeWidget(
                    type: DrawChartType.line,
                    icon: Icons.show_chart,
                  ),
                  _drawChartTypeWidget(
                    type: DrawChartType.circle,
                    icon: Icons.circle_outlined,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  /// 画图类型组件
  Widget _drawChartTypeWidget({
    required DrawChartType type,
    required IconData icon,
  }) {
    Color color = _drawMode == type
        ? Colors.lightBlue.withOpacity(.5)
        : Colors.transparent;

    return Container(
      color: color,
      child: IconButton(
        onPressed: () => _chooseType(type),
        icon: Icon(icon),
      ),
    );
  }

  /// 选择类型
  void _chooseType(DrawChartType type) {
    _drawMode = type;
    if (widget.onPressed != null) {
      widget.onPressed!(_drawMode);
    }
    setState(() {});
  }

  /// 编辑事件
  void _edit() {
    _drawMode = _drawMode.isNone ? DrawChartType.edit : DrawChartType.none;

    if (widget.onPressed != null) {
      widget.onPressed!(_drawMode);
    }

    setState(() {});
  }
}
