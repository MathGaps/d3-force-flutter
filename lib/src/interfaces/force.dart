import 'package:d3_force_flutter/src/helpers/lcg.dart';

import '../models/node.dart';

abstract class IForce<N extends Node> {
  IForce({required double strength}) : strength = strength;

  List<N>? nodes;

  double strength;

  int get n => nodes?.length ?? 0;

  void initialize(List<N> _nodes, LCG? random);
  void call([double alpha = 1]);
}
