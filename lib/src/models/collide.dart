import 'dart:math';

import 'package:d3_force_flutter/src/helpers/jiggle.dart';
import 'package:d3_quadtree_flutter/d3_quadtree_flutter.dart';

import '../interfaces/force.dart';
import '../helpers/accessor.dart';
import '../helpers/lcg.dart';
import 'node.dart';

class Collide<N extends Node> implements IForce<N> {
  Collide({
    this.iterations = 1,
    double radius = 1,
    double strength = 1,
    AccessorCallback<double, N>? onRadius,
  })  : _strength = strength,
        _radii = [] {
    _radius = onRadius ?? (_) => radius;
  }

  @override
  List<N>? nodes;

  // Variables modified through iterations
  late N node;
  late double xi, yi, ri, ri2;

  double _strength;
  set strength(double strength) => _strength = strength;
  int iterations;

  late Quadtree<N> _tree;
  LCG? random;
  List<double> _radii;

  late AccessorCallback<double, N> _radius;
  set radius(AccessorCallback<double, N> fn) {
    _radius = fn;
    _initialize();
  }

  @override
  void call([double alpha = 1]) {
    _tree = Quadtree(
      points: [...?nodes],
      x: (n) => n.x + n.vx,
      y: (n) => n.y + n.vy,
    )..visitAfter(prepare);

    for (var i = 0; i < n; ++i) {
      node = nodes![i];
      ri = _radii[node.index!];
      ri2 = ri * ri;
      xi = node.x + node.vx;
      yi = node.y + node.vy;
      _tree.visit(_apply);
    }
  }

  bool _apply(IQuadtreeNode<N>? quad, Extent e) {
    double rj = quad?.r ?? 0, r = ri + rj;
    if (quad is ILeafNode<N>) {
      if (quad.point.index! > node.index!) {
        final N point = quad.point;
        double x = xi - point.x - point.vx,
            y = yi - point.y - point.vy,
            l = x * x + y * y;

        if (l < r * r) {
          if (random != null) {
            if (x == 0) {
              x = jiggle(random!);
              l += x * x;
            }
            if (y == 0) {
              y = jiggle(random!);
              l += y * y;
            }
          }
          l = (r - (l = sqrt(l))) / l * _strength;
          node
            ..vx += (x *= l) * (r = (rj *= rj) / (ri2 + rj))
            ..vy += (y *= l) * r;
          quad.point
            ..vx -= x * (r = 1 - r)
            ..vy -= y * r;
        }
      }
      return false;
    }
    return e.x0 > xi + r || e.x1 < xi - r || e.y0 > yi + r || e.y1 < yi - r;
  }

  bool prepare(IQuadtreeNode<N>? quad, Extent _) {
    if (quad is ILeafNode<N>) {
      quad.r = _radii[quad.point.index!];
      return quad.r != 0;
    } else {
      for (final node in [...?(quad as IInternalNode<N>?)?.nodes]) {
        quad!.r = max(quad.r ?? 0, node?.r ?? 0);
      }
    }
    return false;
  }

  void _initialize() {
    if (nodes == null) return;

    _radii = List.filled(n, 0);
    for (int i = 0; i < n; ++i) {
      final node = nodes![i];
      _radii[node.index!] = _radius(node);
    }
  }

  @override
  void initialize(List<N> _nodes, LCG? _random) {
    nodes = _nodes;
    random = _random;
    _initialize();
  }
}
