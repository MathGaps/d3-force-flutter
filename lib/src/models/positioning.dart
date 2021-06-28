import '../helpers/accessor.dart';
import '../interfaces/force.dart';
import '../models/node.dart';

class XPositioning<N extends Node> extends IForce<N> {
  XPositioning({
    double x = 0,
    double strength = 0.1,
    this.onStrength,
    this.onX,
  })  : _x = x,
        _strengths = [],
        _xz = [],
        super(strength: strength);

  AccessorCallback<double, N>? onStrength;
  AccessorCallback<double, N>? onX;
  List<double> _strengths;
  List<double> _xz;

  double _x;
  set x(double x) {
    _x = x;
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
      node.vx += (_xz[i] - node.x) * _strengths[i] * alpha;
    }
  }

  void _initialize() {
    _strengths = List.filled(n, 0);
    _xz = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      _xz[i] = onX == null ? _x : onX!(node);
      if (!_x.isNaN)
        _strengths[i] = onStrength == null ? strength : onStrength!(node);
    }
  }

  @override
  void initialize(List<N> _nodes, [_]) {
    nodes = _nodes;
    _initialize();
  }
}

class YPositioning<N extends Node> extends IForce<N> {
  YPositioning({
    double y = 0,
    double strength = 0.1,
    this.onStrength,
    this.onY,
  })  : _y = y,
        _strengths = [],
        _yz = [],
        super(strength: strength);

  AccessorCallback<double, N>? onStrength;
  AccessorCallback<double, N>? onY;
  List<double> _strengths;
  List<double> _yz;

  double _y;
  set y(double y) {
    _y = y;
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
      node.vy += (_yz[i] - node.y) * _strengths[i] * alpha;
    }
  }

  void _initialize() {
    _strengths = List.filled(n, 0);
    _yz = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final node = nodes![i];
      _yz[i] = onY == null ? _y : onY!(node);
      if (!_yz[i].isNaN)
        _strengths[i] = onStrength == null ? strength : onStrength!(node);
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
    _initialize();
  }
}
