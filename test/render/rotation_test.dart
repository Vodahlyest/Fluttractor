import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/render/rotation.dart';
import '../helpers/trajectory_init.dart';
import 'dart:math';

void main(){
  test("no angles -> no rotation", (){
    final testTrajectory = trajectoryInit([[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]]);
    final rotated = rotate(testTrajectory, 0, 1, 2, yaw: 0, pitch: 0);
    expect(rotated.states, equals(testTrajectory.states));
  });

  test("yaw = pi / 2, pitch = 0", (){
    final testTrajectory = trajectoryInit([[1.0, 0.0, 0.0]]);
    final expected = [0, 1, 0];
    final rotated = rotate(testTrajectory, 0, 1, 2, yaw: pi / 2, pitch: 0);
    for (int i = 0; i < rotated.dimension; i++){
      expect(rotated.states[i], closeTo(expected[i], 1e-12));
    }
  });
  test("pitch = pi / 2, yaw = 0", (){
    final testTrajectory = trajectoryInit([[0.0, 0.0, 1.0]]);
    final expected = [0, -1, 0];
    final rotated = rotate(testTrajectory, 0, 1, 2, yaw: 0, pitch: pi / 2);
    for (int i = 0; i < rotated.dimension; i++){
      expect(rotated.states[i], closeTo(expected[i], 1e-12));
    }
  });
  test("distance between poitns remain the same", (){
    final testTrajectory = trajectoryInit([[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]]);
    final rotated = rotate(testTrajectory, 0, 1, 2, yaw: pi/3, pitch: (2 * pi) / 3);
    final dxTest = (testTrajectory.states[3] - testTrajectory.states[0]);
    final dyTest = (testTrajectory.states[4] - testTrajectory.states[1]);
    final dzTest = (testTrajectory.states[5] - testTrajectory.states[2]);
    final dxRotated = (rotated.states[3] - rotated.states[0]);
    final dyRotated = (rotated.states[4] - rotated.states[1]);
    final dzRotated = (rotated.states[5] - rotated.states[2]);
    final d1 = sqrt((dxTest * dxTest) + (dyTest * dyTest) + (dzTest * dzTest));
    final d2 = sqrt((dxRotated * dxRotated) + (dyRotated * dyRotated) + (dzRotated * dzRotated));
    expect(d1, closeTo(d2, 1e-12));
  });
  test("different choice of indecies result in different rotations", (){
    final testTrajectory1 = trajectoryInit([[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]]);
    final testTrajectory2 = trajectoryInit([[2.0, 0.0, 1.0], [5.0, 3.0, 4.0]]);
    final rotated1 = rotate(testTrajectory1, 0, 1, 2, yaw: pi / 2, pitch: pi /2);
    final rotated2 = rotate(testTrajectory1, 2, 0, 1, yaw: pi / 2, pitch: pi /2);
    final tPrimeRotation = rotate(testTrajectory2, 0, 1, 2, yaw: pi/2, pitch: pi/2);
    expect(rotated1.states, isNot(equals(rotated2.states)));
    expect(rotated2.states, equals(tPrimeRotation.states));
  });
}