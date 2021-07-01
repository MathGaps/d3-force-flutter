import 'package:d3_force_flutter/d3_force_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class NodeHitTester extends SingleChildRenderObjectWidget {
  const NodeHitTester(
    this.node, {
    required Widget child,
    required this.onDragUpdate,
    required this.onDragEnd,
    Key? key,
  }) : super(key: key, child: child);

  final Node node;

  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderNodeHitTester(
      node,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderNodeHitTester renderObject) {
    renderObject
      ..node = node
      ..onDragUpdate = onDragUpdate
      ..onDragEnd = onDragEnd;
  }
}

class RenderNodeHitTester extends RenderProxyBox {
  RenderNodeHitTester(
    this._node, {
    required GestureDragUpdateCallback onDragUpdate,
    required GestureDragEndCallback onDragEnd,
  })  : _onDragUpdate = onDragUpdate,
        _onDragEnd = onDragEnd;

  late final PanGestureRecognizer _panGestureRecognizer;

  Node _node;
  Node get node => node;
  set node(Node node) {
    if (node == _node) return;
    _node = node;
  }

  GestureDragUpdateCallback _onDragUpdate;
  GestureDragUpdateCallback get onDragUpdate => _onDragUpdate;
  set onDragUpdate(GestureDragUpdateCallback onDragUpdate) {
    if (_onDragUpdate == onDragUpdate) return;
    _panGestureRecognizer.onUpdate = _onDragUpdate = onDragUpdate;
  }

  GestureDragEndCallback _onDragEnd;
  GestureDragEndCallback get onDragEnd => _onDragEnd;
  set onDragEnd(GestureDragEndCallback onDragEnd) {
    if (_onDragEnd == onDragEnd) return;
    _panGestureRecognizer.onEnd = _onDragEnd = onDragEnd;
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);

    _panGestureRecognizer = PanGestureRecognizer(debugOwner: this)
      ..onUpdate = _onDragUpdate
      ..onEnd = _onDragEnd;
  }

  @override
  void detach() {
    _panGestureRecognizer.dispose();
    super.detach();
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (event is PointerDownEvent) {
      _panGestureRecognizer.addPointer(event);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    context.paintChild(child!, offset);
    canvas.restore();
  }
}
