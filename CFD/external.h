#include<Eigen/Core>
#include"types.h"

using Node2D = Eigen::Vector2d;

void splitTime(const int, double*);

std::vector<struct Edge> compute_edges(const std::vector<Node2D>&, const std::vector<Cell>&,
				       const double& max_x,
				       const double& max_y,
				       const double& min_x,
				       const double& min_y);

std::pair<Node2D,double> n_hat_and_length(const Node2D&, const Node2D&);
