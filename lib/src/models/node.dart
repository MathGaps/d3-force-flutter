import 'package:d3_quadtree_flutter/d3_quadtree_flutter.dart';

class Node implements IPoint {
  Node({
    required this.index,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
  }) {
    if (vx.isNaN) vx = 0;
    if (vy.isNaN) vy = 0;
  }

  int index;
  double x, y, vx, vy;
  double? fx, fy;

  @override
  Node get copy => Node(x: x, y: y, index: index, vx: vx, vy: vy);
  @override
  bool get isNaN => throw UnimplementedError();
}
