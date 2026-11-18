import 'package:bg_calculator/src/steppers/dormand_prince_tableau.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'dart:math';

double quadratureSum(List<double> b, List<double> c, int k) {
  double summ = 0;
  for (int i = 0; i < b.length; i++) {
    summ += b[i] * (pow(c[i], k));
  }
  return summ;
}

void main() {
  test("a_i sum = c_i", () {
    for (int i = 0; i < dpA.length; i++) {
      expect(dpA[i].sum, closeTo(dpC[i], 1e-4));
    }
  });
  test("last a_i == b(5)", () {
    for (int i = 0; i < dpA.last.length; i++) {
      expect(dpA.last[i], closeTo(dpB[i], 1e-12));
    }
  });
  group("order test", () {
    test("b is of the order of 5", () {
      for (int k = 0; k < 5; k++) {
        expect(quadratureSum(dpB, dpC, k), closeTo(1 / (k + 1), 1e-12));
      }
    });
    test("bHat is of the order of 4", () {
      for (int k = 0; k < 4; k++) {
        expect(quadratureSum(dpBHat, dpC, k), closeTo(1 / (k + 1), 1e-12));
      }
    });
    test("bHat is not of the order of 5", () {
      expect(quadratureSum(dpBHat, dpC, 4), isNot(closeTo(1 / 5, 1e-12)));
    });
  });
  group("structural tests", () {
    test("coefficients lengths equal to 7", () {
      expect(dpA.length, equals(7));
      expect(dpC.length, equals(7));
      expect(dpB.length, equals(7));
      expect(dpBHat.length, equals(7));
    });
    test("lengths of strings in dpA are equal to their order number", () {
      for (int i = 0; i < dpA.length; i++) {
        expect(dpA[i].length, equals(i));
      }
    });
  });
}
