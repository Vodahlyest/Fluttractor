import 'package:flutter/material.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:fluttractor/render/camera.dart';
import 'package:fluttractor/render/bounding_sphere.dart';
import 'package:fluttractor/calculations/sphere.dart';

import 'dart:typed_data';

class AttractorScreen extends StatefulWidget {
  const AttractorScreen({super.key});

  @override
  State<AttractorScreen> createState() => _AttractorScreenState();
}

class _AttractorScreenState extends State<AttractorScreen> {
  late final Trajectory _systemTrajectory;
  late Camera _camera;
  late final Sphere _sphere;
  final xIndex = 0;
  final yIndex = 1;
  final zIndex = 2;

  @override
  void initState() {
    super.initState();
    _camera = (yaw: 0.0, pitch: 0.0);
    _systemTrajectory = integrate(
      Rk4(system: lorenz),
      Float64List.fromList([1.0, 1.0, 1.0]),
      0,
      50,
      0.01,
    );
    _sphere = boundingSphere(_systemTrajectory, xIndex, yIndex, zIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: GestureDetector(
          onPanUpdate: (details) => setState(() {
            _camera = orbit(_camera, details.delta);
          }),
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
            painter: TrajectoryPainter(
              trajectory: _systemTrajectory,
              xindex: xIndex,
              yindex: yIndex,
              zindex: zIndex,
              pointColor: Theme.of(context).colorScheme.primary,
              camera: _camera,
              sphere: _sphere,
            ),
          ),
        ),
      ),
    );
  }
}
