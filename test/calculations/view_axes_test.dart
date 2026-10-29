import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/calculations/view_axes.dart';

void main() {
  test("validity check", () {
    final ViewAxes testTriplet = (axis1: 0, axis2: 1, axis3: 2);
    final ViewAxes testTriplet2 = (axis1: 0, axis2: 1, axis3: 3);
    expect(() => checkAxes(testTriplet, 3), returnsNormally);
    expect(() => checkAxes(testTriplet2, 4), returnsNormally);
  });
  test("index equal to dimension throws argument error", () {
    //3d triplet
    final ViewAxes testTriplet1 = (axis1: 0, axis2: 3, axis3: 2);
    //4d triplet
    final ViewAxes testTriplet2 = (axis1: 4, axis2: 1, axis3: 3);
    expect(() => checkAxes(testTriplet1, 3), throwsArgumentError);
    expect(() => checkAxes(testTriplet2, 4), throwsArgumentError);
  });
  test("negative index throws argument error", () {
    //3d triplet
    final ViewAxes testTriplet1 = (axis1: -2, axis2: 1, axis3: 2);
    //4d triplet
    final ViewAxes testTriplet2 = (axis1: 1, axis2: -2, axis3: 3);
    expect(() => checkAxes(testTriplet1, 3), throwsArgumentError);
    expect(() => checkAxes(testTriplet2, 4), throwsArgumentError);
  });
  test("repeated indices throw argument error", () {
    expect(
      () => checkAxes((axis1: 0, axis2: 0, axis3: 2), 3),
      throwsArgumentError,
    );
    expect(
      () => checkAxes((axis1: 0, axis2: 2, axis3: 0), 3),
      throwsArgumentError,
    );
    expect(
      () => checkAxes((axis1: 0, axis2: 2, axis3: 2), 3),
      throwsArgumentError,
    );
  });
}
