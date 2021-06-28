import '../interfaces/force.dart';
import 'node.dart';

class Center<N extends Node> extends IForce<N> {
  Center({
    this.x = 0,
    this.y = 0,
    double strength = 1,
  }) : super(strength: strength);

  double x, y;

  @override
  void call([double alpha = 1]) {
    double sx = 0;
    double sy = 0;

    for (final node in nodes!) {
      sx += node.x;
      sy += node.y;
    }

    sx = (sx / n - x) * strength;
    sy = (sy / n - y) * strength;
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
