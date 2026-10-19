import 'package:flutter/material.dart';
import 'package:bg_calculator/bg_calculator.dart';

import 'dart:ui';

import 'projection.dart';
import 'rotation.dart';
import 'camera.dart';

class TrajectoryPainter extends CustomPainter {
  final Trajectory trajectory;
  final int xindex;
  final int yindex;
  final int zindex;
  final Color pointColor;
  final Camera camera;
  final bool antiAlias;
  final ({double cx, double cy, double cz, double radius}) sphere;

  const TrajectoryPainter({
    required this.trajectory,
    required this.xindex,
    required this.yindex,
    required this.zindex,
    required this.pointColor,
    required this.camera,
    required this.sphere,
    required this.antiAlias,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rotatedPlot = rotate(
      trajectory,
      xindex,
      yindex,
      zindex,
      yaw: camera.yaw,
      pitch: camera.pitch,
      center: (cx: sphere.cx, cy: sphere.cy, cz: sphere.cz),
    );
    final points = projectFixed(rotatedPlot, size, sphere.radius);
    final paint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0
      ..isAntiAlias = antiAlias;
    canvas.drawRawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant TrajectoryPainter oldPainter) {
    return !identical(trajectory, oldPainter.trajectory) ||
        xindex != oldPainter.xindex ||
        yindex != oldPainter.yindex ||
        zindex != oldPainter.zindex ||
        camera != oldPainter.camera ||
        pointColor != oldPainter.pointColor ||
        sphere != oldPainter.sphere ||
        antiAlias != oldPainter.antiAlias;
  }
}
