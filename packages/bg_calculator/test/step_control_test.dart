import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:bg_calculator/src/step_control.dart';

void main() {
  group("norm tests", () {
    test("errorEstimate == 0", () {
      expect(
        errorNorm(
          Float64List.fromList([0.0, 0.0]),
          Float64List.fromList([0.0, 2.0]),
          Float64List.fromList([0.0, 0.0]),
          0.5,
          0.4,
        ),
        equals(0),
      );
    });
    test("atol work test", () {
      expect(
        errorNorm(
          Float64List.fromList([0.0, 0.0]),
          Float64List.fromList([0.0, 0.0]),
          Float64List.fromList([0.1, 0.1]),
          0.0,
          0.1,
        ),
        equals(1),
      );
    });
    test("rtol work test", () {
      expect(
        errorNorm(
          Float64List.fromList([100.0, 100.0]),
          Float64List.fromList([100.0, 100.0]),
          Float64List.fromList([0.1, 0.1]),
          1e-3,
          1e-12,
        ),
        closeTo(1, 1e-9),
      );
    });
    test("abs and max() are taken into account", () {
      expect(
        errorNorm(
          Float64List.fromList([-100.0, -100.0]),
          Float64List.fromList([50.0, 50.0]),
          Float64List.fromList([0.1, 0.1]),
          1e-3,
          1e-12,
        ),
        closeTo(1, 1e-9),
      );
    });
    test("average, not the summ", () {
      expect(
        errorNorm(
          Float64List.fromList([0.0, 0.0]),
          Float64List.fromList([0.0, 0.0]),
          Float64List.fromList([1e-12, 1e-12]),
          1e-3,
          1e-12,
        ),
        equals(1),
      );
    });
    test("linearity test", () {
      final err1 = errorNorm(
        Float64List.fromList([-100.0, -100.0]),
        Float64List.fromList([50.0, 50.0]),
        Float64List.fromList([0.1, 0.1]),
        1e-3,
        1e-12,
      );
      final err2 = errorNorm(
        Float64List.fromList([-100.0, -100.0]),
        Float64List.fromList([50.0, 50.0]),
        Float64List.fromList([0.2, 0.2]),
        1e-3,
        1e-12,
      );
      expect(err2 / err1, equals(2));
    });
    test("sign test", () {
      final err1 = errorNorm(
        Float64List.fromList([-100.0, -100.0]),
        Float64List.fromList([50.0, 50.0]),
        Float64List.fromList([0.1, 0.1]),
        1e-3,
        1e-12,
      );
      final err2 = errorNorm(
        Float64List.fromList([-100.0, -100.0]),
        Float64List.fromList([50.0, 50.0]),
        Float64List.fromList([-0.1, 0.1]),
        1e-3,
        1e-12,
      );
      expect(err1, equals(err2));
    });
    test("combined example", () {
      expect(
        errorNorm(
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1e-6, 1e-6]),
          1e-3,
          1e-6,
        ),
        closeTo(0.7071071340338025, 1e-12),
      );
    });
    test("errors test", () {
      expect(
        () => errorNorm(
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1e-6, 1e-6]),
          1e-3,
          0,
        ),
        throwsArgumentError,
      );
      expect(
        () => errorNorm(
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1e-6, 1e-6]),
          -(1e-3),
          1,
        ),
        throwsArgumentError,
      );
      expect(
        () => errorNorm(
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1.0, 0.0]),
          Float64List.fromList([1e-6, 1e-6]),
          1e-3,
          double.nan,
        ),
        throwsArgumentError,
      );
    });
  });
  group("multiplier tests", () {
    const qOrder = 4;
    test("err == 1e-6", () {
      expect(stepMultiplier(1e-6, qOrder), closeTo(5.0, 1e-12));
    });
    test("err == 0.3", () {
      expect(stepMultiplier(0.3, qOrder), closeTo(1.1450336728854529, 1e-12));
    });
    test("err == 1.0", () {
      expect(stepMultiplier(1.0, qOrder), closeTo(0.9, 1e-12));
    });
    test("err == 4", () {
      expect(stepMultiplier(4, qOrder), closeTo(0.6820724549296792, 1e-12));
    });
    test("err == 10^4", () {
      expect(stepMultiplier(1e4, qOrder), closeTo(0.2, 1e-12));
    });
    test("err == 0", () {
      expect(stepMultiplier(0, qOrder), closeTo(5.0, 1e-12));
      expect(stepMultiplier(0, qOrder), isNot(equals(double.nan)));
      expect(stepMultiplier(0, qOrder), isNot(equals(double.infinity)));
    });
    test("err == 1e-6, facMax = 1.0", () {
      expect(stepMultiplier(1e-6, qOrder, facMax: 1.0), closeTo(1.0, 1e-12));
    });
    test("err == 0.3 with q == 2", () {
      expect(stepMultiplier(0.3, 2), closeTo(1.3444214239671495, 1e-12));
    });
    test("NaN and infinity => facMin", () {
      expect(stepMultiplier(double.nan, qOrder), closeTo(0.2, 1e-12));
      expect(stepMultiplier(double.infinity, qOrder), closeTo(0.2, 1e-12));
    });
  });
}
