module tcm.randplus;
import std.stdio, std.random;

int rand(int digits){
  auto rnd = Random(unpredictableSeed);
  auto a = uniform(0, digits+1, rnd);
  return a;
}

int randrange(int start, int limit){
  auto rnd = Random(unpredictableSeed);
  auto a = uniform(start, limit+1, rnd);
  return a;
}
