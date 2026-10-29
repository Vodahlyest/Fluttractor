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

  test('returns the direct integration result', () {
    final expectedTrajectory = integrate(
      stepper,
      initialState,
      t0,
      tEnd,
      stepSize,
    );

    final trajectory = computeTrajectory(
      stepper: stepper,
      y0: initialState,
      t0: t0,
      tEnd: tEnd,
      h: stepSize,
    );

    expect(trajectory.dimension, expectedTrajectory.dimension);
    expect(trajectory.points, expectedTrajectory.points);
    expect(trajectory.time, orderedEquals(expectedTrajectory.time));
    expect(trajectory.states, orderedEquals(expectedTrajectory.states));
  });
  test("manual calculations and computeTrajectory = same result", () {
    final evolution = evolve(stepper, initialState, t0, t0 + 0.01, stepSize);
    final expectedTrajectory = integrate(
      stepper,
      evolution,
      t0 + 0.01,
      tEnd,
      stepSize,
    );
    final trajectory = computeTrajectory(
      stepper: stepper,
      y0: initialState,
      t0: t0,
      tEnd: tEnd,
      h: stepSize,
      skipTime: 0.01,
    );
    expect(trajectory.states, equals(expectedTrajectory.states));
  });
  test("first point is at t0 + skipTime", () {
    final trajectory = computeTrajectory(
      stepper: stepper,
      y0: initialState,
      t0: t0,
      tEnd: tEnd,
      h: stepSize,
      skipTime: 0.01,
    );
    expect(trajectory.time[0], equals(t0 + 0.01));
  });
  test("skipTime >= t interval -> ArgumentError", () {
    expect(
      () => computeTrajectory(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
        skipTime: 5,
      ),
      throwsArgumentError,
    );
    expect(
      () => computeTrajectory(
        stepper: stepper,
        y0: initialState,
        t0: t0,
        tEnd: tEnd,
        h: stepSize,
        skipTime: 0.1,
      ),
      throwsArgumentError,
    );
  });
}
