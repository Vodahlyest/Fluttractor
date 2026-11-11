import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/features/viewer/view_panel.dart';
import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:fluttractor/providers/plot_view_provider.dart';
import 'package:fluttractor/features/viewer/attractor_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/pump_app.dart';

Finder panelWithId(int id) => find.byWidgetPredicate(
  (widget) => widget is ViewPanel && widget.view.id == id,
  description: 'ViewPanel with id $id',
);

TrajectoryPainter painterOfPanel(WidgetTester tester, int id) {
  final customPaint = tester.widget<CustomPaint>(
    find.descendant(
      of: panelWithId(id),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is TrajectoryPainter,
      ),
    ),
  );
  return customPaint.painter! as TrajectoryPainter;
}

void main() {
  testWidgets("one view, finds add button, no close button is present", (
    tester,
  ) async {
    await pumpApp(tester);

    final addButton = find.byIcon(Icons.add);
    final viewPanel = find.byType(ViewPanel);
    final closeButton = find.byIcon(Icons.close);
    expect(addButton, findsOneWidget);
    expect(viewPanel, findsOneWidget);
    expect(closeButton, findsNothing);
  });

  testWidgets("after adding, two views and two close buttons", (tester) async {
    await pumpApp(tester);
    final addButton = find.byIcon(Icons.add);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final viewPanelFirst = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 0,
      description: "finds the first view",
    );
    final viewPanelSecond = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 1,
    );
    final closeButton = find.byIcon(Icons.close);

    expect(viewPanelFirst, findsOneWidget);
    expect(viewPanelSecond, findsOneWidget);
    expect(closeButton, findsExactly(2));
  });

  testWidgets("at limit: no FAB, 4 views and crosses", (tester) async {
    await pumpApp(tester);
    final addButton = find.byIcon(Icons.add);

    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final viewPanels = find.byWidgetPredicate(
      (widget) => widget is ViewPanel,
      description: "finding the viewPanels",
    );
    final closeButtons = find.byIcon(Icons.close);
    expect(addButton, findsNothing);
    expect(viewPanels, findsExactly(4));
    expect(closeButtons, findsExactly(4));
  });
  testWidgets("removing view works properly", (tester) async {
    await pumpApp(tester);
    final addButton = find.byIcon(Icons.add);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final secondPanel = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 1,
    );

    final closeButton = find.descendant(
      of: secondPanel,
      matching: find.byIcon(Icons.close),
    );

    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    final panels = find.byWidgetPredicate((widget) => widget is ViewPanel);
    final closeButtonsInTheEnd = find.byIcon(Icons.close);
    final addButtonAtInTheEnd = find.byIcon(Icons.add);

    expect(panels, findsOneWidget);
    expect(closeButtonsInTheEnd, findsNothing);
    expect(addButtonAtInTheEnd, findsOneWidget);
  });

  testWidgets("remove id 0, id 1 remains in place", (tester) async {
    await pumpApp(tester);
    final addButton = find.byIcon(Icons.add);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final firstPanel = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 0,
    );

    final closeButton = find.descendant(
      of: firstPanel,
      matching: find.byIcon(Icons.close),
    );

    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    final panels = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 1,
    );
    final closeButtonsInTheEnd = find.byIcon(Icons.close);
    final addButtonAtInTheEnd = find.byIcon(Icons.add);

    expect(panels, findsOneWidget);
    expect(closeButtonsInTheEnd, findsNothing);
    expect(addButtonAtInTheEnd, findsOneWidget);
  });

  testWidgets("Camera remains the same after adding view", (tester) async {
    await pumpApp(tester);
    final addButton = find.byIcon(Icons.add);

    final firstPanel = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 0,
    );

    final firstPanelPainterFinder = find.descendant(
      of: firstPanel,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is TrajectoryPainter,
      ),
    );

    CustomPaint firstPanelCustomPaint = tester.widget<CustomPaint>(
      firstPanelPainterFinder,
    );
    TrajectoryPainter firstPanelPainter =
        firstPanelCustomPaint.painter! as TrajectoryPainter;
    final firstPainterCameraOld = firstPanelPainter.camera;

    await tester.drag(firstPanelPainterFinder, Offset(5.0, 2.0));
    await tester.pump();

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    firstPanelCustomPaint = tester.widget<CustomPaint>(firstPanelPainterFinder);
    firstPanelPainter = firstPanelCustomPaint.painter! as TrajectoryPainter;
    final firstPainterCameraNew = firstPanelPainter.camera;

    final secondPanel = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 1,
    );

    final secondPanelPainterFinder = find.descendant(
      of: secondPanel,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is TrajectoryPainter,
      ),
    );

    final secondPanelWidget = tester.widget<CustomPaint>(
      secondPanelPainterFinder,
    );
    final secondPanelPainter = secondPanelWidget.painter! as TrajectoryPainter;
    final secondPainterCamera = secondPanelPainter.camera;

    expect(secondPainterCamera, equals((yaw: 0.0, pitch: 0.0)));
    expect(firstPainterCameraOld, equals((yaw: 0.0, pitch: 0.0)));
    expect(firstPainterCameraNew, isNot(equals(firstPainterCameraOld)));
  });

  testWidgets("camera remains the same after deleting a view", (tester) async {
    await pumpApp(tester);
    final addButton = find.byIcon(Icons.add);

    final secondPanel = find.byWidgetPredicate(
      (widget) => widget is ViewPanel && widget.view.id == 1,
    );

    final secondPanelPainterFinder = find.descendant(
      of: secondPanel,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is TrajectoryPainter,
      ),
    );

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    CustomPaint secondPanelCustomPaint = tester.widget<CustomPaint>(
      secondPanelPainterFinder,
    );
    TrajectoryPainter secondPanelPainter =
        secondPanelCustomPaint.painter! as TrajectoryPainter;
    final secondPainterCameraDefault = secondPanelPainter.camera;

    await tester.drag(secondPanelPainterFinder, Offset(5.0, 2.0));
    await tester.pump();

    secondPanelCustomPaint = tester.widget<CustomPaint>(
      secondPanelPainterFinder,
    );
    secondPanelPainter = secondPanelCustomPaint.painter! as TrajectoryPainter;
    final secondPainterCameraOld =
        secondPanelPainter.camera; //yaw: 0.05, pitch: 0.02

    expect(secondPainterCameraDefault, isNot(equals(secondPainterCameraOld)));

    final closeButton = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is ViewPanel && widget.view.id == 0,
      ),
      matching: find.byIcon(Icons.close),
    );

    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    secondPanelCustomPaint = tester.widget<CustomPaint>(
      secondPanelPainterFinder,
    );
    secondPanelPainter = secondPanelCustomPaint.painter! as TrajectoryPainter;
    final secondPainterCameraNew =
        secondPanelPainter.camera; //yaw: 0.05, pitch: 0.02

    expect(secondPainterCameraNew, equals(secondPainterCameraOld));
  });

  testWidgets(
    'changing the triplet of one view leaves the other view untouched',
    (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Rotate the first panel, otherwise "camera preserved" proves nothing.
      await tester.drag(panelWithId(0), const Offset(50.0, 20.0));
      await tester.pump();

      final firstBefore = painterOfPanel(tester, 0);
      final secondBefore = painterOfPanel(tester, 1);
      expect(firstBefore.camera, isNot(equals((yaw: 0.0, pitch: 0.0))));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(AttractorScreen)),
      );
      container.read(plotViewProvider.notifier).setNewTripletForId(1, (
        axis1: 1,
        axis2: 0,
        axis3: 2,
      ));
      await tester.pumpAndSettle();

      final firstAfter = painterOfPanel(tester, 0);
      final secondAfter = painterOfPanel(tester, 1);

      // The second panel did change...
      expect((
        secondBefore.xindex,
        secondBefore.yindex,
        secondBefore.zindex,
      ), equals((0, 1, 2)));
      expect((
        secondAfter.xindex,
        secondAfter.yindex,
        secondAfter.zindex,
      ), equals((1, 0, 2)));

      // ...and the first one did not notice.
      expect((
        firstAfter.xindex,
        firstAfter.yindex,
        firstAfter.zindex,
      ), equals((firstBefore.xindex, firstBefore.yindex, firstBefore.zindex)));
      expect(firstAfter.camera, equals(firstBefore.camera));
    },
  );
}
