import 'package:bg_calculator/bg_calculator.dart';
import 'package:flutter/material.dart';
import 'package:fluttractor/calculations/view_axes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/providers/system_provider.dart';
import 'package:fluttractor/providers/view_axes_provider.dart';

Widget buildBottomSheet(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      ViewAxes chosenTriplet = ref.watch(viewAxesProvider);
      OdeSystem system = ref.watch(systemProvider);
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
                        (chosenTriplet.axis1 ==
                        system.variableNames.indexOf(variable));

                    return ChoiceChip(
                      label: Text(variable),
                      selected: isSelected,
                      showCheckmark: true,
                      onSelected: (bool selected) {
                        ref
                            .read(viewAxesProvider.notifier)
                            .newAxes(
                              setAxesWithParameters(
                                chosenTriplet,
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
                        (chosenTriplet.axis2 ==
                        system.variableNames.indexOf(variable));

                    return ChoiceChip(
                      label: Text(variable),
                      selected: isSelected,
                      showCheckmark: true,
                      onSelected: (bool selected) {
                        ref
                            .read(viewAxesProvider.notifier)
                            .newAxes(
                              setAxesWithParameters(
                                chosenTriplet,
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
                        (chosenTriplet.axis3 ==
                        system.variableNames.indexOf(variable));

                    return ChoiceChip(
                      label: Text(variable),
                      selected: isSelected,
                      showCheckmark: true,
                      onSelected: (bool selected) {
                        ref
                            .read(viewAxesProvider.notifier)
                            .newAxes(
                              setAxesWithParameters(
                                chosenTriplet,
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
    },
  );
}
