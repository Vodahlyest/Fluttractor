import 'dart:typed_data';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/calculations/scene.dart';
import 'package:fluttractor/constant_values/indices.dart';

final sceneProvider = FutureProvider<Scene>(
  retry: (retryCount, error) => null,
  (ref) {
    return computeSceneInIsolate(
      stepper: Rk4(system: lorenz),
      y0: Float64List.fromList([1.0, 1.0, 1.0]),
      t0: 0,
      tEnd: 50,
      h: 0.01,
      xIndex: defaultAxes.x,
      yIndex: defaultAxes.y,
      zIndex: defaultAxes.z,
    );
  },
);
