import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/calculations/bounding_sphere.dart';
import 'package:fluttractor/calculations/compute_trajectory.dart';
import 'package:fluttractor/providers/scene_provider.dart';
import 'package:fluttractor/calculations/view_axes.dart';
import 'package:fluttractor/providers/system_provider.dart';
import 'package:fluttractor/providers/trajectory_provider.dart';
import 'package:bg_calculator/bg_calculator.dart';

void main() {
  test('scene builds right', () async {
    final expectedTrajectory = computeTrajectory(
      stepper: Rk4(system: lorenz),
      y0: Float64List.fromList([1.0, 1.0, 1.0]),
      t0: 0,
      tEnd: 1,
      h: 0.01,
    );
    ViewAxes testAxes = (axis1: 2, axis2: 0, axis3: 1);
    final container = ProviderContainer.test(
      overrides: [
        systemProvider.overrideWithValue(lorenz),
        trajectoryProvider.overrideWith((ref) => expectedTrajectory),
      ],
    );

    final testScene = await container.read(sceneProvider(testAxes).future);

    expect(testScene.trajectory, same(expectedTrajectory));
    expect(
      testScene.sphere,
      equals(
        boundingSphere(
          expectedTrajectory,
          testAxes.axis1,
          testAxes.axis2,
          testAxes.axis3,
        ),
      ),
    );
  });
  test("trajectory is calculated once", () async {
    int counter = 0;
    final container = ProviderContainer.test(
      overrides: [
        trajectoryProvider.overrideWith((ref) {
          counter++;
          return computeTrajectory(
            stepper: Rk4(system: lorenz),
            y0: Float64List.fromList([1.0, 1.0, 1.0]),
            t0: 0,
            tEnd: 1,
            h: 0.01,
          );
        }),
      ],
    );
    final testScene1 = await container.read(
      sceneProvider((axis1: 0, axis2: 1, axis3: 2)).future,
    );
    final testScene2 = await container.read(
      sceneProvider((axis1: 2, axis2: 0, axis3: 1)).future,
    );
    expect(counter, equals(1));
    expect(testScene1.trajectory, same(testScene2.trajectory));
  });
}
