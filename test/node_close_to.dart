import 'package:d3_force_flutter/src/models/node.dart';
import 'package:test/test.dart';

Matcher nodeCloseTo<N extends Node>(N value, [double delta = 1e-6]) =>
    _NodeCloseTo(value, delta);

class _NodeCloseTo<N extends Node> extends FeatureMatcher<N> {
  final N _n;
  final double _delta;

  const _NodeCloseTo(this._n, this._delta);

  @override
  bool typedMatches(N o, Map matchState) {
    return o.index == _n.index &&
        (o.x - _n.x).abs() < _delta &&
        (o.y - _n.y).abs() < _delta &&
        (o.vx - _n.vx).abs() < _delta &&
        (o.vy - _n.vy).abs() < _delta &&
        ((o.fx ?? 0) - (_n.fx ?? 0)).abs() < _delta &&
        ((o.fy ?? 0) - (_n.fy ?? 0)).abs() < _delta;
  }

  @override
  Description describe(Description description) => description
      .add('a node with numeric properties ')
      .addDescriptionOf({
        'index': _n.index,
        'x': _n.x,
        'y': _n.y,
        'vx': _n.vx,
        'vy': _n.vy,
        'fx': _n.fx,
        'fy': _n.fy,
      })
      .add(' within the range ')
      .addDescriptionOf(_delta);

  @override
  Description describeTypedMismatch(
      N o, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.add(' differs by ').addDescriptionOf({
      'x': o.x - _n.x,
      'y': o.y - _n.y,
      'vx': o.vx - _n.vx,
      'vy': o.vy - _n.vy,
      'fx': (o.fx ?? 0) - (_n.fx ?? 0),
      'fy': (o.fy ?? 0) - (_n.fy ?? 0),
    });
  }
}

//! Private class pulled from test library
abstract class FeatureMatcher<T> extends TypeMatcher<T> {
  const FeatureMatcher();

  @override
  bool matches(item, Map matchState) =>
      super.matches(item, matchState) && typedMatches(item as T, matchState);

  bool typedMatches(T item, Map matchState);

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is T) {
      return describeTypedMismatch(
          item, mismatchDescription, matchState, verbose);
    }

    return super.describe(mismatchDescription.add('not an '));
  }

  Description describeTypedMismatch(T item, Description mismatchDescription,
          Map matchState, bool verbose) =>
      mismatchDescription;
}
