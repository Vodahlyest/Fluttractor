import 'package:flutter/material.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'package:fluttractor/render/trajectory_painter.dart';

import 'dart:typed_data';

class AttractorScreen extends StatefulWidget {
  const AttractorScreen({super.key});

  @override
  State<AttractorScreen> createState() => _AttractorScreenState();
}

class _AttractorScreenState extends State<AttractorScreen> {
  late final Trajectory _systemTrajectory;

  @override
  void initState() {
    super.initState();
    _systemTrajectory = integrate(
      Rk4(system: lorenz),
      Float64List.fromList([1.0, 1.0, 1.0]),
      0,
      50,
      0.01,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: CustomPaint(
          painter: TrajectoryPainter(
            trajectory: _systemTrajectory,
            hIndex: 0,
            vIndex: 2,
            pointColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
