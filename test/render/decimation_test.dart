import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/render/decimation.dart';

void main() {
  test("nothing to exclude -> returned array is the same length", () {
    final testProjection = Float32List.fromList([0, 0, 5, 0, 10, 0]);
    final decimated = decimate(testProjection);
    expect(decimated.length, equals(6));
  });
  test("decimation works, first and last point remains", () {
    final testProjection = Float32List.fromList([0, 0, 0.1, 0, 0.2, 0, 0.3, 0]);
    final decimated = decimate(testProjection);
    final expectedDecimation = Float32List.fromList([0.0, 0.0, 0.3, 0.0]);
    expect(decimated.length, equals(expectedDecimation.length));
    for (int i = 0; i < decimated.length; i++) {
      expect(decimated[i], closeTo(expectedDecimation[i], 1e-12));
    }
  });
  test("comparison with the last saved point works as it should", () {
    final testProjection = Float32List.fromList([
      0,
      0,
      0.4,
      0,
      0.8,
      0,
      1.2,
      0,
      1.6,
      0,
      2.0,
      0,
      2.4,
      0,
    ]);
    final decimated = decimate(testProjection);
    final expectedDecimation = Float32List.fromList([
      0.0,
      0.0,
      1.2,
      0.0,
      2.4,
      0.0,
    ]);
    expect(decimated.length, equals(expectedDecimation.length));
    for (int i = 0; i < decimated.length; i++) {
      expect(decimated[i], closeTo(expectedDecimation[i], 1e-12));
    }
  });
  test("empty input and 1-point input", () {
    final testInput1 = Float32List.fromList([]);
    final testInput2 = Float32List.fromList([1.0, 2.0]);
    final decimation1 = decimate(testInput1);
    final decimation2 = decimate(testInput2);
    expect(testInput1, equals(decimation1));
    expect(testInput2, equals(decimation2));
  });
  test("last point remains even if smaller that the margin", () {
    final testProjection = Float32List.fromList([0, 0, 5, 0, 5.3, 0]);
    final decimated = decimate(testProjection);
    expect(decimated.length, equals(testProjection.length));
    for (int i = 0; i < testProjection.length; i++) {
      expect(testProjection[i], closeTo(decimated[i], 1e-12));
    }
  });
  test("one of the distances is equal to the margin", () {
    final testProjection = Float32List.fromList([0.0, 0.0, 1.0, 0.0, 2.0, 0.0]);
    final decimated = decimate(testProjection);
    final expectedDecimation = Float32List.fromList([
      0.0,
      0.0,
      1.0,
      0.0,
      2.0,
      0.0,
    ]);
    expect(decimated.length, equals(expectedDecimation.length));
    for (int i = 0; i < testProjection.length; i++) {
      expect(decimated[i], closeTo(expectedDecimation[i], 1e-12));
    }
  });
  test("no errors in distance calculations, w/ respect to Y", () {
    final testProjection = Float32List.fromList([
      0.0,
      0.0,
      0.0,
      0.5,
      0.0,
      1.5,
      0.0,
      3.0,
    ]);
    final decimated = decimate(testProjection);
    final expectedDecimation = Float32List.fromList([
      0.0,
      0.0,
      0.0,
      1.5,
      0.0,
      3.0,
    ]);
    expect(decimated.length, equals(expectedDecimation.length));
    for (int i = 0; i < decimated.length; i++) {
      expect(decimated[i], closeTo(expectedDecimation[i], 1e-12));
    }
  });
  test("different margin still works", () {
    final testProjection = Float32List.fromList([
      0.0,
      0.0,
      1.5,
      0.0,
      3.0,
      0.0,
      10.0,
      0.0,
    ]);
    final decimated = decimate(testProjection, minDistance: 2);
    final expectedDecimation = Float32List.fromList([
      0.0,
      0.0,
      3.0,
      0.0,
      10.0,
      0.0,
    ]);
    expect(decimated.length, equals(expectedDecimation.length));
    for (int i = 0; i < decimated.length; i++) {
      expect(decimated[i], closeTo(expectedDecimation[i], 1e-12));
    }
  });
}
