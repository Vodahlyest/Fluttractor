import 'dart:async';
import 'dart:typed_data';

import 'package:fluttractor/constant_values/indices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/calculations/scene.dart';
import 'package:fluttractor/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'package:fluttractor/providers/scene_provider.dart';

final sceneByDefault = computeScene(
  stepper: Rk4(system: lorenz),
  y0: Float64List.fromList([1.0, 1.0, 1.0]),
  t0: 0,
  tEnd: 1,
  h: 0.01,
  xIndex: defaultAxes.x,
  yIndex: defaultAxes.y,
  zIndex: defaultAxes.z,
);

Future<void> pumpApp(WidgetTester tester, [FutureOr<Scene>? testScene]) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        sceneProvider.overrideWith((ref) => testScene ?? sceneByDefault),
      ],
      child: const MyApp(),
    ),
  );
}
