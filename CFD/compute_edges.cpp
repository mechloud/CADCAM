#include<cmath>
#include<Eigen/Core>
#include<iostream>
#include<vector>
#include"external.h"

///////////////////////////////////////////////////////////////////////
//                      Compute Edges
///////////////////////////////////////////////////////////////////////
std::vector<struct Edge> compute_edges(const std::vector<Node2D>& nodes, const std::vector<Cell>& cells,
				       const double& max_x,
				       const double& max_y,
				       const double& min_x,
				       const double& min_y){

  std::cout << "Computing Edges.\n";
  double target = 0.01;
  double tolerance = 1e-6;

  std::vector<struct Edge> edges;

  for(int i = 0; i < cells.size(); ++i) {

    const auto& cell = cells[i];

    auto e = std::find_if(edges.begin(), edges.end(), [&cell] (const Edge& edge) {
        if((cell.node0 == edge.node0) && (cell.node1 == edge.node1)) return true;
        if((cell.node0 == edge.node1) && (cell.node1 == edge.node0)) return true;
        return false;
      });

    if(e != edges.end()) { //it was found
      e->cell_r = i;
    } else { // new edge
      edges.push_back({cell.node0, cell.node1, i, -1, location::other});
    }

    e = std::find_if(edges.begin(), edges.end(), [&cell] (const Edge& edge) {
        if((cell.node1 == edge.node0) && (cell.node2 == edge.node1)) return true;
        if((cell.node1 == edge.node1) && (cell.node2 == edge.node0)) return true;
        return false;
      });

    if(e != edges.end()) { //it was found
      e->cell_r = i;
    } else { // new edge
      edges.push_back({cell.node1, cell.node2, i, -1, location::other});
    }

    e = std::find_if(edges.begin(), edges.end(), [&cell] (const Edge& edge) {
        if((cell.node2 == edge.node0) && (cell.node0 == edge.node1)) return true;
        if((cell.node2 == edge.node1) && (cell.node0 == edge.node0)) return true;
        return false;
      });

    if(e != edges.end()) { //it was found
      e->cell_r = i;
    } else { // new edge
      edges.push_back({cell.node2, cell.node0, i, -1, location::other});
    }

    if(static_cast<double>(i+1)/static_cast<double>(cells.size()) >= target) {
      std::cout << i+1 << "/" << cells.size() << " cells processed.\n";
      std::cout.flush();
      target += 0.01;
    }

  }

  std::cout << "All cells processed.\n";

  //make sure all edges are propoerly aligned
  // (that the unit normal points from cell_l to cell_r)
    
  for(auto& edge: edges) {

    using std::swap;

    const auto edge_centroid = 0.5*(nodes[edge.node0]+nodes[edge.node1]);

    const auto& cell_left = cells[edge.cell_l];
    const auto left_cell_centroid = ( nodes[cell_left.node0]
                                     +nodes[cell_left.node1]
                                     +nodes[cell_left.node2])/3.0;

    const auto vec1 = left_cell_centroid - edge_centroid;

    auto n_hat_l = n_hat_and_length(nodes[edge.node0],nodes[edge.node1]);
    const auto& n_hat = n_hat_l.first;

    if(n_hat.dot(vec1) > 0.0) swap(edge.cell_l, edge.cell_r);
    
    
    //////////////////////////////////////////////////////////
    // Locate Edges in the control volume

    const Node2D& n0 = nodes[edge.node0];
    const Node2D& n1 = nodes[edge.node1];

    if((edge.cell_l == -1) || (edge.cell_r == -1)){
      if((n1.x() > (max_x - tolerance) || (n1.x() < (min_x + tolerance)))){
	// if it is the front or the back, set freestream
	edge.locate = location::freestream;
      }
      else if(n1.y() > (max_y - tolerance)){
	// if it is the top edge, set freestream
	edge.locate = location::freestream;
      }
      else if(n1.y() < (min_y + tolerance)){
	//if it is the bottom edge, reflect values
	edge.locate = location::road;
      }
      else{
	// if it's not a boundary, it's the vehicle
	edge.locate = location::vehicle;	
      }
    }
    else{
      edge.locate = location::other;
    }

  if(edge.locate == location::vehicle){


	const auto edge_centroid = 0.5*(nodes[edge.node0]+nodes[edge.node1]);

	if(edge.cell_r == -1){
	  const auto& cell_left = cells[edge.cell_l];
	  const auto left_cell_centroid = ( nodes[cell_left.node0]
					    +nodes[cell_left.node1]
					    +nodes[cell_left.node2])/3.0;

	  const auto vec2 = left_cell_centroid - edge_centroid;
	  std::tie(edge.fluid_n_hat,edge.l) = n_hat_and_length(nodes[edge.node0], nodes[edge.node1]);
	  
	  
	  if(edge.fluid_n_hat.dot(vec2) > 0.0) edge.fluid_n_hat.x() *= -1.0;
	} 

  }// if statement
  }
  return edges;

}
