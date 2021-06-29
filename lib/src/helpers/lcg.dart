// https://en.wikipedia.org/wiki/Linear_congruential_generator#Parameters_in_common_use
const int a = 1664525;
const int c = 1013904223;
const int m = 4294967296; // 2^32

final lcg = LCG();

class LCG {
  LCG([this.x = 1]);
  double x;

  double call() => (x = (a * x + c) % m) / m;
}
