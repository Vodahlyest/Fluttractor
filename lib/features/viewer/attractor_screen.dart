import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/features/viewer/view_panel.dart';
import 'package:fluttractor/features/viewer/tiling.dart';
import 'package:fluttractor/providers/plot_view_provider.dart';

class AttractorScreen extends ConsumerWidget {
  const AttractorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotViews = ref.watch(plotViewProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.outlineVariant,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = buildTiles(plotViews.length, constraints.biggest);
          return Stack(
            children: [
              for (final (index, view) in plotViews.indexed) Positioned.fromRect(key: ValueKey(view), rect: tiles[index], child: ColoredBox(color: Theme.of(context).colorScheme.surface, child: ViewPanel(view: view)))
            ]
          );
        }
      )
    );
  }
}