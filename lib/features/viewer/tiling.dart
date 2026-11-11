import 'package:flutter/material.dart';
import 'package:fluttractor/constant_values/tile_gap.dart';
import 'package:fluttractor/constant_values/view_limit.dart';

List<Rect> buildTiles(int viewsAmount, Size screenSize, {double gap = tileGap}) {
  final isHorizontal = screenSize.width >= screenSize.height;
  final halfWidth = screenSize.width / 2;
  final halfHeight = screenSize.height / 2;
  final rects = switch (viewsAmount) {
    1 => [Rect.fromLTWH(0, 0, screenSize.width, screenSize.height)],
    2 when isHorizontal => [
      Rect.fromLTWH(0, 0, halfWidth, screenSize.height),
      Rect.fromLTWH(
        screenSize.width - halfWidth,
        0,
        halfWidth,
        screenSize.height,
      ),
    ],
    2 when !isHorizontal => [
      Rect.fromLTWH(0, 0, screenSize.width, halfHeight),
      Rect.fromLTWH(
        0,
        screenSize.height - halfHeight,
        screenSize.width,
        halfHeight,
      ),
    ],
    3 when isHorizontal => [
      Rect.fromLTWH(0, 0, halfWidth, screenSize.height),
      Rect.fromLTWH(screenSize.width - halfWidth, 0, halfWidth, halfHeight),
      Rect.fromLTWH(
        screenSize.width - halfWidth,
        screenSize.height - halfHeight,
        halfWidth,
        halfHeight,
      ),
    ],
    3 when !isHorizontal => [
      Rect.fromLTWH(0, 0, screenSize.width, halfHeight),
      Rect.fromLTWH(0, screenSize.height - halfHeight, halfWidth, halfHeight),
      Rect.fromLTWH(
        screenSize.width - halfWidth,
        screenSize.height - halfHeight,
        halfWidth,
        halfHeight,
      ),
    ],
    4 => [
      Rect.fromLTWH(0, 0, halfWidth, halfHeight),
      Rect.fromLTWH(screenSize.width - halfWidth, 0, halfWidth, halfHeight),
      Rect.fromLTWH(0, screenSize.height - halfHeight, halfWidth, halfHeight),
      Rect.fromLTWH(
        screenSize.width - halfWidth,
        screenSize.height - halfHeight,
        halfWidth,
        halfHeight,
      ),
    ],
    _ => throw ArgumentError(
      "Specify the correct amount of views, from 1 to $viewLimit, viewsAmount: $viewsAmount",
    ),
  };
  return rects.map((rect) => rect.deflate(gap / 2)).toList();
}
