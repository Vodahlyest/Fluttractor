import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/calculations/view_axes.dart';
import 'package:fluttractor/constant_values/indices.dart';
import 'package:fluttractor/providers/system_provider.dart';
import 'package:fluttractor/constant_values/view_limit.dart';

typedef PlotView = ({int id, ViewAxes axes});

class PlotViewNotifier extends Notifier<List<PlotView>> {
  @override
  List<PlotView> build() {
    final system = ref.watch(systemProvider);
    checkAxes(defaultAxes, system.dimension);
    return [
      (id: 0, axes: defaultAxes),
      (id: 1, axes: (axis1: 0, axis2: 1, axis3: 3)),
      (id: 2, axes: (axis1: 1, axis2: 2, axis3: 3)),
    ];
  }

  void addNewPlotView(ViewAxes newAxes) {
    if (state.length == viewLimit) {
      throw StateError(
        "You can't add more than $viewLimit plot views: views = ${state.length}",
      );
    }
    checkAxes(newAxes, ref.read(systemProvider).dimension);
    int maxId = state.map((view) => view.id).reduce(max);
    state = [...state, (id: maxId + 1, axes: newAxes)];
  }

  void removeViewById(int chosenId) {
    if (state.length == 1) {
      throw StateError(
        "There should be at least one view to display: amount of views = ${state.length}",
      );
    }
    if (!(state.any((view) => view.id == chosenId))) {
      throw ArgumentError("no such id for view: chosenId = $chosenId");
    }
    state = state.where((view) => view.id != chosenId).toList();
  }

  void setNewTripletForId(int id, ViewAxes newSet) {
    checkAxes(newSet, ref.read(systemProvider).dimension);

    if (!state.any((view) => view.id == id)) {
      throw ArgumentError("No element with such ID: chosen ID = $id");
    }

    state = state
        .map((view) => view.id == id ? (id: view.id, axes: newSet) : view)
        .toList();
  }
}

final plotViewProvider = NotifierProvider<PlotViewNotifier, List<PlotView>>(
  PlotViewNotifier.new,
);
