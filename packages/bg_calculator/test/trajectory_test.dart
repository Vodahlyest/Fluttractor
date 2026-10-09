import 'package:bg_calculator/bg_calculator.dart';
import 'package:test/test.dart';

void main() {
  test("main test, Model's integrity", () {
    final testTrajectory = Trajectory(dimension: 3, points: 5);
    expect(testTrajectory.dimension, equals(3));
    expect(testTrajectory.points, equals(5));
    expect(testTrajectory.time.length, equals(5));
    expect(testTrajectory.states.length, equals(15));
  });
  test("stateAt returns correct view", () {
    final testTrajectory = Trajectory(dimension: 3, points: 5);
    testTrajectory.states.setAll(0, [
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      6.0,
      7.0,
      8.0,
      9.0,
      10.0,
      11.0,
      12.0,
      13.0,
      14.0,
      15.0,
    ]);
    testTrajectory.time.setAll(0, [0.0, 1.0, 2.0, 3.0, 4.0]);
    final stateAt0 = testTrajectory.stateAt(0);
    final stateAt2 = testTrajectory.stateAt(2);
    expect(stateAt2, equals([7.0, 8.0, 9.0]));
    expect(stateAt0, equals([1.0, 2.0, 3.0]));
  });
  test("stateAt returns the view of the original list, not the slice", () {
    final testTrajectory = Trajectory(dimension: 3, points: 3);
    testTrajectory.states.setAll(0, [
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      6.0,
      7.0,
      8.0,
      9.0,
    ]);
    final stateAt2 = testTrajectory.stateAt(2);
    stateAt2[1] = -99;
    expect(testTrajectory.states[7], equals(-99));
  });
  test("rangeError actually throws lmao", () {
    final testTrajectory = Trajectory(dimension: 3, points: 3);
    expect(() => testTrajectory.stateAt(3), throwsA(isA<RangeError>()));
  });
}
