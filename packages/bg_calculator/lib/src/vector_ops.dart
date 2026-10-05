import 'dart:typed_data';

/// Computes resBuff = yVec + scalar * kVec element-wise
/// 1. resBuff[i] = (scalar * kVec[i]) + yVec[i]
/// 2. no memory is allocated for the result, it is written to resBuff
/// 3. lengths of the vectors must be the same, otherwise an assertion error is thrown
/// 4. resBuff may be the same object as the kVec or yVec
void axpy(
  Float64List yVec,
  double scalar,
  Float64List kVec,
  Float64List resBuff,
) {
  assert(
    yVec.length == kVec.length && resBuff.length == kVec.length,
    "Vectors must be the same length: yVec: ${yVec.length}, resBuff: ${resBuff.length}, kVec: ${kVec.length}",
  );
  for (int i = 0; i < kVec.length; i++) {
    resBuff[i] = (scalar * kVec[i]) + yVec[i];
  }
}
