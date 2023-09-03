import 'package:flutter/material.dart';

class DoubleBackExitAppWidget extends StatefulWidget {
  const DoubleBackExitAppWidget({super.key, required this.child});

  final Widget? child;

  @override
  State<DoubleBackExitAppWidget> createState() =>
      _DoubleBackExitAppWidgetState();
}

class _DoubleBackExitAppWidgetState extends State<DoubleBackExitAppWidget> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugPrint("退出app");
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) >
                const Duration(seconds: 2)) {
          _lastPressedAt = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('再按一次退出'),
            ),
          );
          return false;
        }
        return true;
      },
      child: widget.child ?? const SizedBox(),
    );
  }
}