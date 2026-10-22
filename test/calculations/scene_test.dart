import 'dart:typed_data';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/calculations/scene.dart';
import 'package:fluttractor/calculations/bounding_sphere.dart';

void main() {
  final stepper = Rk4(system: lorenz);
  final initialState = Float64List.fromList([1.0, 1.0, 1.0]);
  const t0 = 0.0;
  const tEnd = 0.1;
  const stepSize = 0.01;

  test('returns the direct integration and bounding sphere results', () {
    final expectedTrajectory = integrate(
      stepper,
      initialState,
      t0,
      tEnd,
      stepSize,
    );
    final expectedSphere = boundingSphere(expectedTrajectory, 2, 0, 1);

    final scene = computeScene(
      stepper: stepper,
      y0: initialState,
      t0: t0,
      tEnd: tEnd,
      h: stepSize,
      xIndex: 2,
      yIndex: 0,
      zIndex: 1,
    );

    expect(scene.trajectory.dimension, expectedTrajectory.dimension);
    expect(scene.trajectory.points, expectedTrajectory.points);
    expect(scene.trajectory.time, orderedEquals(expectedTrajectory.time));
    expect(scene.trajectory.states, orderedEquals(expectedTrajectory.states));
    expect(scene.sphere, expectedSphere);
  });

  test("computeScene actually uses passed indices for sphere", () {
    final expectedTrajectory = integrate(
      stepper,
      initialState,
      t0,
      tEnd,
      stepSize,
    );
    final expectedSphere = boundingSphere(expectedTrajectory, 2, 0, 1);
    final scene = computeScene(
      stepper: stepper,
      y0: initialState,
      t0: t0,
      tEnd: tEnd,
      h: stepSize,
      xIndex: 0,
      yIndex: 1,
      zIndex: 2,
    );
    expect(expectedSphere, isNot(equals(scene.sphere)));
  });
}
