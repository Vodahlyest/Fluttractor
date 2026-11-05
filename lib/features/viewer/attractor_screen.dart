import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/features/viewer/view_panel.dart';
import 'package:fluttractor/providers/plot_view_provider.dart';

class AttractorScreen extends ConsumerWidget {
  const AttractorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotViews = ref.watch(plotViewProvider);
    return Scaffold(
      body: ViewPanel(key: ValueKey(plotViews.first), view: plotViews.first),
    );
  }
}