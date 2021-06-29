import 'dart:math';

import '../helpers/accessor.dart';
import '../helpers/constants.dart';
import '../interfaces/force.dart';
import 'node.dart';

class Radial<N extends Node> implements IForce<N> {
  Radial({
    this.x = 0,
    this.y = 0,
    double strength = 0.1,
    double radius = 0,
    AccessorCallback<double, N>? onRadius,
    AccessorCallback<double, N>? onStrength,
  }) {
    _radius = onRadius ?? (_) => radius;
    _strength = onStrength ?? (_) => strength;
  }

  @override
  List<N>? nodes;
  double x, y;

  late List<double> strengths, radiuses;
  late AccessorCallback<double, N> _radius, _strength;

  set radius(AccessorCallback<double, N> fn) {
    _radius = fn;
    _initialize();
  }

  set strength(AccessorCallback<double, N> fn) {
    _strength = fn;
    _initialize();
  }

  @override
  void call([double alpha = 1]) {
    for (int i = 0; i < n; i++) {
      final node = nodes![i];

      double dx = node.x - x, dy = node.y - y;
      if (dx == 0) dx = eps;
      if (dy == 0) dy = eps;

      final r = sqrt(pow(dx, 2) + pow(dy, 2));
      final k = (radiuses[i] - r) * strengths[i] * alpha / r;

      node.vx += dx * k;
      node.vy += dy * k;
    }
  }

  void _initialize() {
    radiuses = List.filled(n, 0);
    strengths = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      if (!(radiuses[i] = _radius(node)).isNaN) strengths[i] = _strength(node);
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
    _initialize();
  }
}
