import 'package:flutter/material.dart';
class SizeRender {
  const SizeRender();
  static renderSizeWith(BuildContext context, double designSize) {
    double maxWith = MediaQuery.of(context).size.width;
    double dpr = MediaQuery.of(context).devicePixelRatio;
    return (designSize * ((maxWith * dpr) / 1080)) / dpr;
  }

  static renderSizeHeight(BuildContext context, double designSize) {
    double maxHeight = MediaQuery.of(context).size.height;
    double dpr = MediaQuery.of(context).devicePixelRatio;
    return (designSize * ((maxHeight * dpr) / 2190)) / dpr;
  }

  static renderTextSize(BuildContext context, double textSize) {
    double dpr = MediaQuery.of(context).devicePixelRatio;
    return textSize / dpr;
  }

  static renderBorderSize(BuildContext context, double borderRadius) {
    double dpr = MediaQuery.of(context).devicePixelRatio;
    return borderRadius / dpr;

  }
}
