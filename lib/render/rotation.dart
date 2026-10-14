import 'dart:math';

import 'package:bg_calculator/bg_calculator.dart';

/// Rotates a triple of trajectory variables by the camera angles.
/// angles of rotation: yaw and pitch (\psi & \theta)
/// angles are passed strictly in radians, not in degrees
///
Trajectory rotate(
  Trajectory trajectory,
  int xindex,
  int yindex,
  int zindex, {
  required double yaw,
  required double pitch,
}) {
  assert(
    trajectory.dimension >= 3,
    "given trajectory has wrong dimension: ${trajectory.dimension}, when should be 3 or more",
  );
  assert(
    0 <= xindex && xindex <= trajectory.dimension - 1,
    "xindex out of bounds: $xindex",
  );
  assert(
    0 <= yindex && yindex <= trajectory.dimension - 1,
    "yindex out of bounds: $yindex",
  );
  assert(
    0 <= zindex && zindex <= trajectory.dimension - 1,
    "zindex out of bounds: $zindex",
  );
  final Trajectory rotated = Trajectory(
    dimension: 3,
    points: trajectory.points,
  );
  final cosP = cos(pitch);
  final sinP = sin(pitch);
  final cosY = cos(yaw);
  final sinY = sin(yaw);
  for (int i = 0; i < trajectory.points; i++) {
    final x1 =
        (trajectory.states[(i * trajectory.dimension) + xindex] * cosY) -
        (trajectory.states[(i * trajectory.dimension) + yindex] * sinY);
    final y1 =
        (trajectory.states[(i * trajectory.dimension) + xindex] * sinY) +
        (trajectory.states[(i * trajectory.dimension) + yindex] * cosY);
    final y2 =
        (y1 * cosP) -
        (trajectory.states[(i * trajectory.dimension) + zindex] * sinP);
    final z2 =
        (y1 * sinP) +
        (trajectory.states[(i * trajectory.dimension) + zindex] * cosP);
    rotated.states[i * rotated.dimension] = x1;
    rotated.states[(i * rotated.dimension) + 1] = y2;
    rotated.states[(i * rotated.dimension) + 2] = z2;
  }
  return rotated;
}
