import 'package:d3_force_flutter/src/models/center.dart';
import 'package:d3_force_flutter/src/models/collide.dart';
import 'package:d3_force_flutter/src/models/node.dart';
import 'package:d3_force_flutter/src/simulation.dart';
import 'package:test/test.dart';

void main() {
  test(
    'forceCollide collides nodes',
    () {
      final collide = Collide(radius: 1);
      final f = ForceSimulation()..setForce('collide', collide);
      final a = Node(), b = Node(), c = Node();
      f.nodes = [a, b, c];
      f.tick(10);

      expect(a, Node(index: 0, x:))

      expect(a, Node(index: 0, x: -100, y: 0, vy: 0, vx: 0));
      expect(b, Node(index: 1, x: 0, y: 0, vy: 0, vx: 0));
      expect(c, Node(index: 2, x: 100, y: 0, vy: 0, vx: 0));
    },
  );
}
