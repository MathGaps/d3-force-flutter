class Node {
  Node({
    required this.index,
    required this.x,
    required this.y,
    this.vx = 0,
    this.vy = 0,
  }) {
    if (vx.isNaN) vx = 0;
    if (vy.isNaN) vy = 0;
  }

  int index;
  double x, y, vx, vy;
  double? fx, fy;
}
