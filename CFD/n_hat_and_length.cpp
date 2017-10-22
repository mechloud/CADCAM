#include"external.h"

using Node2D = Eigen::Vector2d;

///////////////////////////////////////////////////////////////////////
//                    Simple Geometry stuff
///////////////////////////////////////////////////////////////////////
std::pair<Node2D,double> n_hat_and_length(const Node2D& n0, const Node2D& n1) {
  auto length = (n1-n0).norm();
  Node2D n_hat;
  n_hat.x() =  (n1.y()-n0.y())/length;
  n_hat.y() = -(n1.x()-n0.x())/length;
  return std::make_pair(n_hat, length);
}
