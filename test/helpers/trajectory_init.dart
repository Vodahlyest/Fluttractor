import 'package:bg_calculator/bg_calculator.dart';

Trajectory trajectoryInit(List<List<double>> points) {
  final testTrajectory = Trajectory(dimension: 3, points: points.length);
  for (int i = 0; i < points.length; i++) {
    testTrajectory.states[(i * testTrajectory.dimension)] = points[i][0];
    testTrajectory.states[(i * testTrajectory.dimension) + 1] = points[i][1];
    testTrajectory.states[(i * testTrajectory.dimension) + 2] = points[i][2];
  }
  return testTrajectory;
}
