import 'trajectory.dart';
import 'steppers/stepper.dart';

import 'dart:typed_data';

Trajectory integrate(
  Stepper stepper,
  Float64List y0,
  double t0,
  double tEnd,
  double h,
) {
  final dimension = stepper.system.dimension;
  final points = ((tEnd - t0) / h).ceil() + 1;
  final steps = ((tEnd - t0) / h).ceil();
  final hPrime = (tEnd - t0) / steps;
  final y = Float64List.fromList(y0);
  final result = Trajectory(dimension: dimension, points: points);
  result.time[0] = t0;
  result.states.setRange(0, dimension, y);
  for (int i = 0; i < steps; i++) {
    stepper.step(t0 + (i * hPrime), y, hPrime);
    result.time[i + 1] = t0 + ((i + 1) * hPrime);
    result.states.setRange((i + 1) * dimension, (i + 2) * dimension, y);
  }
  return result;
}
