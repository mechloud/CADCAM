///////////////////////////////////////////////////////////////////////
//                    Some useful types
///////////////////////////////////////////////////////////////////////
struct Cell {
  int node0;
  int node1;
  int node2;
};

using Node2D = Eigen::Vector2d;
enum class location {vehicle, freestream, road, other};

struct Edge {
  int node0;
  int node1;
  int cell_l;
  int cell_r;
  location locate;
  Node2D fluid_n_hat;
  double l;
};

