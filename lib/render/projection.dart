import 'package:bg_calculator/bg_calculator.dart';

import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';

Float32List project(
  Trajectory trajectory,
  int hVarIndex,
  int vVarIndex,
  Size canvasSize, {
  double padding = 20,
}) {
  final projection = Float32List(2 * trajectory.points);

  double xMin = double.infinity;
  double xMax = double.negativeInfinity;
  double zMin = double.infinity;
  double zMax = double.negativeInfinity;
  for (int i = 0; i < trajectory.points; i++) {
    xMin = min(xMin, trajectory.states[(i * trajectory.dimension) + hVarIndex]);
    xMax = max(xMax, trajectory.states[(i * trajectory.dimension) + hVarIndex]);
    zMin = min(zMin, trajectory.states[(i * trajectory.dimension) + vVarIndex]);
    zMax = max(zMax, trajectory.states[(i * trajectory.dimension) + vVarIndex]);
  }

  if (zMax - zMin == 0 && xMax - xMin == 0) {
    for (int i = 0; i < trajectory.points; i++) {
      final px = (canvasSize.width / 2);
      final py = (canvasSize.height / 2);
      projection[i * 2] = px;
      projection[(i * 2) + 1] = py;
    }
    return projection;
  }

  final scaleW = (canvasSize.width - (2 * padding)) / (xMax - xMin);
  final scaleH = (canvasSize.height - (2 * padding)) / (zMax - zMin);
  final resultingScale = min(scaleW, scaleH);
  final cx = (xMin + xMax) / 2;
  final cz = (zMin + zMax) / 2;

  for (int i = 0; i < trajectory.points; i++) {
    final px =
        (canvasSize.width / 2) +
        ((trajectory.states[(i * trajectory.dimension) + hVarIndex] - cx)) *
            resultingScale;
    final py =
        (canvasSize.height / 2) -
        ((trajectory.states[(i * trajectory.dimension) + vVarIndex] - cz)) *
            resultingScale;
    projection[i * 2] = px;
    projection[(i * 2) + 1] = py;
  }

  return projection;
}

/// this function expects a rotated trajectory
/// with center at (0, 0, 0) and dimension of 3
Float32List projectFixed(
  Trajectory rotated,
  Size canvasSize,
  double radius, {
  double padding = 20,
}) {
  assert(rotated.dimension == 3, "wrong dimensions! ${rotated.dimension}");
  assert(radius >= 0, "radius gotta be >= 0: $radius");
  final projection = Float32List(2 * rotated.points);
  final scale = radius != 0
      ? (min(canvasSize.width, canvasSize.height) - 2 * padding) / (2 * radius)
      : (min(canvasSize.width, canvasSize.height) - 2 * padding) / 2;

  for (int i = 0; i < rotated.points; i++) {
    final px =
        (canvasSize.width / 2) +
        ((rotated.states[(i * rotated.dimension)])) * scale;
    final py =
        (canvasSize.height / 2) -
        ((rotated.states[(i * rotated.dimension) + 2])) * scale;
    projection[i * 2] = px;
    projection[(i * 2) + 1] = py;
  }

  return projection;
}
