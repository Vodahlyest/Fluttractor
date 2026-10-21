import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/render/projection.dart';

import '../helpers/trajectory_init.dart';

import 'dart:ui';

void main() {
  test("validation test, point (0, 0, 0)", () {
    final testInit = trajectoryInit([
      [0, 0, 0],
    ]);
    final testProjection = projectFixed(testInit, Size(800, 600), 10);
    expect(testProjection, equals([400, 300]));
  });
  test("scale is calculated with respect to the smalles side of window", () {
    final testTrajectory = trajectoryInit([
      [10, 0, 0],
    ]);
    final testProjection = projectFixed(testTrajectory, Size(800, 600), 10);
    expect(testProjection, equals([680, 300]));
  });
  test("translation of the vertical -> equals to the padding", () {
    final testTrajectory = trajectoryInit([
      [0, 0, 10],
    ]);
    final testProjection = projectFixed(testTrajectory, Size(800, 600), 10);
    expect(testProjection, equals([400, 20]));
  });
  test("depth does not affect the projection", () {
    final testTrajectory = trajectoryInit([
      [0, 10, 0],
    ]);
    final testProjection = projectFixed(testTrajectory, Size(800, 600), 10);
    expect(testProjection, equals([400, 300]));
  });
  test("radius of 0 does not brake the function", () {
    final testInit = trajectoryInit([
      [0, 0, 0],
    ]);
    final testProjection = projectFixed(testInit, Size(800, 600), 0);
    expect(testProjection, equals([400, 300]));
  });
  test("3 points, length of projection array is 6", () {
    final testInit = trajectoryInit([
      [0, 0, 0],
      [3, 3, 3],
      [6, 6, 6],
    ]);
    final testProjection = projectFixed(testInit, Size(800, 600), 0);
    expect(testProjection.length, equals(6));
  });
}
