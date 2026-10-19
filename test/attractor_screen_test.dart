import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/main.dart';
import 'package:fluttractor/render/trajectory_painter.dart';

void main() {
  final trajectoryPaintFinder = find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is TrajectoryPainter,
    description: 'CustomPaint with TrajectoryPainter',
  );
  group('AttractorScreen', () {
    testWidgets('draws the trajectory with TrajectoryPainter', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(trajectoryPaintFinder, findsOneWidget);
    });

    testWidgets('draws (0, 1, 2) triplet and start camera (0, 0)', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      final customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
      final painter = customPaint.painter! as TrajectoryPainter;

      expect(painter.xindex, 0);
      expect(painter.yindex, 1);
      expect(painter.zindex, 2);
      expect(painter.camera, (yaw: 0.0, pitch: 0.0));
    });

    testWidgets('canvas fills the whole screen', (tester) async {
      await tester.pumpWidget(const MyApp());

      expect(tester.getSize(trajectoryPaintFinder), const Size(800, 600));
    });

    testWidgets('canvas follows window resize', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MyApp());
      tester.view.physicalSize = const Size(1200, 400);
      await tester.pump();

      expect(tester.getSize(trajectoryPaintFinder), const Size(1200, 400));
    });
  });
}
