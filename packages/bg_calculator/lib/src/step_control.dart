import 'dart:math';
import 'dart:typed_data';

double errorNorm(
  Float64List y,
  Float64List yNew,
  Float64List errorEstimate,
  double rtol,
  double atol,
) {
  if (!(y.length == yNew.length && y.length == errorEstimate.length)) {
    throw ArgumentError(
      "lengths of the passed arrays should be the same: y: ${y.length}, "
      "yNew: ${yNew.length}, errorEstimate: ${errorEstimate.length}",
    );
  }

  if (!(atol > 0 && rtol >= 0)) {
    throw ArgumentError(
      "atol should be > 0 and rtol >= 0: "
      "atol: $atol, rtol: $rtol",
    );
  }

  double sumOfSquares = 0;
  for (int i = 0; i < yNew.length; i++) {
    final sc = atol + rtol * max(y[i].abs(), yNew[i].abs());
    final r = ((errorEstimate[i] / sc) * (errorEstimate[i] / sc));
    sumOfSquares += r * r;
  }

  return sqrt(sumOfSquares / yNew.length);
}

double stepMultiplier(
  double err,
  int errorOrder, {
  double fac = 0.9,
  double facMin = 0.2,
  double facMax = 5.0,
}) {
  if (!err.isFinite) return facMin;
  return err == 0
      ? facMax
      : ((fac * pow(err, (-1 / (errorOrder + 1)))).clamp(
          facMin,
          facMax,
        )).toDouble();
}
