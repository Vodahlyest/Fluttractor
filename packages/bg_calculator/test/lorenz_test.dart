import 'package:test/test.dart';

import 'dart:math';

import 'package:bg_calculator/bg_calculator.dart';

void main() {
  late List<double> derivatives;
  setUp(() {
    derivatives = [0.0, 0.0, 0.0];
  });
  group("system's integrity test", () {
    test("general test of the system", () {
      expect(lorenz.dimension, equals(3));
      expect(lorenz.variableNames, equals(['x', 'y', 'z']));
      expect(lorenz.parameterNames, equals(['sigma', 'rho', 'beta']));
      expect(lorenz.parameters, equals([10, 28, 8 / 3]));
      expect(lorenz.rhs, same(lorenzRhs));
    });
    test("testing the differentiation at a point", () {
      lorenzRhs(0, [1.1, 2.0, 7.0], lorenz.parameters, derivatives);
      expect(derivatives[0], closeTo(9, 1e-12));
      expect(derivatives[1], closeTo(21.1, 1e-12));
      // x·y − β·z = 1.1·2 − (8/3)·7 = −247/15
      expect(derivatives[2], closeTo(-247 / 15, 1e-12));
    });
    test("motionless points", () {
      final cPlus = <double>[
        1 * sqrt(8 / 3 * (28 - 1)),
        1 * sqrt(8 / 3 * (28 - 1)),
        28 - 1,
      ];
      final cMinus = <double>[
        -1 * sqrt(8 / 3 * (28 - 1)),
        -1 * sqrt(8 / 3 * (28 - 1)),
        28 - 1,
      ];

      lorenzRhs(0, cPlus, lorenz.parameters, derivatives);
      expect(derivatives[0], closeTo(0, 1e-10));
      expect(derivatives[1], closeTo(0, 1e-10));
      expect(derivatives[2], closeTo(0, 1e-10));
      derivatives = [0.0, 0.0, 0.0];
      lorenzRhs(0, cMinus, lorenz.parameters, derivatives);
      expect(derivatives[0], closeTo(0, 1e-10));
      expect(derivatives[1], closeTo(0, 1e-10));
      expect(derivatives[2], closeTo(0, 1e-10));
    });
    test("symmetry test", () {
      final testPoint = [5.0, 4.0, 32.0];
      final reflectedPoint = [-5.0, -4.0, 32.0];
      final reflectedDerivatives = [0.0, 0.0, 0.0];
      lorenzRhs(0, testPoint, lorenz.parameters, derivatives);
      lorenzRhs(0, reflectedPoint, lorenz.parameters, reflectedDerivatives);
      expect(reflectedDerivatives[2], equals(derivatives[2]));
      expect(reflectedDerivatives[0], equals(-(derivatives[0])));
      expect(reflectedDerivatives[1], equals(-(derivatives[1])));
    });
    test("parameters are set by p, not by RightSide", () {
      final newLorenz = lorenz.withParameters([10, 99, 8 / 3]);
      final cPlus = <double>[
        1 * sqrt(newLorenz.parameters[2] * (newLorenz.parameters[1] - 1)),
        1 * sqrt(newLorenz.parameters[2] * (newLorenz.parameters[1] - 1)),
        newLorenz.parameters[1] - 1,
      ];
      final cMinus = <double>[
        -1 * sqrt(newLorenz.parameters[2] * (newLorenz.parameters[1] - 1)),
        -1 * sqrt(newLorenz.parameters[2] * (newLorenz.parameters[1] - 1)),
        newLorenz.parameters[1] - 1,
      ];

      lorenzRhs(0, cPlus, newLorenz.parameters, derivatives);
      expect(derivatives[0], closeTo(0, 1e-10));
      expect(derivatives[1], closeTo(0, 1e-10));
      expect(derivatives[2], closeTo(0, 1e-10));
      derivatives = [0.0, 0.0, 0.0];
      lorenzRhs(0, cMinus, newLorenz.parameters, derivatives);
      expect(derivatives[0], closeTo(0, 1e-10));
      expect(derivatives[1], closeTo(0, 1e-10));
      expect(derivatives[2], closeTo(0, 1e-10));
    });
  });
}
