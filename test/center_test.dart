import 'package:d3_force_flutter/src/models/center.dart';
import 'package:d3_force_flutter/src/models/node.dart';
import 'package:d3_force_flutter/src/simulation.dart';
import 'package:test/test.dart';

void main() {
  test(
    'forceCenter repositions nodes',
    () {
      final force = Center(0, 0);
      final f = ForceSimulation()..setForce('center', force);
      final a = Node(x: 100, y: 0),
          b = Node(x: 200, y: 0),
          c = Node(x: 300, y: 0);

      f.nodes = [a, b, c];
      f.tick();

      expect(a, Node(index: 0, x: -100, y: 0, vy: 0, vx: 0));
      expect(b, Node(index: 1, x: 0, y: 0, vy: 0, vx: 0));
      expect(c, Node(index: 2, x: 100, y: 0, vy: 0, vx: 0));
    },
  );
}
