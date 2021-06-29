import 'package:d3_force_flutter/src/models/node.dart';
import 'package:d3_force_flutter/src/simulation.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test(
    'simulation.find finds a node',
    () {
      final f = ForceSimulation();
      final a = Node(x: 5, y: 0),
          b = Node(x: 10, y: 16),
          c = Node(x: -10, y: -4);
      f.nodes = [a, b, c];

      expect(f.find(0, 0), a);
      expect(f.find(0, 20), b);
    },
  );

  test(
    'simulation.find(x, y, radius) finds a node within radius',
    () {
      final f = ForceSimulation();
      final a = Node(x: 5, y: 0),
          b = Node(x: 10, y: 16),
          c = Node(x: -10, y: -4);
      f.nodes = [a, b, c];

      expect(f.find(0, 0), a);
      expect(f.find(0, 0, 1), null);
      expect(f.find(0, 20), b);
    },
  );
}
