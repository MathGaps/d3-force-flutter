import 'package:d3_force_flutter/src/models/center.dart';
import 'package:d3_force_flutter/src/models/collide.dart';
import 'package:d3_force_flutter/src/models/node.dart';
import 'package:d3_force_flutter/src/simulation.dart';
import 'package:test/test.dart';

import 'node_close_to.dart';

void main() {
  test(
    'forceCollide collides nodes',
    () {
      final collide = Collide(radius: 1);
      final f = ForceSimulation()..setForce('collide', collide);
      final a = Node(), b = Node(), c = Node();
      f.nodes = [a, b, c];
      f.tick(10);

      expect(
        a,
        nodeCloseTo(
          Node(index: 0, x: 7.0710678118654755, y: 0, vy: 0, vx: 0),
        ),
      );
      expect(
        b,
        nodeCloseTo(
          Node(
              index: 1,
              x: -9.03088751750192,
              y: 8.27303273571596,
              vy: 0,
              vx: 0),
        ),
      );
      expect(
        c,
        nodeCloseTo(
          Node(
            index: 2,
            x: 1.3823220809823638,
            y: -15.750847141167634,
            vy: 0,
            vx: 0,
          ),
        ),
      );
    },
  );
}
