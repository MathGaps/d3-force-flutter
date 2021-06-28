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
  final N source;
  final N target;
}

class Edges<E extends Edge<N>, N extends Node> extends IForce<N> {
  Edges({
    required this.id,
    AccessorCallback<double, E>? onStrength,
    this.onDistance,
    this.iterations = 1,
    this.distance = 30,
    List<E>? edges,
  })  : distances = [],
        strengths = [],
        count = [],
        bias = [],
        super(strength: 0) {
    this.edges = edges ?? [];

    if (onStrength == null) {
      onStrength = (E edge) {
        return 1 / min(count[edge.source.index], count[edge.target.index]);
      };
    } else {
      this.onStrength = onStrength;
    }
  }

  final String id;
  int iterations;
  double distance;
  late List<E> edges;
  List<double> distances;
  List<double> strengths;
  List<int> count;
  List<double> bias;
  LCG? random;

  late AccessorCallback<double, E> onStrength;
  AccessorCallback<double, E>? onDistance;

  int get m => edges.length;

  @override
  void call([double alpha = 1]) {
    for (int k = 0; k < iterations; k++) {
      for (int i = 0; i < n; i++) {
        final edge = edges[i];
        final N source = edge.source;
        final N target = edge.target;

        double x = target.x + target.vx - source.x - source.vx;
        double y = target.y + target.vy - source.y - source.vy;

        if (random != null) {
          x = x.abs() < eps ? jiggle(random!) : x;
          y = y.abs() < eps ? jiggle(random!) : y;
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

    for (int i = 0; i < m; i++) {
      strengths[i] = onStrength(edges[i]);
    }
  }

  void initializeDistance() {
    if (nodes == null) return;

    for (int i = 0; i < m; i++) {
      distances[i] = onDistance == null ? distance : onDistance!(edges[i]);
    }
  }

  @override
  void initialize(List<N> _nodes, LCG? _random) {
    nodes = _nodes;
    random = _random;
    _initialize();
  }
}
