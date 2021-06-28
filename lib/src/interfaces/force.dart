import 'package:d3_force_flutter/src/helpers/lcg.dart';

import '../models/node.dart';

abstract class IForce<N extends Node> {
  IForce._();

  List<N>? nodes;

  external void initialize(List<N> _nodes, LCG? random);
  external void call([double alpha = 1]);
}

extension IForceX<N extends Node> on IForce<N> {
  int get n => nodes?.length ?? 0;
}
