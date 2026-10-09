import 'dart:typed_data';

class Trajectory {
  Trajectory({required this.dimension, required this.points})
    : states = Float64List(dimension * points),
      time = Float64List(points);
  final int dimension;
  final int points;
  final Float64List time;
  final Float64List states;

  /// stateAt returns a view (reference) of the states vector
  /// at specified time point. all the states are saved in the flat list
  /// instead of a list of lists due to the memory economy.
  Float64List stateAt(int timeIndex) {
    RangeError.checkValidIndex(timeIndex, time, "timeIndex");
    return Float64List.sublistView(
      states,
      timeIndex * dimension,
      (timeIndex + 1) * dimension,
    );
  }
}
