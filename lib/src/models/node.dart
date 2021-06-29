import 'package:d3_quadtree_flutter/d3_quadtree_flutter.dart';
import 'package:quiver/core.dart';

class Node implements IPoint {
  Node({
    this.x = double.nan,
    this.y = double.nan,
    this.index,
    this.vx = 0,
    this.vy = 0,
  }) {
    if (vx.isNaN) vx = 0;
    if (vy.isNaN) vy = 0;
  }

  int? index;
  double x, y, vx, vy;
  double? fx, fy;

  @override
  Node get copy => Node(x: x, y: y, index: index, vx: vx, vy: vy);
  @override
  bool get isNaN => throw UnimplementedError();

  @override
  bool operator ==(Object o) =>
      o is Node &&
      x == o.x &&
      y == o.y &&
      index == o.index &&
      vx == o.vx &&
      vy == o.vy;
  @override
  int get hashCode => hashObjects([x, y, index, vx, vy]);
  @override
  String toString() {
    return {
      'index': index,
      'position': '($x, $y)',
      'velocity': '($vx, $vy)',
    }.toString();
  }
}
