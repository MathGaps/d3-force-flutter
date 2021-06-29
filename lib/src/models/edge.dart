import 'dart:math';

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
    this.iterations = 1,
    // int Function(N)? id,
    AccessorCallback<double, E>? onDistance,
    AccessorCallback<double, E>? onStrength,
    double distance = 30,
    List<E>? edges,
  })  : distances = [],
        strengths = [],
        count = [],
        bias = [],
        _edges = edges ?? [] {
    // _id = id ?? (n) => n.index;
    _strength = onStrength ??
        (E edge) =>
            1 / min(count[edge.source.index!], count[edge.target.index!]);
    _distance = onDistance ?? (_) => distance;
  }

  // TODO: make dynamic
  // late int Function(N) _id;
  @override
  List<N>? nodes;
  late List<E> _edges;

  int iterations;
  List<double> distances, strengths, bias;
  List<int> count;
  LCG? random;

  late AccessorCallback<double, E> _strength, _distance;

  set strength(AccessorCallback<double, E> fn) {
    _strength = fn;
    _initialize();
  }

  set distance(AccessorCallback<double, E> fn) {
    _distance = fn;
    _initialize();
  }

  set edges(List<E> edges) {
    _edges = edges;
    this();
  }

  int get m => _edges.length;

  @override
  void call([double alpha = 1]) {
    for (int k = 0; k < iterations; k++) {
      for (int i = 0; i < m; i++) {
        final edge = _edges[i];
        final N source = edge.source;
        final N target = edge.target;

        double x = target.x + target.vx - source.x - source.vx,
            y = target.y + target.vy - source.y - source.vy;

        if (random != null) {
          x == 0 ? jiggle(random!) : x;
          y == 0 ? jiggle(random!) : y;
        }

        double l = sqrt(x * x + y * y);
        l = (l - distances[i]) / l * alpha * strengths[i];
        x *= l;
        y *= l;

        final b = bias[i];
        edge
          ..target.vx -= x * b
          ..target.vy -= y * b
          ..source.vx += x * (1 - b)
          ..source.vy += y * (1 - b);
      }
    }
  }

  void _initialize() {
    if (nodes == null) return;
    count = List.filled(n, 0);
    // final nodeById = {for (final n in nodes!) _id(n): n};

    for (int i = 0; i < m; i++) {
      final edge = _edges[i];
      edge.index = i;
      // edge.source = find(nodebyId, edge.source);
      count[edge.source.index!] += 1;
      count[edge.target.index!] += 1;
    }

    bias = List.filled(m, 0);
    for (int i = 0; i < m; i++) {
      final edge = _edges[i];
      final totalDegree = count[edge.source.index!] + count[edge.target.index!];
      bias[i] = count[edge.source.index!] / totalDegree;
    }

    strengths = List.filled(m, 0);
    initializeStrength();

    distances = List.filled(m, 0);
    initializeDistance();
  }

  void initializeStrength() {
    if (nodes == null) return;
    for (int i = 0; i < m; i++) strengths[i] = _strength(_edges[i]);
  }

  void initializeDistance() {
    if (nodes == null) return;
    for (int i = 0; i < m; i++) distances[i] = _distance(_edges[i]);
  }

  @override
  void initialize(List<N> _nodes, LCG? _random) {
    nodes = _nodes;
    random = _random;
    _initialize();
  }

  // N find(Map<String, N> nodeById, String nodeId) {
  //   final node = nodeById[nodeId];
  //   if (node == null) throw StateError('Node not found: $nodeId');
  //   return node;
  // }
}
