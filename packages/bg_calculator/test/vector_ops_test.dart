import 'package:test/test.dart';

import 'dart:typed_data';

import 'package:bg_calculator/src/vector_ops.dart';

void main() {
  test('axpy operation', () {
    final result1 = Float64List.fromList([0.0, 0.0, 0.0]);
    final result2 = Float64List.fromList([0.0, 0.0, 0.0]);
    axpy(
      Float64List.fromList([1.0, 5.0, -4.0]),
      4.0,
      Float64List.fromList([2.0, -1.0, 3.0]),
      result1,
    );
    axpy(
      Float64List.fromList([3.0, 0.0, 10.0]),
      2.5,
      Float64List.fromList([4.0, 2.0, -6.0]),
      result2,
    );
    expect(result1[0], equals(9.0));
    expect(result1[1], equals(1.0));
    expect(result1[2], equals(8.0));
    expect(result2[0], equals(13.0));
    expect(result2[1], equals(5.0));
    expect(result2[2], equals(-5.0));
  });
  test("scalar = 0, resBuff = yVec", () {
    final result1 = Float64List.fromList([0.0, 0.0, 0.0]);
    axpy(
      Float64List.fromList([3.0, 0.0, 10.0]),
      0.0,
      Float64List.fromList([2.0, -1.0, 3.0]),
      result1,
    );
    expect(result1[0], equals(3.0));
    expect(result1[1], equals(0.0));
    expect(result1[2], equals(10.0));
  });
  test("resBuff = yVec, resBuff = kVec", () {
    final yVec = Float64List.fromList([3.0, -12.0, 5.0]);
    axpy(yVec, 2.0, Float64List.fromList([2.0, -1.0, 3.0]), yVec);
    expect(yVec[0], equals(7.0));
    expect(yVec[1], equals(-14.0));
    expect(yVec[2], equals(11.0));
    final kVec = Float64List.fromList([2.0, -1.0, 3.0]);
    axpy(Float64List.fromList([3.0, 0.0, 10.0]), 2.0, kVec, kVec);
    expect(kVec[0], equals(7.0));
    expect(kVec[1], equals(-2.0));
    expect(kVec[2], equals(16.0));
  });
  test("kVec after function call does not change", () {
    final kVec = Float64List.fromList([2.0, -1.0, 3.0]);
    final originalKVec = Float64List.fromList([2.0, -1.0, 3.0]);
    axpy(
      Float64List.fromList([3.0, 0.0, 10.0]),
      2.0,
      kVec,
      Float64List.fromList([0.0, 0.0, 0.0]),
    );
    expect(kVec, equals(originalKVec));
  });
  test("kVec, yVec and resBuff are equal length. Different length throws assertion error", () {
    expect(
      () => axpy(
        Float64List.fromList([1.0, 5.0, -4.0]),
        4.0,
        Float64List.fromList([2.0, -1.0, 3.0]),
        Float64List.fromList([0.0, 0.0]),
      ),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => axpy(
        Float64List.fromList([1.0, 5.0, -4.0]),
        4.0,
        Float64List.fromList([2.0, -1.0]),
        Float64List.fromList([0.0, 0.0, 0.0]),
      ),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => axpy(
        Float64List.fromList([1.0, 5.0]),
        4.0,
        Float64List.fromList([2.0, -1.0, 3.0]),
        Float64List.fromList([0.0, 0.0, 0.0]),
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
