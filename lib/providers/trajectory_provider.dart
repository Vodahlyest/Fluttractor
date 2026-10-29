import 'dart:typed_data';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/calculations/compute_trajectory.dart';
import 'package:fluttractor/providers/system_provider.dart';

final trajectoryProvider = FutureProvider<Trajectory>(
  retry: (retryCount, error) => null,
  (ref) {
    return computeTrajectoryInIsolate(
      stepper: Rk4(system: ref.watch(systemProvider)),
      y0: Float64List.fromList([-10.0, -6.0, 0.0, 10]),
      t0: 0,
      tEnd: 200,
      h: 0.01,
    );
  },
);
