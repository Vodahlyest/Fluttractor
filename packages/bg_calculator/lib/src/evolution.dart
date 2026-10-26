import 'dart:typed_data';

import 'steppers/stepper.dart';

/// returns a new state vector at tEnd, from the initial condition
///
/// Function returns a new array, not modifying the passed initial
/// condition
/// Uses the same logic as in integrate function, so the result
/// is the same as the last state from integrate on the same
/// time interval
/// If [tStart] == [tEnd], returns the copy of [y0]
/// May throw ArgumentError if wrong values [tStart], [tEnd] and
/// [h] are passed
///
/// [stepper] method of integration
/// [y0] initial condition
/// [tStart], [tEnd] time interval
/// [h] desired integration step
Float64List evolve(
  Stepper stepper,
  Float64List y0,
  double tStart,
  double tEnd,
  double h,
) {
  if (tEnd < tStart) {
    throw ArgumentError(
      "passed interval should be >= 0: tStart = $tStart, tEnd = $tEnd",
    );
  }

  if (h <= 0) {
    throw ArgumentError("desired step should be strictly positive: h = $h");
  }
  int steps = ((tEnd - tStart) / h).ceil();
  double hPrime = (tEnd - tStart) / steps;
  Float64List y = Float64List.fromList(y0);
  for (int i = 0; i < steps; i++) {
    stepper.step(tStart + (i * hPrime), y, hPrime);
  }

  return y;
}
