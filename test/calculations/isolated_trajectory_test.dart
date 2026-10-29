import 'dart:typed_data';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/calculations/compute_trajectory.dart';

void main() {
  final stepper = Rk4(system: lorenz);
  final initialState = Float64List.fromList([1.0, 1.0, 1.0]);
  const t0 = 0.0;
  const tEnd = 0.1;
  const stepSize = 0.01;
  test("Wrong skip time throws state error", () async {
    await expectLater(
      computeTrajectoryInIsolate(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
        skipTime: 5.0,
      ),
      throwsArgumentError,
    );
  });
  test(
    "result from an isolate is the same as the result from the main event loop",
    () async {
      final expectedTrajectory = computeTrajectory(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
      );
      final testTrajectory = await computeTrajectoryInIsolate(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
      );
      expect(testTrajectory.dimension, equals(expectedTrajectory.dimension));
      expect(testTrajectory.points, equals(expectedTrajectory.points));
      expect(testTrajectory.time, orderedEquals(expectedTrajectory.time));
      expect(testTrajectory.states, orderedEquals(expectedTrajectory.states));
    },
  );
}
