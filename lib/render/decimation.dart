import 'dart:typed_data';

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
  double minDistaceSquared = minDistance * minDistance;
  buffer[0] = projected[0];
  buffer[1] = projected[1];
  int savedPoints = 1;
  int lastIndex = 0;
  for (int i = 2; i < projected.length - 3; i += 2) {
    if ((((projected[i] - buffer[lastIndex]) *
                (projected[i] - buffer[lastIndex])) +
            ((projected[i + 1] - buffer[lastIndex + 1]) *
                (projected[i + 1] - buffer[lastIndex + 1]))) >=
        minDistaceSquared) {
      savedPoints += 1;
      lastIndex += 2;
      buffer[lastIndex] = projected[i];
      buffer[lastIndex + 1] = projected[i + 1];
    }
  }
  lastIndex += 2;
  buffer[lastIndex] = projected[projected.length - 2];
  buffer[lastIndex + 1] = projected[projected.length - 1];
  savedPoints += 1;
  return Float32List.sublistView(buffer, 0, 2 * savedPoints);
}
