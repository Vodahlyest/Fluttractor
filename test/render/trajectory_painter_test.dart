import 'dart:ui';

import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../helpers/trajectory_init.dart';

import 'dart:typed_data';

class FakeCanvas extends Fake implements Canvas {
  late Float32List _points;

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    _points = points;
  }
}

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
  group("decimation tests", () {
    test("after decimation only 2 points remain", () {
      final testTrajectory = trajectoryInit(
        List.generate(101, (i) => [i * 0.001, 0.0, 0.0]),
      );
      final testPainter = TrajectoryPainter(
        trajectory: testTrajectory,
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 280.0),
      );
      final fakeCanvas = FakeCanvas();
      testPainter.paint(fakeCanvas, Size(800, 600));
      expect(fakeCanvas._points.length, equals(4));
      expect(fakeCanvas._points[0], closeTo(400, 1e-12));
      expect(
        fakeCanvas._points[fakeCanvas._points.length - 2],
        closeTo(400.1, 1e-3),
      );
      expect(fakeCanvas._points[1], equals(600 / 2));
      expect(fakeCanvas._points[3], equals(600 / 2));
    });
    test("step > pixel -> nothing's thrown out", () {
      final testTrajectory = trajectoryInit(
        Iterable.generate(11, (i) => [i * 0.01, 0.0, 0.0]).toList(),
      );
      final testPainter = TrajectoryPainter(
        trajectory: testTrajectory,
        xindex: 0,
        yindex: 1,
        zindex: 2,
        pointColor: Colors.blue,
        camera: (yaw: 0, pitch: 0),
        sphere: (cx: 0.0, cy: 0.0, cz: 0.0, radius: 1.0),
      );
      final fakeCanvas = FakeCanvas();
      testPainter.paint(fakeCanvas, Size(800, 600));
      expect(fakeCanvas._points.length, equals(22));
    });
  });
}
