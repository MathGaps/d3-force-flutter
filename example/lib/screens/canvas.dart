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
  int i = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final size = MediaQuery.of(context).size;

    final nodes = List.generate(
      100,
      (index) => f.Node(
        x: size.width / 2,
        y: size.height / 2,
      ),
    );
    final r = Random();
    edges = [
      for (final n in nodes)
        if (r.nextDouble() < 0.8) ...[
          for (int i = 0; i < (r.nextDouble() * 3).toInt(); i++)
            f.Edge(
              source: n,
              target: nodes[(nodes.length * r.nextDouble()).toInt()],
            ),
        ]
    ];
    simulation = f.ForceSimulation()
      ..nodes = nodes
      // ..setForce('collide', f.Collide(radius: 10))
      // ..setForce('radial', f.Radial(radius: 400))
      ..setForce('manyBody', f.ManyBody())
      // ..setForce(
      //     'center', f.Center(size.width / 2, size.height / 2, strength: 0.5))
      ..setForce(
        'edges',
        f.Edges(edges: edges, distance: 15),
      )
      ..setForce('x', f.XPositioning(x: size.width / 2))
      ..setForce('y', f.YPositioning(y: size.height / 2))
      ..alpha = 1;

    _ticker = this.createTicker((_) {
      i++;
      // if (i % 10 != 0) return;
      setState(() {
        simulation.tick();
      });
    })
      ..start();
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(size),
          child: SimulationCanvas(
            children: [
              for (final node in simulation.nodes)
                if (!node.isNaN)
                  SimulationCanvasObject(
                    constraints: BoxConstraints.tight(Size(10, 10)),
                    node: node,
                    edges: [...edges.where((e) => e.source == node)],
                    child: NodeHitTester(
                      node,
                      onDragUpdate: (update) {
                        node
                          ..fx = update.globalPosition.dx
                          ..fy = update.globalPosition.dy;
                        simulation..alpha = 1;
                      },
                      onDragEnd: (_) {
                        node
                          ..fx = null
                          ..fy = null;
                      },
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
