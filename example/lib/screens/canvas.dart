import 'dart:math';

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

    final nodes = List.generate(100, (index) => f.Node());
    final r = Random();
    edges = [
      for (final n in nodes)
        if (r.nextDouble() < 0.6) ...[
          for (int i = 0; i < (r.nextDouble() * 5).toInt(); i++)
            f.Edge(
              source: n,
              target: nodes[(nodes.length * r.nextDouble()).toInt()],
            ),
        ]
    ];
    simulation = f.ForceSimulation()
      ..nodes = nodes
      ..setForce('collide', f.Collide(radius: 5))
      ..setForce('manyBody', f.ManyBody())
      ..setForce(
        'edges',
        f.Edges(edges: edges, distance: 15),
      )
      ..alpha = 1
      ..tick(10);

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
    return Scaffold(
      body: Center(
        child: SimulationCanvas(
          children: [
            for (final node in simulation.nodes)
              if (!node.isNaN)
                SimulationCanvasObject(
                  node: node,
                  edges: [...edges.where((e) => e.source == node)],
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
