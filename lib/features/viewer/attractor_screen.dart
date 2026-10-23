import 'package:flutter/material.dart';
import 'package:fluttractor/constant_values/indices.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:fluttractor/render/camera.dart';
import 'package:fluttractor/providers/scene_provider.dart';

class AttractorScreen extends ConsumerStatefulWidget {
  const AttractorScreen({super.key});

  @override
  ConsumerState<AttractorScreen> createState() => _AttractorScreenState();
}

class _AttractorScreenState extends ConsumerState<AttractorScreen> {
  Camera _camera = (yaw: 0.0, pitch: 0.0);

  @override
  Widget build(BuildContext context) {
    final scene = ref.watch(sceneProvider);
    return Scaffold(
      body: scene.when(
        data: (scene) => SizedBox.expand(
          child: GestureDetector(
            onPanUpdate: (details) => setState(() {
              _camera = orbit(_camera, details.delta);
            }),
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: TrajectoryPainter(
                trajectory: scene.trajectory,
                xindex: defaultAxes.x,
                yindex: defaultAxes.y,
                zindex: defaultAxes.z,
                pointColor: Theme.of(context).colorScheme.primary,
                camera: _camera,
                sphere: scene.sphere,
              ),
            ),
          ),
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
