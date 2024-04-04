import 'package:flutter/material.dart';

import '../common/utils/kline_date_util.dart';
import '../common/utils/kline_util.dart';

/// 底部日期栏
class BottomDateWidget extends StatefulWidget {
  const BottomDateWidget({
    super.key,
    required this.startDate,
    required this.endDate,
    this.currentDate,
    this.currentDateLeftPadding = 0,
    required this.periodNumber,
    this.formatType = DateTimeFormatType.date,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? currentDate;
  final double currentDateLeftPadding;
  final DateTimeFormatType formatType;

  /// 周期数
  final int periodNumber;

  @override
  State<BottomDateWidget> createState() => _BottomDateWidgetState();
}

class _BottomDateWidgetState extends State<BottomDateWidget> {
  final TextStyle _textStyle =
      const TextStyle(color: Color(0xff737373), fontSize: 10);

  final GlobalKey _globalKey = GlobalKey();
  Size? _currentDateWidgetSize;

  @override
  void didUpdateWidget(covariant BottomDateWidget oldWidget) {
    KlineUtil.logd('didUpdateWidget run ...', name: toStringShort());
    if (widget.currentDate == null) {
      _currentDateWidgetSize = null;
    }

    if (widget.currentDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _resetCurrentDateWidgetSize();
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  /// 重置当前日期组件宽度
  void _resetCurrentDateWidgetSize() {
    _currentDateWidgetSize = _globalKey.currentContext?.size;
    KlineUtil.logd('_currentDateWidgetSize $_currentDateWidgetSize, padding ${widget.currentDateLeftPadding}', name: toStringShort());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      double halfWidth = (_currentDateWidgetSize?.width ?? 0) / 2;
      // 重新定位【当前日期】位置
      double currentDateLeftPadding = widget.currentDateLeftPadding - halfWidth;
      KlineUtil.logd('build currentDateLeftPadding0 $currentDateLeftPadding, halfWidth $halfWidth, minWidth ${boxConstraints.minWidth}', name: toStringShort());

      // 约束末尾位置
      if (currentDateLeftPadding >
          boxConstraints.maxWidth - (_currentDateWidgetSize?.width ?? 0)) {
        currentDateLeftPadding = boxConstraints.maxWidth - halfWidth * 2;
      }

      // 约束开始位置
      if (currentDateLeftPadding < 0) {
        KlineUtil.logd('build start position', name: toStringShort());
        currentDateLeftPadding = 0;
      }

      KlineUtil.logd('build currentDateLeftPadding $currentDateLeftPadding', name: toStringShort());

      return Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FittedBox(
                    child: Text(
                      KlineDateUtil.formatDate(
                          date: widget.startDate,
                          formatType: widget.formatType),
                      style: _textStyle,
                    ),
                  ),
                  if (widget.formatType != DateTimeFormatType.time)
                    const SizedBox(
                      width: 8,
                    ),
                  if (widget.formatType != DateTimeFormatType.time)
                    FittedBox(
                        child: Text(
                      '周期数${widget.periodNumber}个',
                      style: _textStyle,
                    )),
                ],
              ),
              if (widget.formatType == DateTimeFormatType.time)
                Center(
                  child: FittedBox(
                    child: Text(
                      KlineDateUtil.formatDate(
                          date: DateTime(2024, 1, 1, 11, 30), formatType: widget.formatType),
                      style: _textStyle,
                    ),
                  ),
                ),
              FittedBox(
                child: Text(
                  KlineDateUtil.formatDate(
                      date: widget.endDate, formatType: widget.formatType),
                  style: _textStyle,
                ),
              ),
            ],
          ),
          Positioned(
            left: currentDateLeftPadding,
            child: Opacity(
              opacity:
                  widget.currentDate != null && _currentDateWidgetSize != null
                      ? 1
                      : 0,
              child: Container(
                key: _globalKey,
                decoration: const BoxDecoration(
                  color: Color(0xFFA3E1FF),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    KlineDateUtil.formatDate(
                        date: widget.currentDate,
                        formatType: widget.formatType),
                    style: _textStyle.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
