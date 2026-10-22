import 'dart:typed_data';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/calculations/scene.dart';

void main() {
  final stepper = Rk4(system: lorenz);
  final initialState = Float64List.fromList([1.0, 1.0, 1.0]);
  const t0 = 0.0;
  const tEnd = 0.1;
  const stepSize = 0.01;
  test("Wrong indices return error from the isolate", () async {
    await expectLater(
      computeSceneInIsolate(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
        xIndex: 0,
        yIndex: 1,
        zIndex: 3,
      ),
      throwsStateError,
    );
  });
  test(
    "result from an isolate is the same as the result from the main event loop",
    () async {
      final expectedScene = computeScene(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
        xIndex: 0,
        yIndex: 1,
        zIndex: 2,
      );
      final testScene = await computeSceneInIsolate(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
        xIndex: 0,
        yIndex: 1,
        zIndex: 2,
      );
      expect(
        testScene.trajectory.dimension,
        equals(expectedScene.trajectory.dimension),
      );
      expect(
        testScene.trajectory.points,
        equals(expectedScene.trajectory.points),
      );
      expect(
        testScene.trajectory.time,
        orderedEquals(expectedScene.trajectory.time),
      );
      expect(
        testScene.trajectory.states,
        orderedEquals(expectedScene.trajectory.states),
      );
      expect(testScene.sphere, equals(expectedScene.sphere));
    },
  );
}
