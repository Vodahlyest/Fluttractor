import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttractor/calculations/bounding_sphere.dart';
import 'package:fluttractor/calculations/scene.dart';
import 'package:fluttractor/providers/trajectory_provider.dart';
import 'package:fluttractor/calculations/view_axes.dart';

final sceneProvider = FutureProvider.family<Scene, ViewAxes>(
  retry: (retryCount, error) => null,
  (ref, selectedAxes) async {
    final trajectory = await ref.watch(trajectoryProvider.future);
    final sphere = boundingSphere(
      trajectory,
      selectedAxes.axis1,
      selectedAxes.axis2,
      selectedAxes.axis3,
    );
    return (trajectory: trajectory, sphere: sphere);
  },
);
