import 'package:flutter/material.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'package:fluttractor/render/trajectory_painter.dart';
import 'package:fluttractor/render/camera.dart';
import 'package:fluttractor/render/bounding_sphere.dart';
import 'package:fluttractor/features/density/density.dart';

import 'dart:typed_data';

class AttractorScreen extends StatefulWidget {
  const AttractorScreen({super.key});

  @override
  State<AttractorScreen> createState() => _AttractorScreenState();
}

class _AttractorScreenState extends State<AttractorScreen> {
  late Trajectory _systemTrajectory;
  Density _density = Density.low;
  bool _antiAliasState = false;
  late double _calculationTime;
  Camera _camera = (yaw: 0.0, pitch: 0.0);
  late ({double cx, double cy, double cz, double radius}) _sphere;
  final xIndex = 0;
  final yIndex = 1;
  final zIndex = 2;

  void _compute() {
    double currentStep = _density.step;
    final stopwatch = Stopwatch();
    stopwatch.start();
    _systemTrajectory = integrate(
      Rk4(system: lorenz),
      Float64List.fromList([1.0, 1.0, 1.0]),
      0,
      50,
      currentStep,
    );
    stopwatch.stop();
    _calculationTime = stopwatch.elapsedMicroseconds / 1000;
    _sphere = boundingSphere(_systemTrajectory, xIndex, yIndex, zIndex);
  }

  @override
  void initState() {
    super.initState();
    _compute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
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
                  antiAlias: _antiAliasState,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedButton<Density>(
                      segments: Density.values.map((value) {
                        return ButtonSegment(
                          label: Text(value.label),
                          value: value,
                        );
                      }).toList(),
                      selected: <Density>{_density},
                      onSelectionChanged: (Set<Density> newSelection) {
                        setState(() {
                          _density = newSelection.first;
                          _compute();
                        });
                      },
                    ),
                    Text(
                      "current amount of points: ${_systemTrajectory.points}",
                    ),
                    Text(
                      "Calculation time: ${_calculationTime.toStringAsFixed(2)} ms",
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Smoothing: "),
                        SizedBox(width: 8),
                        Switch(
                          value: _antiAliasState,
                          onChanged: (bool value) {
                            setState(() {
                              _antiAliasState = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
