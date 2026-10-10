import 'dart:typed_data';
import 'dart:math';

import 'package:bg_calculator/bg_calculator.dart';

List<double> correctSolution(
  Float64List y0,
  OdeSystem system,
  double timePoint,
) {
  final x_t = y0[0] * cos(system.parameters[0] * timePoint) + (y0[1] / system.parameters[0]) * sin(system.parameters[0] * timePoint);
  final v_t = y0[1] * cos(system.parameters[0] * timePoint) - y0[0] * system.parameters[0] * sin(system.parameters[0] * timePoint);
  return <double>[x_t, v_t];
}
