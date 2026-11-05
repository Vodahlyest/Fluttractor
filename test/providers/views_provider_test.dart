import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/constant_values/indices.dart';
import 'package:fluttractor/providers/plot_view_provider.dart';
import 'package:fluttractor/providers/system_provider.dart';

void main() {
  test("provider initialization goes as expected", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    expect(container.read(plotViewProvider).length, equals(1));
    expect(
      container.read(plotViewProvider),
      equals([(id: 0, axes: defaultAxes)]),
    );
  });
  test("adding new view works as intended", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 2,
      axis2: 0,
      axis3: 1,
    ));
    expect(container.read(plotViewProvider).length, equals(2));
    expect(
      container.read(plotViewProvider).last,
      equals((id: 1, axes: (axis1: 2, axis2: 0, axis3: 1))),
    );
  });
  test("more than 4 views throws state error", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 0,
      axis2: 2,
      axis3: 1,
    ));
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 2,
      axis2: 0,
      axis3: 1,
    ));
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 2,
      axis2: 1,
      axis3: 0,
    ));
    expect(
      () => container.read(plotViewProvider.notifier).addNewPlotView((
        axis1: 1,
        axis2: 0,
        axis3: 2,
      )),
      throwsStateError,
    );
    expect(container.read(plotViewProvider).length, equals(4));
  });
  test("id numbers don't change", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 0,
      axis2: 2,
      axis3: 1,
    ));
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 2,
      axis2: 0,
      axis3: 1,
    ));
    container.read(plotViewProvider.notifier).removeViewById(1);
    expect(container.read(plotViewProvider).length, equals(2));
    expect(
      () => container.read(plotViewProvider).any((view) => view.id == 0),
      isNot(throwsStateError),
    );
    expect(
      () => container.read(plotViewProvider).any((view) => view.id == 2),
      isNot(throwsStateError),
    );
  });
  test("last view cannot be deleted", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    expect(
      () => container.read(plotViewProvider.notifier).removeViewById(0),
      throwsStateError,
    );
  });
  test("setNewtripletForId changes only the specified view", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 0,
      axis2: 2,
      axis3: 1,
    ));
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 2,
      axis2: 0,
      axis3: 1,
    ));
    final prevView0 = container.read(plotViewProvider)[0];
    final prevView1 = container.read(plotViewProvider)[1];
    final prevView2 = container.read(plotViewProvider)[2];
    container.read(plotViewProvider.notifier).setNewTripletForId(2, (
      axis1: 2,
      axis2: 1,
      axis3: 0,
    ));
    expect(container.read(plotViewProvider)[0], equals(prevView0));
    expect(container.read(plotViewProvider)[1], equals(prevView1));
    expect(container.read(plotViewProvider)[2], isNot(equals(prevView2)));
    expect(
      container.read(plotViewProvider).last.axes,
      equals((axis1: 2, axis2: 1, axis3: 0)),
    );
  });
  test("wrong triplet throws argument error", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    expect(
      () => container.read(plotViewProvider.notifier).addNewPlotView((
        axis1: 2,
        axis2: 1,
        axis3: 3,
      )),
      throwsArgumentError,
    );
    expect(container.read(plotViewProvider)[0].axes, equals(defaultAxes));
  });
  test("wrong ID while deleting or replacing throws argument error", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 0,
      axis2: 2,
      axis3: 1,
    ));
    expect(
      () => container.read(plotViewProvider.notifier).removeViewById(5),
      throwsArgumentError,
    );
    expect(
      () => container.read(plotViewProvider.notifier).setNewTripletForId(6, (
        axis1: 2,
        axis2: 0,
        axis3: 1,
      )),
      throwsArgumentError,
    );
  });
  test("id assignment works properly", () {
    final container = ProviderContainer.test(
      overrides: [systemProvider.overrideWithValue(lorenz)],
    );
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 0,
      axis2: 2,
      axis3: 1,
    ));
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 1,
      axis2: 0,
      axis3: 2,
    ));
    container.read(plotViewProvider.notifier).removeViewById(1);
    container.read(plotViewProvider.notifier).addNewPlotView((
      axis1: 2,
      axis2: 0,
      axis3: 1,
    ));
    expect(container.read(plotViewProvider).last.id, equals(3));
  });
}
