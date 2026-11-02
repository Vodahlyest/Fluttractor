import 'package:flutter/material.dart';
import 'package:fluttractor/calculations/view_axes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/providers/view_axes_provider.dart';
import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:fluttractor/render/camera.dart';
import 'package:fluttractor/providers/scene_provider.dart';
import 'package:fluttractor/features/custom_widgets/build_bottom_sheet.dart';

class AttractorScreen extends ConsumerStatefulWidget {
  const AttractorScreen({super.key});

  @override
  ConsumerState<AttractorScreen> createState() => _AttractorScreenState();
}

class _AttractorScreenState extends ConsumerState<AttractorScreen> {
  Camera _camera = (yaw: 0.0, pitch: 0.0);

  @override
  Widget build(BuildContext context) {
    final ViewAxes selectedAxes = ref.watch(viewAxesProvider);
    ref.listen(viewAxesProvider, (previous, next) {
      setState(() {
        _camera = (yaw: 0.0, pitch: 0.0);
      });
    });
    final scene = ref.watch(sceneProvider(selectedAxes));
    return Scaffold(
      body: scene.when(
        data: (scene) => Stack(
          children: [
            SizedBox.expand(
              child: GestureDetector(
                onPanUpdate: (details) => setState(() {
                  _camera = orbit(_camera, details.delta);
                }),
                behavior: HitTestBehavior.opaque,
                child: CustomPaint(
                  painter: TrajectoryPainter(
                    trajectory: scene.trajectory,
                    xindex: selectedAxes.axis1,
                    yindex: selectedAxes.axis2,
                    zindex: selectedAxes.axis3,
                    pointColor: Theme.of(context).colorScheme.primary,
                    camera: _camera,
                    sphere: scene.sphere,
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
                  builder: buildBottomSheet,
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
      ),
    );
  }
}
