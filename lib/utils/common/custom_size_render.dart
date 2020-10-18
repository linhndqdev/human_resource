import 'package:flutter/material.dart';
import 'dart:io';
class SizeRender {
  static renderBorderSize(BuildContext context, double borderRadius) {
    double dpr = MediaQuery.of(context).devicePixelRatio;
    return borderRadius / dpr;
  }
}
