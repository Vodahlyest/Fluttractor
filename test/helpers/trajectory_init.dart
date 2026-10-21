import 'package:bg_calculator/bg_calculator.dart';

Trajectory trajectoryInit(List<List<double>> points) {
  assert(points.isNotEmpty, "points should contain at least one point: ${points.length}");
  for (int i = 0; i < points.length - 1; i++) {
    assert(
      points[i].length == points[i + 1].length,
      "follow the dimension restricitions",
    );
  }
  final testTrajectory = Trajectory(
    dimension: points[0].length,
    points: points.length,
  );
  for (int i = 0; i < points.length; i++) {
    testTrajectory.states.setRange(
      i * testTrajectory.dimension,
      (i + 1) * testTrajectory.dimension,
      points[i],
    );
  }
  return testTrajectory;
}
