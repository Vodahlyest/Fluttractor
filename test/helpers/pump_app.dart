import 'dart:async';
import 'dart:typed_data';

import 'package:fluttractor/calculations/compute_trajectory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'package:fluttractor/providers/system_provider.dart';
import 'package:fluttractor/providers/trajectory_provider.dart';

final trajectoryByDefault = computeTrajectory(
  stepper: Rk4(system: lorenz),
  y0: Float64List.fromList([1.0, 1.0, 1.0]),
  t0: 0,
  tEnd: 1,
  h: 0.01,
);

Future<void> pumpApp(
  WidgetTester tester, [
  FutureOr<Trajectory>? testTrajectory,
]) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        systemProvider.overrideWithValue(lorenz),
        trajectoryProvider.overrideWith(
          (ref) => testTrajectory ?? trajectoryByDefault,
        ),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pump();
}
