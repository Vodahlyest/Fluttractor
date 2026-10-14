import 'package:flutter/material.dart';
import 'package:bg_calculator/bg_calculator.dart';

import 'dart:ui';

import 'projection.dart';

class TrajectoryPainter extends CustomPainter {
  final Trajectory trajectory;
  final int hIndex;
  final int vIndex;
  final Color pointColor;

  const TrajectoryPainter({
    required this.trajectory,
    required this.hIndex,
    required this.vIndex,
    required this.pointColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = project(trajectory, hIndex, vIndex, size);
    final paint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0
      ..isAntiAlias = true;
    canvas.drawRawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant TrajectoryPainter oldPainter) {
    return !identical(trajectory, oldPainter.trajectory) ||
        hIndex != oldPainter.hIndex ||
        vIndex != oldPainter.vIndex ||
        pointColor != oldPainter.pointColor;
  }
}
