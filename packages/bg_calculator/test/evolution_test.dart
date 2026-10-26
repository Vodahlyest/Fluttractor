import 'dart:typed_data';

import 'helpers/hos_init.dart';

import 'package:test/test.dart';
import 'package:bg_calculator/bg_calculator.dart';

void main() {
  late Stepper stepper;
  late Float64List y0;
  setUp(() {
    stepper = Rk4(system: lorenz);
    y0 = Float64List.fromList([1.0, 1.0, 1.0]);
  });
  test("evolution == integrate , same t interval", () {
    final testTrajectory = integrate(stepper, y0, 0, 1, 0.3);
    final testEvolution = evolve(stepper, y0, 0, 1, 0.3);
    expect(testTrajectory.stateAt(4), equals(testEvolution));
  });
  test("integrate from t1 compared to integrate from t0", () {
    final hosStepper = Rk4(system: systemInit([1.0, 2.0]));
    final hosY0 = Float64List.fromList([0.0, 1.0]);
    final testEvolution = evolve(hosStepper, hosY0, 0, 1, 1 / 64);
    final integrateT0 = integrate(hosStepper, hosY0, 0, 2, 1 / 64);
    final integrateT1 = integrate(hosStepper, testEvolution, 1, 2, 1 / 64);
    expect(
      integrateT1.states[integrateT1.states.length - 1],
      closeTo(integrateT0.states[integrateT0.states.length - 1], 1e-9),
    );
    expect(
      integrateT1.states[integrateT1.states.length - 2],
      closeTo(integrateT0.states[integrateT0.states.length - 2], 1e-9),
    );
  });
  test("tStart == tEnd test", () {
    final testEvolution = evolve(stepper, y0, 0, 0, 0.3);
    expect(testEvolution, equals(y0));
    expect(testEvolution, isNot(same(y0)));
  });
  test("y0 actually doesn't change at all", () {
    final y0Copy = Float64List.fromList(y0);
    final testEvolution = evolve(stepper, y0, 0, 1, 0.3);
    expect(testEvolution, isNot(equals(y0)));
    expect(y0Copy, equals(y0));
  });
  test("tEnd < tStart, throws ArgumentError", () {
    expect(() => evolve(stepper, y0, 1, 0, 0.3), throwsArgumentError);
  });
  test("h <= 0, throws ArgumentError", () {
    expect(() => evolve(stepper, y0, 0, 1, 0.0), throwsArgumentError);
    expect(() => evolve(stepper, y0, 0, 1, -0.5), throwsArgumentError);
  });
}
