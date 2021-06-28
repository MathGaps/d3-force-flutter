import 'package:d3_quadtree_flutter/d3_quadtree_flutter.dart';

class ForcePoint implements IPoint {
  ForcePoint(this.x, this.y, {this.index});

  @override
  double x, y;
  int? index;

  @override
  ForcePoint get copy => ForcePoint(x, y, index: index);

  @override
  bool get isNaN => x.isNaN || y.isNaN;
}
