import 'package:flutter/material.dart';

class CommonException implements Exception {
  final dynamic message;

  CommonException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "CommonException";
    return "$message";
  }
}