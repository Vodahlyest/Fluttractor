import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/calculations/view_axes.dart';
import 'package:fluttractor/features/viewer/attractor_screen.dart';
import 'package:fluttractor/providers/view_axes_provider.dart';
import 'package:fluttractor/render/trajectory_painter.dart';

import 'helpers/pump_app.dart';

// pumpApp overrides the system with Lorenz: variables x, y, z (indices 0, 1, 2),
// so every row of the sheet has 3 chips and the starting triple is (0, 1, 2).

final trajectoryPaintFinder = find.byWidgetPredicate(
  (widget) => widget is CustomPaint && widget.painter is TrajectoryPainter,
  description: 'CustomPaint with TrajectoryPainter',
);

/// The painter as it is right now (a fresh snapshot after every pump).
TrajectoryPainter currentPainter(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(trajectoryPaintFinder);
  return customPaint.painter! as TrajectoryPainter;
}

/// The triple stored in the provider, read from the screen's container.
ViewAxes currentAxes(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(AttractorScreen)),
  );
  return container.read(viewAxesProvider);
}

/// Taps the settings button and waits for the sheet to slide in.
Future<void> openSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
}

/// The chip with [variable] in the row labelled [rowLabel].
///
/// Every row contains the same variable names, so `find.text('x')` alone
/// would match three widgets. We first find the nearest Row around the label
/// (ancestors are listed from the closest one, hence `.first`), then look for
/// the chip inside that row only.
Finder chipIn(String rowLabel, String variable) {
  final row = find
      .ancestor(of: find.text(rowLabel), matching: find.byType(Row))
      .first;
  return find.descendant(
    of: row,
    matching: find.widgetWithText(ChoiceChip, variable),
  );
}

bool isChipSelected(WidgetTester tester, String rowLabel, String variable) {
  return tester.widget<ChoiceChip>(chipIn(rowLabel, variable)).selected;
}

Future<void> tapChip(
  WidgetTester tester,
  String rowLabel,
  String variable,
) async {
  await tester.tap(chipIn(rowLabel, variable));
  // The new triple is a new key of the scene family: one frame of loading,
  // then the scene arrives. pumpAndSettle covers both (and the chip animation).
  await tester.pumpAndSettle();
}

void main() {
  group('axes bottom sheet', () {
    testWidgets(
      'settings button opens the sheet with a chip per variable and axis',
      (tester) async {
        await pumpApp(tester);
        await openSheet(tester);

        expect(
          find.text('Select the triplet of axes to display the plot'),
          findsOneWidget,
        );
        // 3 rows (width, depth, height) x 3 Lorenz variables.
        expect(find.byType(ChoiceChip), findsNWidgets(9));
        // The default triple (0, 1, 2) is highlighted.
        expect(isChipSelected(tester, 'Width', 'x'), isTrue);
        expect(isChipSelected(tester, 'depth', 'y'), isTrue);
        expect(isChipSelected(tester, 'height', 'z'), isTrue);
      },
    );

    testWidgets('height <- x swaps x and z: provider, painter and chips agree', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSheet(tester);

      await tapChip(tester, 'height', 'x');

      // (0, 1, 2): x is on axis 1, so it moves to axis 3 and z goes to axis 1.
      expect(currentAxes(tester), equals((axis1: 2, axis2: 1, axis3: 0)));

      final painter = currentPainter(tester);
      expect(painter.xindex, 2);
      expect(painter.yindex, 1);
      expect(painter.zindex, 0);

      // The sheet is still open and must show the new triple, not the old one.
      expect(isChipSelected(tester, 'Width', 'z'), isTrue);
      expect(isChipSelected(tester, 'height', 'x'), isTrue);
      expect(isChipSelected(tester, 'height', 'z'), isFalse);
    });

    testWidgets(
      'two taps in one open sheet: the second starts from the first',
      (tester) async {
        // Regression test: the sheet used to compute every swap from the triple
        // captured when it was opened, so the second tap undid the first one.
        await pumpApp(tester);
        await openSheet(tester);

        await tapChip(tester, 'Width', 'z'); // (0, 1, 2) -> (2, 1, 0)
        await tapChip(tester, 'depth', 'x'); // (2, 1, 0) -> (2, 0, 1)

        // With the stale triple the second swap would give (1, 0, 2).
        expect(currentAxes(tester), equals((axis1: 2, axis2: 0, axis3: 1)));
      },
    );

    testWidgets('changing the triple resets the camera', (tester) async {
      await pumpApp(tester);

      await tester.drag(trajectoryPaintFinder, const Offset(100.0, 0.0));
      await tester.pump();
      expect(currentPainter(tester).camera.yaw, greaterThan(0.0));

      await openSheet(tester);
      await tapChip(tester, 'Width', 'y'); // (0, 1, 2) -> (1, 0, 2)

      expect(currentAxes(tester), equals((axis1: 1, axis2: 0, axis3: 2)));
      expect(currentPainter(tester).camera, equals((yaw: 0.0, pitch: 0.0)));
    });
  });
}
