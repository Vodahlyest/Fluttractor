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
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
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
        xindex: 2,
        yindex: 0,
        zindex: 1,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
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
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory1,
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.red,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
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
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
      );
      final painter2 = TrajectoryPainter(
        trajectory: systemTrajectory2,
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 0.0),
      );
      expect(painter2.shouldRepaint(painter1), isTrue);
    });
  });
}
