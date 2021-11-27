import 'dart:math';

import 'package:example/widgets/node_hit_test.dart';
import 'package:example/widgets/simulation_canvas.dart';
import 'package:example/widgets/simulation_canvas_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:d3_force_flutter/d3_force_flutter.dart' as f;

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({Key? key}) : super(key: key);

  @override
  _CanvasScreenState createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final f.ForceSimulation simulation;
  late final List<f.Edge> edges;
  late final List<int> edgeCounts;
  int maxEdgeCount = 0;
  int i = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final size = MediaQuery.of(context).size;

    final nodes = List.generate(
      140,
      (index) => f.Node(),
    );
    final r = Random();
    edges = [
      for (final n in nodes)
        if (r.nextDouble() < 0.8) ...[
          for (int i = 0; i < (r.nextDouble() * 5).toInt(); i++)
            f.Edge(
              source: n,
              target: nodes[(nodes.length * r.nextDouble()).toInt()],
            ),
        ]
    ];

    simulation = f.ForceSimulation(
      phyllotaxisX: size.width / 2,
      phyllotaxisY: size.height / 2,
      phyllotaxisRadius: 20,
    )
      ..nodes = nodes
      ..setForce('collide', f.Collide(radius: 10))
      // ..setForce('radial', f.Radial(radius: 400))
      ..setForce('manyBody', f.ManyBody(strength: -40))
      // ..setForce(
      //     'center', f.Center(size.width / 2, size.height / 2, strength: 0.5))
      ..setForce(
        'edges',
        f.Edges(edges: edges, distance: 30),
      )
      ..setForce('x', f.XPositioning(x: size.width / 2))
      ..setForce('y', f.YPositioning(y: size.height / 2))
      ..alpha = 1;

    _ticker = this.createTicker((_) {
      i++;
      // if (i% 10 != 0) return;
      setState(() {
        simulation.tick();
      });
    })
      ..start();

    edgeCounts = List.filled(nodes.length, 0);
    for (int i = 0; i < edges.length; i++) {
      final edge = edges[i];
      edge.index = i;
      edgeCounts[edge.source.index!] += 1;
      edgeCounts[edge.target.index!] += 1;
    }
    for (final count in edgeCounts) {
      if (count > maxEdgeCount) maxEdgeCount = count;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void startTicker() => _ticker..start();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(size),
          child: SimulationCanvas(
            children: [
              for (final node in simulation.nodes)
                if (!node.isNaN)
                  Builder(builder: (context) {
                    final double weight = maxEdgeCount == 0
                        ? 0
                        : edgeCounts[node.index!] / maxEdgeCount;
                    return SimulationCanvasObject(
                      weight: weight,
                      constraints: BoxConstraints.tight(Size(10, 10)),
                      node: node,
                      edges: [...edges.where((e) => e.source == node)],
                      child: NodeHitTester(
                        node,
                        onDragUpdate: (update) {
                          node
                            ..fx = update.globalPosition.dx
                            ..fy = update.globalPosition.dy;
                          simulation..alphaTarget = 0.5;
                        },
                        onDragEnd: (_) {
                          node
                            ..fx = null
                            ..fy = null;
                          simulation.alphaTarget = 0;
                        },
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            color: Colors.white.withOpacity(sqrt(weight)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
