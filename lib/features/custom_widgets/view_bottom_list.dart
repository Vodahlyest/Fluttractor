import 'package:flutter/material.dart';
import 'package:fluttractor/calculations/view_axes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/providers/plot_view_provider.dart';
import 'package:fluttractor/providers/system_provider.dart';

class ViewBottomSheet extends ConsumerWidget {
  const ViewBottomSheet({super.key, required this.viewId});
  final int viewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final views = ref.watch(plotViewProvider);
    final system = ref.watch(systemProvider);
    final selectedView = views.firstWhere((element) => element.id == viewId);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8.0,
        children: [
          Text("Select the triplet of axes to display the plot"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 10.0,
            children: [
              Text("Width"),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: system.variableNames.map((variable) {
                  bool isSelected =
                      selectedView.axes.axis1 ==
                      system.variableNames.indexOf(variable);

                  return ChoiceChip(
                    label: Text(variable),
                    selected: isSelected,
                    showCheckmark: true,
                    onSelected: (bool selected) {
                      ref
                          .read(plotViewProvider.notifier)
                          .setNewTripletForId(
                            viewId,
                            setAxesWithParameters(
                              selectedView.axes,
                              1,
                              system.variableNames.indexOf(variable),
                            ),
                          );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            spacing: 10.0,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("depth"),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: system.variableNames.map((variable) {
                  bool isSelected =
                      (views
                          .firstWhere((element) => element.id == viewId)
                          .axes
                          .axis2 ==
                      system.variableNames.indexOf(variable));

                  return ChoiceChip(
                    label: Text(variable),
                    selected: isSelected,
                    showCheckmark: true,
                    onSelected: (bool selected) {
                      ref
                          .read(plotViewProvider.notifier)
                          .setNewTripletForId(
                            viewId,
                            setAxesWithParameters(
                              selectedView.axes,
                              2,
                              system.variableNames.indexOf(variable),
                            ),
                          );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            spacing: 10.0,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("height"),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: system.variableNames.map((variable) {
                  bool isSelected =
                      (views
                          .firstWhere((element) => element.id == viewId)
                          .axes
                          .axis3 ==
                      system.variableNames.indexOf(variable));

                  return ChoiceChip(
                    label: Text(variable),
                    selected: isSelected,
                    showCheckmark: true,
                    onSelected: (bool selected) {
                      ref
                          .read(plotViewProvider.notifier)
                          .setNewTripletForId(
                            viewId,
                            setAxesWithParameters(
                              selectedView.axes,
                              3,
                              system.variableNames.indexOf(variable),
                            ),
                          );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
