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

    testWidgets('projects x horizontally and z vertically', (tester) async {
      await tester.pumpWidget(const MyApp());

      final customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
      final painter = customPaint.painter! as TrajectoryPainter;

      expect(painter.hIndex, 0);
      expect(painter.vIndex, 2);
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
