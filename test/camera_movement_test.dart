import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/main.dart';
import 'package:fluttractor/render/trajectory_painter.dart';

import 'dart:math';

void main() {
  final trajectoryPaintFinder = find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is TrajectoryPainter,
    description: 'CustomPaint with TrajectoryPainter',
  );

  testWidgets("drag: yaw + 1 rad", (tester) async {
    await tester.pumpWidget(const MyApp());

    CustomPaint customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    TrajectoryPainter painter = customPaint.painter! as TrajectoryPainter;
    final oldCam = painter.camera;

    await tester.drag(trajectoryPaintFinder, Offset(100.0, 0.0));

    await tester.pump();
    customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    painter = customPaint.painter! as TrajectoryPainter;
    expect(oldCam, equals((yaw: 0.0, pitch: 0.0)));
    expect(painter.camera.yaw, greaterThan(0.0));
    expect(painter.camera.pitch, equals(0.0));
  });
  testWidgets("drag: pitch + 1 rad", (tester) async {
    await tester.pumpWidget(const MyApp());

    CustomPaint customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    TrajectoryPainter painter = customPaint.painter! as TrajectoryPainter;
    final oldCam = painter.camera;

    await tester.drag(trajectoryPaintFinder, Offset(0.0, 100.0));

    await tester.pump();
    customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    painter = customPaint.painter! as TrajectoryPainter;
    expect(oldCam, equals((yaw: 0.0, pitch: 0.0)));
    expect(painter.camera.pitch, greaterThan(0.0));
    expect(painter.camera.yaw, equals(0.0));
  });
  testWidgets("pitching up is strictly limited at +pi / 2 rads", (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    CustomPaint customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    TrajectoryPainter painter = customPaint.painter! as TrajectoryPainter;
    final oldCam = painter.camera;

    await tester.drag(trajectoryPaintFinder, Offset(0.0, 1000.0));

    await tester.pump();
    customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    painter = customPaint.painter! as TrajectoryPainter;
    expect(oldCam, equals((yaw: 0.0, pitch: 0.0)));
    expect(painter.camera.pitch, equals(pi / 2));
    expect(painter.camera.yaw, equals(0.0));
  });
  testWidgets("pitching down is limited at -pi / 2 rads", (tester) async {
    await tester.pumpWidget(const MyApp());

    CustomPaint customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    TrajectoryPainter painter = customPaint.painter! as TrajectoryPainter;
    final oldCam = painter.camera;

    await tester.drag(trajectoryPaintFinder, Offset(0.0, -1000.0));

    await tester.pump();
    customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
    painter = customPaint.painter! as TrajectoryPainter;
    expect(oldCam, equals((yaw: 0.0, pitch: 0.0)));
    expect(painter.camera.pitch, equals(-pi / 2));
    expect(painter.camera.yaw, equals(0.0));
  });
}
