import 'dart:typed_data';

/// Removes certain points from
/// the projection according to the Radial Distance
/// polyline simplification rule for better performance
/// arguments
/// 1. projected - a list of ODE points projected in px
/// 2. minDistance - decimation parameter, 1 by default
/// 
Float32List decimate(Float32List projected, {double minDistance = 1.0}) {
  assert(
    projected.length % 2 == 0,
    "The array should have the even length: ${projected.length}",
  );
  assert(minDistance >= 0, "minDistance should be non-negative: $minDistance");
  if (projected.length <= 2) {
    return Float32List.sublistView(projected);
  }
  final Float32List buffer = Float32List(projected.length);
  final double minDistanceSquared = minDistance * minDistance;
  buffer[0] = projected[0];
  buffer[1] = projected[1];
  int lastIndex = 0;
  for (int i = 2; i < projected.length - 3; i += 2) {
    if ((((projected[i] - buffer[lastIndex]) *
                (projected[i] - buffer[lastIndex])) +
            ((projected[i + 1] - buffer[lastIndex + 1]) *
                (projected[i + 1] - buffer[lastIndex + 1]))) >=
        minDistanceSquared) {
      lastIndex += 2;
      buffer[lastIndex] = projected[i];
      buffer[lastIndex + 1] = projected[i + 1];
    }
  }
  lastIndex += 2;
  buffer[lastIndex] = projected[projected.length - 2];
  buffer[lastIndex + 1] = projected[projected.length - 1];
  return Float32List.sublistView(buffer, 0, lastIndex + 2);
}
