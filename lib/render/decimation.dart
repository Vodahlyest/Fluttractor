import 'dart:typed_data';

/// Simplifies a polyline of screen points by dropping every point that
/// lies closer than [minDistance] to the last kept point.
///
/// [projected] is a flat list of `(x, y)` pairs in logical pixels, as
/// returned by `projectFixed`. Its length must be even.
///
/// This is the radial distance simplification: a single O(n) pass that
/// compares each point with the last *kept* point rather than with its
/// immediate predecessor, so a slow drift of many short steps is still
/// preserved.
///
/// Guarantees:
/// * the first and the last points are always kept;
/// * every dropped point lies within [minDistance] of a kept point, so the
///   result deviates from the input by at most [minDistance] pixels;
/// * [projected] is never modified.
///
/// If [projected] contains fewer than two points, the result is a view of
/// [projected] rather than a copy.
///
/// In debug mode, throws an [AssertionError] if the length of [projected]
/// is odd or [minDistance] is negative.
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
