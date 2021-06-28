import 'package:d3_force_flutter/src/lcg.dart';

import 'node.dart';

abstract class IForce<N extends Node> {
  IForce({required double strength}) : strength = strength;

  List<N>? nodes;

  double strength;

  int get n => nodes?.length ?? 0;

  void initialize(List<N> _nodes, LCG? random);
  void call([double alpha = 1]);
}
