import 'dart:math';

import '../helpers/constants.dart';
import '../helpers/accessor.dart';
import '../interfaces/force.dart';
import '../helpers/jiggle.dart';
import '../helpers/lcg.dart';
import 'node.dart';

class Edge<N extends Node> {
  Edge({
    required this.source,
    required this.target,
    this.index,
  });

  int? index;
  final N source, target;
}

class Edges<E extends Edge<N>, N extends Node> implements IForce<N> {
  Edges({
    required this.id,
    this.iterations = 1,
    AccessorCallback<double, E>? onDistance,
    AccessorCallback<double, E>? onStrength,
    double distance = 30,
    List<E>? edges,
  })  : distances = [],
        strengths = [],
        count = [],
        bias = [],
        edges = edges ?? [] {
    _onStrength = onStrength ??
        (E edge) => 1 / min(count[edge.source.index], count[edge.target.index]);
    _onDistance = onDistance ?? (_) => distance;
  }

  final String id;
  @override
  List<N>? nodes;
  late List<E> edges;

  int iterations;
  List<double> distances, strengths, bias;
  List<int> count;
  LCG? random;

  late AccessorCallback<double, E> _onStrength, _onDistance;

  set onStrength(AccessorCallback<double, E> fn) {
    _onStrength = fn;
    _initialize();
  }

  set onDistance(AccessorCallback<double, E> fn) {
    _onDistance = fn;
    _initialize();
  }

  int get m => edges.length;

  @override
  void call([double alpha = 1]) {
    for (int k = 0; k < iterations; k++) {
      for (int i = 0; i < n; i++) {
        final edge = edges[i];
        final N source = edge.source;
        final N target = edge.target;

        double x = target.x + target.vx - source.x - source.vx,
            y = target.y + target.vy - source.y - source.vy;

        if (random != null) {
          x == 0 ? jiggle(random!) : x;
          y == 0 ? jiggle(random!) : y;
        }

        double l = sqrt(pow(x, 2) + pow(y, 2));
        l = (l - distances[i]) / l * alpha * strengths[i];

        x *= l;
        y *= l;

        final b = bias[i];
        edge.target.vx -= x * b;
        edge.target.vy -= y * b;
        edge.source.vx += x * (1 - b);
        edge.source.vy += y * (1 - b);
      }
    }
  }

  void _initialize() {
    if (nodes == null) return;
    count = List.filled(n, 0);

    for (int i = 0; i < m; i++) {
      final edge = edges[i];
      edge.index = i;
      // TODO: edge source and target

      count[edge.source.index] += 1;
      count[edge.target.index] += 1;
    }

    bias = List.filled(m, 0);
    for (int i = 0; i < m; i++) {
      final edge = edges[i];
      final totalDegree = count[edge.source.index] + count[edge.target.index];
      bias[i] = count[edge.source.index] / totalDegree;
    }

    strengths = List.filled(m, 0);
    initializeStrength();

    distances = List.filled(m, 0);
    initializeDistance();
  }

  void initializeStrength() {
    if (nodes == null) return;
    for (int i = 0; i < m; i++) strengths[i] = _onStrength(edges[i]);
  }

  void initializeDistance() {
    if (nodes == null) return;
    for (int i = 0; i < m; i++) distances[i] = _onDistance(edges[i]);
  }

  @override
  void initialize(List<N> _nodes, LCG? _random) {
    nodes = _nodes;
    random = _random;
    _initialize();
  }
}
