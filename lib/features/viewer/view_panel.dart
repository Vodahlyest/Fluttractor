import 'package:flutter/material.dart';
import 'package:fluttractor/providers/plot_view_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:fluttractor/render/camera.dart';
import 'package:fluttractor/providers/scene_provider.dart';
import 'package:fluttractor/features/custom_widgets/view_bottom_list.dart';

class ViewPanel extends ConsumerStatefulWidget {
  const ViewPanel({super.key, required this.view});
  final PlotView view;
  @override
  ConsumerState<ViewPanel> createState() => _ViewPanelState();
}

class _ViewPanelState extends ConsumerState<ViewPanel> {
  Camera _camera = (yaw: 0.0, pitch: 0.0);

  @override
  Widget build(BuildContext context) {
    final scene = ref.watch(sceneProvider(widget.view.axes));
    return scene.when(
      data: (scene) => Stack(
        children: [
          SizedBox.expand(
            child: GestureDetector(
              onPanUpdate: (details) => setState(() {
                _camera = orbit(_camera, details.delta);
              }),
              behavior: HitTestBehavior.opaque,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: TrajectoryPainter(
                    trajectory: scene.trajectory,
                    xindex: widget.view.axes.axis1,
                    yindex: widget.view.axes.axis2,
                    zindex: widget.view.axes.axis3,
                    pointColor: Theme.of(context).colorScheme.primary,
                    camera: _camera,
                    sphere: scene.sphere,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentGeometry.topLeft,
            child: IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (BuildContext context) => ViewBottomSheet(viewId: widget.view.id),
              ),
              icon: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          "error occurred while performing calculations\n\nError: $err",
        ),
      ),
    );
  }
}
