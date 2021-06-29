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

      collide.radius = (_) => 100;
      f.tick(10);

      // TODO: these tests fail

      expect(
        a,
        nodeCloseTo(
          Node(
              index: 0,
              x: 174.08616723117228,
              y: 66.51743051995625,
              vy: 0.26976816231064354,
              vx: 0.677346615710878),
        ),
      );
      expect(
          b,
          nodeCloseTo(Node(
              index: 1,
              x: -139.73606544743998,
              y: 95.69860503079263,
              vy: 0.3545632444404687,
              vx: -0.5300880593105067)));
      expect(
          c,
          nodeCloseTo(Node(
              index: 2,
              x: -34.9275994083864,
              y: -169.69384995620052,
              vy: -0.6243314067511122,
              vx: -0.1472585564003713)));
    },
  );

  test(
    'forceCollide respects fixed positions',
    () {
      final collide = Collide(radius: 1);
      final f = ForceSimulation()..setForce('collide', collide);

      final a = Node(fx: 0, fy: 0), b = Node(), c = Node();
      f.nodes = [a, b, c];
      f.tick(10);

      expect(
        a,
        nodeCloseTo(Node(fx: 0, fy: 0, index: 0, x: 0, y: 0, vy: 0, vx: 0)),
      );

      collide.radius = (_) => 100;
      f.tick(10);

      expect(
        a,
        nodeCloseTo(Node(fx: 0, fy: 0, index: 0, x: 0, y: 0, vy: 0, vx: 0)),
      );
    },
  );

  test(
    'forceCollide jiggles equal positions',
    () {
      final collide = Collide(radius: 1);
      final f = ForceSimulation()..setForce('collide', collide);

      final a = Node(x: 0, y: 0), b = Node(x: 0, y: 0);
      f.nodes = [a, b];
      f.tick();

      expect(a.x != b.x, true);
      expect(a.y != b.y, true);
      expect(a.vx, -b.vx);
      expect(a.vy, -b.vy);
    },
  );

  test(
    'forceCollide jiggles in a reproducible way',
    () {
      final nodes = List.generate(10, (index) => Node(x: 0, y: 0));
      ForceSimulation(nodes: nodes)
        ..setForce('collide', Collide())
        ..tick(50);
      expect(
        nodes[0],
        nodeCloseTo(
          Node(
            x: -5.371433857229194,
            y: -2.6644608278592576,
            index: 0,
            vy: 0,
            vx: 0,
          ),
        ),
      );
    },
  );
}
