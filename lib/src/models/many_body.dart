import 'dart:math';

import 'package:d3_force_flutter/src/helpers/jiggle.dart';
import 'package:d3_quadtree_flutter/d3_quadtree_flutter.dart';

import '../interfaces/force.dart';
import '../helpers/accessor.dart';
import '../helpers/lcg.dart';
import 'node.dart';

class ManyBody<N extends Node> implements IForce<N> {
  ManyBody({
    double strength = -30,
    double distanceMin2 = 1,
    double distanceMax2 = double.infinity,
    double theta2 = 0.81,
    AccessorCallback<double, N>? onStrength,
  })  : _distanceMin2 = distanceMin2,
        _distanceMax2 = distanceMax2,
        _theta2 = theta2,
        _strengths = [] {
    _onStrength = onStrength ?? (_) => strength;
  }

  @override
  List<N>? nodes;
  LCG? random;

  late double _alpha;
  N? _node;
  List<double> _strengths;

  double _distanceMin2, _distanceMax2, _theta2;

  set distanceMin(double dm) {
    _distanceMin2 = dm * dm;
    this();
  }

  set distanceMax(double dm) {
    _distanceMax2 = dm * dm;
    this();
  }

  set theta(double theta) {
    _theta2 = theta * theta;
    this();
  }

  late AccessorCallback<double, N> _onStrength;
  set onStrength(AccessorCallback<double, N> fn) {
    _onStrength = fn;
    _initialize();
  }

  @override
  void call([double alpha = 1]) {
    _alpha = alpha;
    final tree = Quadtree<N>(
      points: nodes,
      x: (n) => n.x,
      y: (n) => n.y,
    )..visitAfter(accumulate);
    for (final node in nodes!) {
      _node = node;
      tree.visit(_apply);
    }
  }

  bool _apply(IQuadtreeNode<N>? quad, Extent e) {
    if (quad?.value == null) return true;

    double x = quad!.fx! - _node!.x,
        y = quad.fy! - _node!.y,
        w = e.x0 - e.x1,
        l = x * x + y * y;

    // Apply the Barnes-Hut approximation if possible.
    // Limit forces for very close nodes; randomize direction if coincident.
    if (w * w / _theta2 < l) {
      if (l < _distanceMax2) {
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
        if (l < _distanceMin2) l = sqrt(_distanceMin2 * l);
        _node!
          ..vx += x * quad.value! * _alpha / l
          ..vy += y * quad.value! * _alpha / l;
      }
      return true;
    }

    // Otherwise, process points directly.
    else if (quad is IInternalNode<N> || l >= _distanceMax2) return false;

    // Limit forces for very close nodes; randomize direction if coincident.
    if (quad is ILeafNode<N> && (quad.point != _node || quad.next != null)) {
      if (x == 0) {
        x = jiggle(random!);
        l += x * x;
      }
      if (y == 0) {
        y = jiggle(random!);
        l += y * y;
      }
      if (l < _distanceMin2) l = sqrt(_distanceMin2 * l);
    }

    if (quad is ILeafNode<N> && quad.point != _node) {
      do {
        quad = quad as ILeafNode<N>;
        w = _strengths[quad.point.index!] * _alpha / l;
        _node!
          ..vx += x * w
          ..vy += y * w;
      } while ((quad = quad.next) != null);
    }

    return false;
  }

  bool accumulate(
    IQuadtreeNode<N>? quad,
    Extent _,
  ) {
    if (quad == null) return false;
    double strength = 0, weight = 0, x = 0, y = 0;
    double? c;

    if (quad is IInternalNode<N> && quad.nodes != null) {
      for (final q in quad.nodes!) {
        if ((c = q?.value?.abs() ?? 0) != 0) {
          strength += q!.value!;
          weight += c;
          x += c * q.fx!;
          y += c * q.fy!;
        }
      }
      quad
        ..fx = x / weight
        ..fy = y / weight;
    } else if (quad is ILeafNode<N>) {
      ILeafNode<N>? q = quad;
      quad
        ..fx = quad.point.x
        ..fy = quad.point.y;
      do {
        strength += _strengths[q!.point.index!];
      } while ((q = q.next) != null);
    }

    quad.value = strength;
    return false;
  }

  void _initialize() {
    if (nodes == null) return;

    _strengths = List.filled(n, 0);
    for (int i = 0; i < n; i++) {
      _node = nodes![i];
      _strengths[_node!.index!] = _onStrength(_node!);
    }
  }

  @override
  void initialize(List<N> _nodes, LCG? _random) {
    nodes = _nodes;
    random = _random;
    _initialize();
  }
}
