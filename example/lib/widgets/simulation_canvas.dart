import 'dart:math';

import 'package:d3_force_flutter/d3_force_flutter.dart' hide Center;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SimulationCanvas extends MultiChildRenderObjectWidget {
  SimulationCanvas({
    required List<Widget> children,
    Key? key,
  }) : super(children: children, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSimulationCanvas();
  }
}

class SimulationCanvasParentData extends ContainerBoxParentData<RenderBox> {
  SimulationCanvasParentData({
    required this.edges,
    required this.weight,
    required this.constraints,
  });

  List<Edge> edges;
  double weight;
  BoxConstraints constraints;
}

class RenderSimulationCanvas extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SimulationCanvasParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SimulationCanvasParentData> {
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SimulationCanvasParentData) {
      child.parentData = SimulationCanvasParentData(
        edges: [],
        weight: 0,
        constraints: BoxConstraints.tight(Size(0, 0)),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();

    RenderBox? child = firstChild;

    while (child != null) {
      final pd = child.parentData! as SimulationCanvasParentData;
      final edgeOffset = Offset(child.size.width / 2, child.size.height / 2);
      for (final edge in pd.edges) {
        final e = edge.target;
        canvas.drawLine(
          pd.offset + offset + edgeOffset,
          Offset(e.x, e.y) + offset + edgeOffset,
          Paint()
            ..color = Colors.grey.withOpacity(pd.weight)
            ..strokeWidth = 0.75,
        );
      }
      child = pd.nextSibling;
    }

    child = firstChild;
    while (child != null) {
      final pd = child.parentData! as SimulationCanvasParentData;
      context.paintChild(child, pd.offset + offset);
      child = pd.nextSibling;
    }

    canvas.restore();
  }

  @override
  void performLayout() {
    size = _computeLayoutSize(constraints: constraints, dry: false);
  }

  Size _computeLayoutSize({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    RenderBox? child = firstChild;

    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;

      if (!dry) {
        child.layout(
          childParentData.constraints,
          parentUsesSize: true,
        );
      } else {
        child.getDryLayout(childParentData.constraints);
      }

      child = childParentData.nextSibling;
    }

    return constraints.biggest;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;
      height += child.getMinIntrinsicHeight(width);

      child = childParentData.nextSibling;
    }

    return height;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double width = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;
      width = max(width, child.getMaxIntrinsicWidth(height));

      child = childParentData.nextSibling;
    }

    return width;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    double width = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as SimulationCanvasParentData;
      width = max(width, child.getMinIntrinsicWidth(height));

      child = childParentData.nextSibling;
    }

    return width;
  }

  /// Baseline
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
