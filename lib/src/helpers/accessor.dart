typedef AccessorCallback<R, T> = R Function(T);

//? Unused but may reimplement
class Accessor<R, T> {
  const Accessor(this.accessor, {this.callback});

  final AccessorCallback<R, T> accessor;
  final Function()? callback;

  R call(T t, {bool shouldRebuild = true}) {
    final r = accessor(t);
    if (callback != null && shouldRebuild) callback!();
    return r;
  }
}
