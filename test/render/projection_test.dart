import 'package:fluttractor/render/projection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bg_calculator/bg_calculator.dart';

import '../helpers/trajectory_init.dart';

import 'dart:ui';
import 'dart:typed_data';

void main() {
  test("resulting array has length of points * 2", () {
    final trajectory = trajectoryInit([
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0],
      [7.0, 8.0, 9.0],
    ]);
    final pixelPoints = project(trajectory, 0, 2, Size(800, 600));
    expect(pixelPoints.length, equals(6));
  });
  test("corners test", () {
    final trajectory = trajectoryInit([
      [0.0, 2.0, 0.0],
      [2.0, 1.0, 1.0],
    ]);
    final pixelPoints = project(trajectory, 0, 2, Size(200, 100), padding: 0);
    expect(pixelPoints, equals([0.0, 100.0, 200.0, 0.0]));
  });
  test("scale test: aspect ratio stays", () {
    final trajectory = trajectoryInit([
      [0.0, 2.0, 0.0],
      [2.0, 1.0, 1.0],
    ]);
    final pixelPoints = project(trajectory, 0, 2, Size(100, 100), padding: 0);
    expect(pixelPoints, equals([0.0, 75.0, 100.0, 25.0]));
  });
  test("vertical index is actually used", () {
    final trajectory1 = trajectoryInit([
      [0.0, 7.0, 0.0],
      [2.0, 3.0, 1.0],
    ]);
    final pixelPoints1 = project(trajectory1, 0, 2, Size(200, 100), padding: 0);
    final pixelPoints2 = project(trajectory1, 0, 1, Size(200, 100), padding: 0);
    expect(pixelPoints1, isNot(equals(pixelPoints2)));
    expect(pixelPoints1, equals([0.0, 100.0, 200.0, 0.0]));
    expect(pixelPoints2, equals([75.0, 0.0, 125.0, 100.0]));
  });
  test("point span is zero", () {
    final trajectory = trajectoryInit([
      [3.0, 2.0, 1.0],
      [3.0, 2.0, 1.0],
      [3.0, 2.0, 1.0],
    ]);
    final pixelPoints = project(trajectory, 0, 2, Size(800, 600));
    expect(pixelPoints, equals([400, 300, 400, 300, 400, 300]));
  });
  test("zero span only on one axis", () {
    final trajectory = trajectoryInit([
      [3.0, 2.0, 0.0],
      [3.0, 2.0, 1.0],
      [3.0, 2.0, 1.0],
    ]);
    final pixelPoints = project(trajectory, 0, 2, Size(800, 600));
    expect(pixelPoints, equals([400, 580, 400, 20, 400, 20]));
  });
  test("padding works correctly", () {
    final trajectory = trajectoryInit([
      [0.0, 2.0, 0.0],
      [2.0, 1.0, 1.0],
    ]);
    final pixelPoints = project(trajectory, 0, 2, Size(200, 100), padding: 10);
    expect(pixelPoints, equals([20.0, 90.0, 180.0, 10.0]));
  });
  test("smoke test, real system", () {
    final trajectory = integrate(
      Rk4(system: lorenz),
      Float64List.fromList([1.0, 1.0, 1.0]),
      0,
      50,
      0.01,
    );
    final pixelPoints = project(trajectory, 0, 2, Size(800, 600));
    for (int i = 0; i < pixelPoints.length; i += 2) {
      expect(pixelPoints[i], inInclusiveRange(20, 780));
    }
    for (int i = 1; i < pixelPoints.length; i += 2) {
      expect(pixelPoints[i], inInclusiveRange(20, 580));
    }
  });
}
