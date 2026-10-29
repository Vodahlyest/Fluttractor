import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/calculations/view_axes.dart';
import 'package:fluttractor/providers/system_provider.dart';
import 'package:fluttractor/constant_values/indices.dart';

class ViewAxesNotifier extends Notifier<ViewAxes> {
  @override
  ViewAxes build() {
    checkAxes(defaultAxes, ref.watch(systemProvider).dimension);
    return defaultAxes;
  }

  void newAxes(ViewAxes newSet) {
    checkAxes(newSet, ref.read(systemProvider).dimension);
    state = newSet;
  }
}

final viewAxesProvider = NotifierProvider<ViewAxesNotifier, ViewAxes>(
  ViewAxesNotifier.new,
);
