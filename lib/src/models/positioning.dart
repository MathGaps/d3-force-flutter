import '../helpers/accessor.dart';
import '../interfaces/force.dart';
import '../models/node.dart';

class XPositioning<N extends Node> implements IForce<N> {
  XPositioning({
    double x = 0,
    double strength = 0.1,
    AccessorCallback<double, N>? onStrength,
    AccessorCallback<double, N>? onX,
  })  : _strengths = [],
        _xz = [] {
    _strength = onStrength ?? (_) => strength;
    _x = onX ?? (_) => x;
  }

  late AccessorCallback<double, N> _strength, _x;
  set strength(AccessorCallback<double, N> fn) {
    _strength = fn;
    _initialize();
  }

  set x(AccessorCallback<double, N> fn) {
    _x = fn;
    _initialize();
  }

  @override
  List<N>? nodes;
  List<double> _strengths, _xz;

  @override
  void call([double alpha = 1]) {
    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      node.vx += (_xz[i] - node.x) * _strengths[i] * alpha;
    }
  }

  void _initialize() {
    _strengths = List.filled(n, 0);
    _xz = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      if (!(_xz[i] = _x(node)).isNaN) _strengths[i] = _strength(node);
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
    _initialize();
  }
}

class YPositioning<N extends Node> implements IForce<N> {
  YPositioning({
    double y = 0,
    double strength = 0.1,
    AccessorCallback<double, N>? onStrength,
    AccessorCallback<double, N>? onY,
  })  : _strengths = [],
        _yz = [] {
    _onStrength = onStrength ?? (_) => strength;
    _onY = onY ?? (_) => y;
  }

  late AccessorCallback<double, N> _onStrength, _onY;
  set onStrength(AccessorCallback<double, N> fn) {
    _onStrength = fn;
    _initialize();
  }

  set onY(AccessorCallback<double, N> fn) {
    _onY = fn;
    _initialize();
  }

  @override
  List<N>? nodes;
  List<double> _strengths, _yz;

  @override
  void call([double alpha = 1]) {
    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      node.vy += (_yz[i] - node.y) * _strengths[i] * alpha;
    }
  }

  void _initialize() {
    _strengths = List.filled(n, 0);
    _yz = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      if (!(_yz[i] = _onY(node)).isNaN) _strengths[i] = _onStrength(node);
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
    _initialize();
  }
}
