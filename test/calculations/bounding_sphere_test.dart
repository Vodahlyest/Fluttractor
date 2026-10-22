import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/trajectory_init.dart';

import 'package:fluttractor/calculations/bounding_sphere.dart';

import 'dart:math';

void main() {
  test("validation test of the bounding sphere", () {
    Trajectory testTrajectory = trajectoryInit([
      [0, 0, 0],
      [0, 0, 2],
      [0, 2, 0],
      [0, 2, 2],
      [2, 0, 0],
      [2, 0, 2],
      [2, 2, 0],
      [2, 2, 2],
    ]);
    final testSphere = boundingSphere(testTrajectory, 0, 1, 2);
    expect(testSphere.cx, closeTo(1, 1e-12));
    expect(testSphere.cy, closeTo(1, 1e-12));
    expect(testSphere.cz, closeTo(1, 1e-12));
    expect(testSphere.radius, closeTo(sqrt(3), 1e-12));
  });
  test("working with one point", () {
    Trajectory testTrajectory = trajectoryInit([
      [3, -2, 5],
    ]);
    final testSphere = boundingSphere(testTrajectory, 0, 1, 2);
    expect(testSphere.cx, closeTo(3, 1e-12));
    expect(testSphere.cy, closeTo(-2, 1e-12));
    expect(testSphere.cz, closeTo(5, 1e-12));
    expect(testSphere.radius, closeTo(0, 1e-12));
  });
  test("negative coordinate values", () {
    final testTrajectory = trajectoryInit([
      [-4, -1, 0],
      [2, 3, 6],
    ]);
    final testSphere = boundingSphere(testTrajectory, 0, 1, 2);
    expect(testSphere.cx, closeTo(-1, 1e-12));
    expect(testSphere.cy, closeTo(1, 1e-12));
    expect(testSphere.cz, closeTo(3, 1e-12));
    expect(testSphere.radius, closeTo(sqrt(22), 1e-12));
  });
  test("middle point is actually middle, not the mean value", () {
    final testTrajectory = trajectoryInit([
      [0, 0, 0],
      [10, 0, 0],
      [1, 0, 0],
      [1, 0, 0],
    ]);
    final testSphere = boundingSphere(testTrajectory, 0, 1, 2);
    expect(testSphere.cx, closeTo(5, 1e-12));
    expect(testSphere.cy, closeTo(0, 1e-12));
    expect(testSphere.cz, closeTo(0, 1e-12));
    expect(testSphere.radius, closeTo(5, 1e-12));
  });
  test("radius is calculated win max(), not just the last point", () {
    final testTrajectory = trajectoryInit([
      [0, 0, 0],
      [2, 2, 2],
      [1, 1, 1],
    ]);
    final testSphere = boundingSphere(testTrajectory, 0, 1, 2);
    expect(testSphere.cx, closeTo(1, 1e-12));
    expect(testSphere.cy, closeTo(1, 1e-12));
    expect(testSphere.cz, closeTo(1, 1e-12));
    expect(testSphere.radius, closeTo(sqrt(3), 1e-12));
  });
  test("4-D system", () {
    final testTrajectory = trajectoryInit([
      [10, 0, 999, 0],
      [12, 2, -999, 4],
    ]);
    final testSphere = boundingSphere(testTrajectory, 3, 1, 0);
    expect(testSphere.cx, closeTo(2, 1e-12));
    expect(testSphere.cy, closeTo(1, 1e-12));
    expect(testSphere.cz, closeTo(11, 1e-12));
    expect(testSphere.radius, closeTo(sqrt(6), 1e-12));
  });
}
