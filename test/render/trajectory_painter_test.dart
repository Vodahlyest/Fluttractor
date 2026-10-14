import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';

void main() {
  group("shouldRepaint method testing", () {
    test("same trajectory, same indicies and color", () {
      final systemTrajectory1 = integrate(
        Rk4(system: lorenz),
        Float64List.fromList([1.0, 1.0, 1.0]),
        0,
        50,
        0.01,
      );
      final painter1 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        hIndex: 0,
        vIndex: 2,
        pointColor: Colors.blue,
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        hIndex: 0,
        vIndex: 2,
        pointColor: Colors.blue,
      );
      expect(painter2.shouldRepaint(painter1), isFalse);
    });
    test("different indecies", () {
      final systemTrajectory1 = integrate(
        Rk4(system: lorenz),
        Float64List.fromList([1.0, 1.0, 1.0]),
        0,
        50,
        0.01,
      );
      final painter1 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        hIndex: 0,
        vIndex: 2,
        pointColor: Colors.blue,
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        hIndex: 0,
        vIndex: 1,
        pointColor: Colors.blue,
      );
      expect(painter2.shouldRepaint(painter1), isTrue);
    });
    test("different color", () {
      final systemTrajectory1 = integrate(
        Rk4(system: lorenz),
        Float64List.fromList([1.0, 1.0, 1.0]),
        0,
        50,
        0.01,
      );
      final painter1 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        hIndex: 0,
        vIndex: 2,
        pointColor: Colors.blue,
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        hIndex: 0,
        vIndex: 2,
        pointColor: Colors.red,
      );
      expect(painter2.shouldRepaint(painter1), isTrue);
    });
    test("different trajectories give true, even if elements are the same", () {
      final systemTrajectory1 = integrate(
        Rk4(system: lorenz),
        Float64List.fromList([1.0, 1.0, 1.0]),
        0,
        50,
        0.01,
      );
      final systemTrajectory2 = integrate(
        Rk4(system: lorenz),
        Float64List.fromList([1.0, 1.0, 1.0]),
        0,
        50,
        0.01,
      );
      final painter1 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        hIndex: 0,
        vIndex: 2,
        pointColor: Colors.blue,
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory2,
        hIndex: 0,
        vIndex: 2,
        pointColor: Colors.blue,
      );
      expect(painter2.shouldRepaint(painter1), isTrue);
    });
  });
}
