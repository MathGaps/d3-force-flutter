import '../interfaces/force.dart';
import 'node.dart';

class Center<N extends Node> implements IForce<N> {
  Center({
    this.x = 0,
    this.y = 0,
    double strength = 1,
  }) : _strength = strength;

  @override
  List<N>? nodes;

  double _strength;
  set strength(double strength) => _strength = strength;

  double x, y;

  @override
  void call([double alpha = 1]) {
    double sx = 0;
    double sy = 0;

    for (final node in nodes!) {
      sx += node.x;
      sy += node.y;
    }

    sx = (sx / n - x) * _strength;
    sy = (sy / n - y) * _strength;
    for (final node in nodes!) {
      node.x -= sx;
      node.y -= sy;
    }
  }

  @override
  void initialize(List<N> _nodes, _) {
    nodes = _nodes;
  }
}
