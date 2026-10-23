import 'dart:async';
import 'package:fluttractor/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/calculations/scene.dart';
import 'package:fluttractor/providers/scene_provider.dart';
import 'package:fluttractor/render/trajectory_painter.dart';

import 'helpers/pump_app.dart';

void main() {
  final trajectoryPaintFinder = find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.painter is TrajectoryPainter,
    description: 'CustomPaint with TrajectoryPainter',
  );
  group('AttractorScreen', () {
    testWidgets('draws the trajectory with TrajectoryPainter', (tester) async {
      await pumpApp(tester);

      expect(trajectoryPaintFinder, findsOneWidget);
    });

    testWidgets('draws (0, 1, 2) triplet and start camera (0, 0)', (
      tester,
    ) async {
      await pumpApp(tester);

      final customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
      final painter = customPaint.painter! as TrajectoryPainter;

      expect(painter.xindex, 0);
      expect(painter.yindex, 1);
      expect(painter.zindex, 2);
      expect(painter.camera, (yaw: 0.0, pitch: 0.0));
    });

    testWidgets('canvas fills the whole screen', (tester) async {
      await pumpApp(tester);

      expect(tester.getSize(trajectoryPaintFinder), const Size(800, 600));
    });

    testWidgets('canvas follows window resize', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);
      tester.view.physicalSize = const Size(1200, 400);
      await tester.pump();

      expect(tester.getSize(trajectoryPaintFinder), const Size(1200, 400));
    });
  });
  group('scene loading tests', () {
    testWidgets('loading screen test', (tester) async {
      final completer = Completer<Scene>();
      await pumpApp(tester, completer.future);

      Finder progressIndicator = find.byType(CircularProgressIndicator);
      expect(progressIndicator, findsOneWidget);
      expect(trajectoryPaintFinder, findsNothing);

      await tester.pump(Duration(seconds: 15));
      expect(progressIndicator, findsOneWidget);
      expect(trajectoryPaintFinder, findsNothing);

      completer.complete(sceneByDefault);

      await tester.pump();
      progressIndicator = find.byType(CircularProgressIndicator);
      expect(progressIndicator, findsNothing);
      expect(trajectoryPaintFinder, findsOneWidget);
    });
    testWidgets("Future finishes with error", (tester) async {
      final completer = Completer<Scene>();
      await pumpApp(tester, completer.future);
      completer.completeError(StateError("LOL, i broke my own app"));
      await tester.pump();

      final progressIndicator = find.byType(CircularProgressIndicator);
      final errorText = find.textContaining(
        "error occurred while performing calculations",
      );
      final errorDescription = find.textContaining("LOL, i broke my own app");
      expect(trajectoryPaintFinder, findsNothing);
      expect(progressIndicator, findsNothing);
      expect(errorText, findsOneWidget);
      expect(errorDescription, findsOneWidget);
    });
    testWidgets("real test with real isolate working", (tester) async {
      final providerContainer = ProviderContainer();
      addTearDown(providerContainer.dispose);

      await tester.runAsync(() => providerContainer.read(sceneProvider.future));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: providerContainer,
          child: const MyApp(),
        ),
      );
      final progressIndicator = find.byType(CircularProgressIndicator);
      final customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
      final painter = customPaint.painter! as TrajectoryPainter;

      expect(trajectoryPaintFinder, findsOneWidget);
      expect(progressIndicator, findsNothing);
      expect(painter.trajectory.points, equals(5001));
    });
  });
}
