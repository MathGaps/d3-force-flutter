import 'package:d3_force_flutter/src/models/node.dart';
import 'package:d3_force_flutter/src/models/positioning.dart';
import 'package:d3_force_flutter/src/simulation.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test(
    'forceX centers nodes',
    () {
      final x = XPositioning(x: 200);
      final f = ForceSimulation()..setForce('x', x);
      final a = Node(x: 100, y: 0),
          b = Node(x: 200, y: 0),
          c = Node(x: 300, y: 0);

      f.nodes = [a, b, c];
      f.tick(30);

      print(a);
      assert(a.x > 190);
      assert(a.vx > 0);
      expect(b.x, 200);
      expect(b.vx, 0);
      assert(c.x < 210);
      assert(c.vx < 0);
    },
  );
}
