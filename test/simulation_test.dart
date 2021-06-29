import 'package:d3_force_flutter/src/models/node.dart';
import 'package:d3_force_flutter/src/simulation.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'node_close_to.dart';

void main() {
  test(
    'ForceSimulation()..nodes = nodes initializes a simulation wiht indices & phyllotaxis positions, 0 speed',
    () {
      final f = ForceSimulation();
      final a = Node(), b = Node(), c = Node();
      f.nodes = [a, b, c];

      expect(
        a,
        nodeCloseTo(Node(index: 0, x: 7.0710678118654755, y: 0, vy: 0, vx: 0)),
      );
      expect(
        b,
        nodeCloseTo(Node(
            index: 1, x: -9.03088751750192, y: 8.27303273571596, vy: 0, vx: 0)),
      );
      expect(
        c,
        nodeCloseTo(Node(
            index: 2,
            x: 1.3823220809823638,
            y: -15.750847141167634,
            vy: 0,
            vx: 0)),
      );
    },
  );
}
