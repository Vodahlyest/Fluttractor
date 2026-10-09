import 'package:test/test.dart';

import 'dart:typed_data';

import "package:bg_calculator/bg_calculator.dart";

import 'helpers/hos_init.dart';

void main() {
  test("euler's method accuracy test, F=0", () {
    final hos = systemInit([2.0, 0.0]);
    final stepper = ExplicitEuler(system: hos);
    final state = Float64List.fromList([2.0, -3.0]);
    final h = 0.1;
    final t = 0.0;
    stepper.step(t, state, h);
    expect(state[0], closeTo(1.7, 1e-12));
    expect(state[1], closeTo(-3.8, 1e-12));
  });
  test("euler's method accuracy test, F=5.0", () {
    final hos = systemInit([2.0, 5.0]);
    final stepper = ExplicitEuler(system: hos);
    final state = Float64List.fromList([2.0, -3.0]);
    final h = 0.1;
    final t = 0.5;
    stepper.step(t, state, h);
    expect(state[0], closeTo(1.7, 1e-12));
    expect(state[1], closeTo(-3.55, 1e-12));
  });
  test("wrong y length -> assertion error", () {
    final hos = systemInit([2.0, 5.0]);
    final stepper = ExplicitEuler(system: hos);
    final state = Float64List.fromList([2.0]);
    final h = 0.1;
    final t = 0.5;
    expect(() => stepper.step(t, state, h), throwsA(isA<AssertionError>()));
  });
  test("euler's order getter returns 1", () {
    final hos = systemInit([2.0, 5.0]);
    final stepper = ExplicitEuler(system: hos);
    expect(stepper.order, equals(1));
  });
}
