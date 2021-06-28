import '../interfaces/force.dart';
import '../helpers/accessor.dart';
import '../helpers/lcg.dart';
import 'node.dart';

class Collide<N extends Node> extends IForce<N> {
  Collide({
    this.iterations = 1,
    this.radius = 1,
    double strength = 1,
    AccessorCallback<double, N>? onRadius,
  })  : _radii = [],
        _onRadius = onRadius,
        super(strength: strength);

  final double radius;
  int iterations;
  LCG? random;

  AccessorCallback<double, N>? _onRadius;
  List<double> _radii;
  Quadtree<O> _quadtree;

  set onRadius(AccessorCallback<double, N>? fn) {
    _onRadius = fn;
    _initialize();
  }

  @override
  void call([double alpha = 1]) {
    _quadtree = Quadtree();
  }

  void prepare(Quadtree quad) {}

  void _initialize() {
    if (nodes == null) return;

    _radii = List.filled(n, 0);
    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      _radii[node.index] = _onRadius == null ? radius : _onRadius!(node);
    }
  }

  @override
  void initialize(List<N> _nodes, LCG? _random) {
    nodes = _nodes;
    random = _random;
    _initialize();
  }
}
