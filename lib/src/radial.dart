import 'dart:math';

import 'constants.dart';
import 'force.dart';
import 'node.dart';

class Radial<N extends Node> extends IForce<N> {
  Radial({
    required double radius,
    this.x = 0,
    this.y = 0,
    double strength = 0.1,
    this.onRadius,
    this.onStrength,
  })  : _radius = radius,
        super(strength: strength);

  double x, y;
  double _radius;

  late List<double> strengths, radiuses;
  AccessorCallback<double, N>? onRadius, onStrength;

  set radius(double r) {
    _radius = r;
    _initialize();
  }

  set strength(double _strength) {
    super.strength = _strength;
    _initialize();
  }

  @override
  void call([double alpha = 1]) {
    for (int i = 0; i < n; i++) {
      final node = nodes![i];

      double dx = node.x - x;
      double dy = node.y - y;
      dx = dx.abs() < eps ? eps : dx;
      dy = dy.abs() < eps ? eps : dy;

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
      radiuses[i] = onRadius == null ? _radius : onRadius!(nodes![i]);
      if (!radiuses[i].isNaN) {
        strengths[i] = onStrength == null ? strength : onStrength!(nodes![i]);
      }
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
    _initialize();
  }
}
