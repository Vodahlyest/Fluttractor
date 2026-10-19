import 'package:bg_calculator/bg_calculator.dart';
import 'package:collection/collection.dart';

import 'dart:math';

({double cx, double cy, double cz, double radius}) boundingSphere(
  Trajectory trajectory,
  int xIndex,
  int yIndex,
  int zIndex,
) {
  double minX = trajectory.states
      .whereIndexed((index, value) => index % trajectory.dimension == xIndex)
      .reduce(min);
  double maxX = trajectory.states
      .whereIndexed((index, value) => index % trajectory.dimension == xIndex)
      .reduce(max);
  double minY = trajectory.states
      .whereIndexed((index, value) => index % trajectory.dimension == yIndex)
      .reduce(min);
  double maxY = trajectory.states
      .whereIndexed((index, value) => index % trajectory.dimension == yIndex)
      .reduce(max);
  double minZ = trajectory.states
      .whereIndexed((index, value) => index % trajectory.dimension == zIndex)
      .reduce(min);
  double maxZ = trajectory.states
      .whereIndexed((index, value) => index % trajectory.dimension == zIndex)
      .reduce(max);
  double cx = (maxX + minX) / 2;
  double cy = (maxY + minY) / 2;
  double cz = (minZ + maxZ) / 2;
  double radius = Iterable.generate(
    trajectory.points,
    (point) => sqrt(
      ((trajectory.states[(point * trajectory.dimension) + xIndex] - cx) *
              (trajectory.states[(point * trajectory.dimension) + xIndex] -
                  cx)) +
          ((trajectory.states[(point * trajectory.dimension) + yIndex] - cy) *
              (trajectory.states[(point * trajectory.dimension) + yIndex] -
                  cy)) +
          ((trajectory.states[(point * trajectory.dimension) + zIndex] - cz) *
              (trajectory.states[(point * trajectory.dimension) + zIndex] -
                  cz)),
    ),
  ).reduce(max);
  return (cx: cx, cy: cy, cz: cz, radius: radius);
}
