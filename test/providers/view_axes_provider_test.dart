import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/constant_values/indices.dart';
import 'package:fluttractor/providers/system_provider.dart';
import 'package:fluttractor/providers/view_axes_provider.dart';

void main() {
  test("default value is defaultAxes", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    expect(container.read(viewAxesProvider), equals(defaultAxes));
  });
  test("correct triplet is accepted", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    expect(
      () => container.read(viewAxesProvider.notifier).newAxes((
        axis1: 2,
        axis2: 0,
        axis3: 1,
      )),
      returnsNormally,
    );
    expect(
      container.read(viewAxesProvider),
      equals((axis1: 2, axis2: 0, axis3: 1)),
    );
  });
  test("incorrect triplet throws argument error", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    expect(
      () => container.read(viewAxesProvider.notifier).newAxes((
        axis1: 2,
        axis2: 0,
        axis3: 4,
      )),
      throwsArgumentError,
    );
    expect(container.read(viewAxesProvider), equals(defaultAxes));
  });
}
