import 'dart:math';
import 'dart:typed_data';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:test/test.dart';

import 'helpers/hos_init.dart';
import 'helpers/polynomial_helper.dart';
import 'helpers/accurate_solution.dart';

void main() {
  test("y is not modified", () {
    final hos = systemInit([2.0, 0.0]);
    final stepper = DormandPrince5(system: hos);
    final state = Float64List.fromList([2.0, -3.0]);
    final stateCopy = Float64List.fromList(state);
    final newState = Float64List.fromList([0.0, 0.0]);
    final errorEstimate = Float64List.fromList([0.0, 0.0]);
    final h = 0.1;
    final t = 0.0;
    stepper.step(t, state, h, newState, errorEstimate);
    expect(state, equals(stateCopy));
  });
  group("Polynomial tests", () {
    test("yNew consistency", () {
      final poly = polynomialInit();
      final stepper = DormandPrince5(system: poly);
      final state = Float64List.fromList([0.5 * 0.5 * 0.5 * 0.5 * 0.5]);
      final newState = Float64List.fromList([0.0]);
      final errorEstimate = Float64List.fromList([0.0]);
      final t = 0.5;
      final h = 0.1;
      stepper.step(t, state, h, newState, errorEstimate);
      expect(newState[0], closeTo((0.6 * 0.6 * 0.6 * 0.6 * 0.6), 1e-14));
    });
    test("errorEstimate is significantly larger than 0", () {
      final poly = polynomialInit();
      final stepper = DormandPrince5(system: poly);
      final state = Float64List.fromList([0.5 * 0.5 * 0.5 * 0.5 * 0.5]);
      final newState = Float64List.fromList([0.0]);
      final errorEstimate = Float64List.fromList([0.0]);
      final t = 0.5;
      final h = 0.1;
      stepper.step(t, state, h, newState, errorEstimate);
      expect(errorEstimate[0], isNot(closeTo(0.0, 1e-8)));
    });
  });
  test("assertion errors", () {
    final hos = systemInit([2.0, 0.0]);
    final stepper = DormandPrince5(system: hos);
    final state = Float64List.fromList([2.0, -3.0]);
    final newState = Float64List.fromList([0.0, 0.0]);
    final errorEstimate = Float64List.fromList([0.0, 0.0]);
    final fakeNewState = state;
    final fakeErrorEstimate = state;

    expect(
      () => stepper.step(
        0.5,
        Float64List.fromList([2.0, -3.0, 1.0]),
        0.1,
        newState,
        errorEstimate,
      ),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => stepper.step(
        0.5,
        state,
        0.1,
        Float64List.fromList([2.0, -3.0, 1.0]),
        errorEstimate,
      ),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => stepper.step(
        0.5,
        state,
        0.1,
        newState,
        Float64List.fromList([0.0, 0.0, 0.0]),
      ),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => stepper.step(0.5, state, 0.1, fakeNewState, errorEstimate),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => stepper.step(0.5, state, 0.1, newState, fakeErrorEstimate),
      throwsA(isA<AssertionError>()),
    );
  });
  test("order test through step decrement", () {
    final system = systemInit([2.0, 0.0]);
    final stepper = DormandPrince5(system: system);
    final t = 0.0;
    final y = Float64List.fromList([2.0, -3.0]);
    Float64List yNew1 = Float64List.fromList([0.0, 0.0]);
    Float64List errorEstimate1 = Float64List.fromList([0.0, 0.0]);
    Float64List yNew2 = Float64List.fromList([0.0, 0.0]);
    Float64List errorEstimate2 = Float64List.fromList([0.0, 0.0]);
    final h1 = 0.2;
    final h2 = 0.1;
    final correctSolution1 = correctSolution(y, system, h1);
    stepper.step(t, y, h1, yNew1, errorEstimate1);
    final correctSolution2 = correctSolution(y, system, h2);
    stepper.step(t, y, h2, yNew2, errorEstimate2);
    final solErr1 = [
      yNew1[0] - correctSolution1[0],
      yNew1[1] - correctSolution1[1],
    ];
    final solErrLength1 = sqrt(
      (solErr1[0] * solErr1[0]) + (solErr1[1] * solErr1[1]),
    );
    final estSize1 = sqrt(
      (errorEstimate1[0] * errorEstimate1[0]) +
          (errorEstimate1[1] * errorEstimate1[1]),
    );
    final solErr2 = [
      yNew2[0] - correctSolution2[0],
      yNew2[1] - correctSolution2[1],
    ];
    final solErrLength2 = sqrt(
      (solErr2[0] * solErr2[0]) + (solErr2[1] * solErr2[1]),
    );
    final estSize2 = sqrt(
      (errorEstimate2[0] * errorEstimate2[0]) +
          (errorEstimate2[1] * errorEstimate2[1]),
    );

    final solutionOrder = log(solErrLength1 / solErrLength2) / ln2;
    final estimateOrder = log(estSize1 / estSize2) / ln2;

    expect(solutionOrder, closeTo(6, 0.3));
    expect(estimateOrder, closeTo(5, 0.3));
  });
}
