#include<iostream>
#include<Eigen/Core>
#include<math.h> // needed for M_PI in operations class
#include<string>
#include<sstream>
#include<fstream>
#include<algorithm>

#define TESTING

struct Node{
  int id;
  double x;
  double y;
  double z;
};

struct Element{
  int id;
  int node0;
  int node1;
  int matflag;
};

auto read_csv(const std::string& nodal, const std::string& elemental){

  std::ifstream nin(nodal);
  if(!nin){
    throw std::runtime_error("Cannot open : " + nodal + ".");
  }

  std::ifstream ein(elemental);
  if(!ein){
    throw std::runtime_error("Cannot open : " + elemental + ".");
  }
  
  std::vector<Node> nodes;
  std::vector<Element> elements;

  int nnodes;
  nin >> nnodes;
  
  for (int i = 0; i < nnodes; ++i){

    std::string s;
    do {
      std::getline(nin,s);
      std::replace(s.begin(),s.end(),',',' ');
    } while (s.empty());

    std::istringstream ss(s);

    Node n;
    
    ss >> n.id >> n.x >> n.y >> n.z;
    
    // if (fabs(n.y) > 1.0e-12){
    //   throw std::runtime_error("Error, node has y component. Code is not ready for 3D analysis yet.");
    // }

    nodes.push_back(n);
    
  } // end loop through nodes

  int nelements;
  ein >> nelements;

  for (int i = 0; i < nelements; ++i){

    std::string s;
    do {
      std::getline(ein,s);
      std::replace(s.begin(),s.end(),',',' ');
    }while (s.empty());

    std::istringstream ss(s);
    
    Element e;

    ss >> e.id >> e.node0 >> e.node1 >> e.matflag;

    if (e.id != (i + 1)){
      throw std::runtime_error("Error reading element number");
    }

    if (e.matflag == 0){
      throw std::runtime_error("Error reading material type for element number " + std::to_string(e.id) + ".");      
    }

    elements.push_back(e);
    
  } // end loop through elements

  return std::make_pair(nodes,elements);
  
} // end read_csv function

class TwoDBeam {
public:

  using matrix_type = Eigen::MatrixXd;
  static constexpr int number_of_unknowns = 6;

  /////////////////////////////////////////////////
  // Build Rotation Matrix
  /////////////////////////////////////////////////
  template<typename T>
  static matrix_type rotation(const T& l, const T& m){
    matrix_type R;
    R.resize(number_of_unknowns,number_of_unknowns);
    R.fill(0.0);

    R(0,0) = l;
    R(0,1) = m;
    
    R(1,0) = -m;
    R(1,1) = l;
    
    R(2,2) = 1;
    
    R(3,3) = l;
    R(3,4) = m;
    
    R(4,3) = -m;
    R(4,4) = l;
    
    R(5,5) = 1;

    return R;
  }

  /////////////////////////////////////////////////
  // Build Stiffness Matrix
  /////////////////////////////////////////////////
  template<typename T>
  static matrix_type stiffness(const T& A, const T& E, const T& L, const T& I){
    
    matrix_type Ke;
    Ke.resize(number_of_unknowns,number_of_unknowns);
    Ke.fill(0.0);

    Ke(0,0) = A*E/L;
    Ke(0,3) = -A*E/L;

    Ke(1,1) = 12.0*E*I/(L*L*L);
    Ke(1,2) = 6.0*E*I/(L*L);
    Ke(1,4) = -Ke(1,1);
    Ke(1,5) = -Ke(1,2);

    Ke(2,1) = Ke(1,2);
    Ke(2,2) = 4.0*E*I/L;
    Ke(2,4) = -Ke(1,2);
    Ke(2,5) = 0.5*Ke(2,2);

    Ke(3,0) = -Ke(0,0);
    Ke(3,3) = -Ke(0,3);
    
    Ke(4,1) = -Ke(1,1);
    Ke(4,2) = -Ke(1,2);
    Ke(4,4) = Ke(1,1);
    Ke(4,5) = -Ke(1,2);

    Ke(5,1) = Ke(1,2);
    Ke(5,2) = Ke(2,5);
    Ke(5,4) = -Ke(1,2);
    Ke(5,5) = Ke(2,2);

    return Ke;
  }

}; // End TwoDBeam class

template<typename T>
class operations {
public:
  
  operations() = default;
  operations(const operations&) = default;
  operations(operations&&) = default;
  // operations& operator = (const operations&) = default;
  // operations& operator = (const operations&&) = default;
  
  operations(T POD_in, T PID_in, T SOD_in, T SID_in, T md_in) :
    POD(POD_in),
    PID(PID_in),
    SOD(SOD_in),
    SID(SID_in),
    md(md_in)
  {};

  //operations& operator=(const operations&) = default;
  //operations& operator=(operations&&) = default;

  // Returns the length between two nodes
  template<typename TT0>
  auto get_length(const TT0& x1,const TT0& y1,
		  const TT0& x2,const TT0& y2){
    TT0 dx = x2-x1;
    TT0 dy = y2-y1;
    TT0 L = sqrt(dx*dx + dy*dy);

    if(L <= 0){
      throw std::runtime_error("Zero-length or negative length element");
    } else {
      return L;
    }
  }

  // Returns the cross sectional area of a tubular section
  template<typename TT0>
  auto area(const TT0& od, const TT0& id){
    return (M_PI/4)*(od*od - id*id);
  }

  template<typename TT0>
  auto inertia(const TT0& od, const TT0& id){
    return (M_PI/64)*(od*od*od*od - id*id*id*id);
  }

  
private:
  T POD = 25.4;
  T PID = 19.304;
  T SOD = 25.4;
  T SID = 20.638;
  T md  = 110;
};

template<typename Equations>
class Solver {
public:
  
  Solver() = default;
  Solver(const Solver&) = default;
  Solver(Solver&&) = default;
  Solver& operator=(const Solver&) = default;
  Solver& operator=(Solver&&) = default;

  Solver(double POD_in, double PID_in, double SOD_in, double SID_in, double md_in) :
    POD(POD_in),
    PID(PID_in),
    SOD(SOD_in),
    SID(SID_in),
    md(md_in)
  {};

  
  void preprocessing(const std::vector<Node>& nodes,const std::vector<Element>& elements){

    operations<double> op;

    typename Equations::matrix_type rotated;
    typename Equations::matrix_type assembled;

    double nelements = elements.size();
    R.resize(nelements);
    Ke.resize(nelements);

    for (int i = 0; i < nelements; ++ i){

      // Find nodes corresponding to element i
      int nodei = elements[i].node0;
      int nodej = elements[i].node1;

      // Find nodal coordinates for nodes i and j for element i 
      double xi = nodes[nodei].x;
      double yi = nodes[nodei].y;
      double xj = nodes[nodej].x;
      double yj = nodes[nodej].y;

      // Get length and find direction cosines
      L.push_back(op.get_length(xi,yi,xj,yj));
      l.push_back((xj-xi)/L[i]);
      m.push_back((yj-yi)/L[i]);

      // Get rotation matrices
      R[i] = Equations::rotation(l[i],m[i]);

      // Get local stiffness matrix;
      Eigen::MatrixXd Ke_prime = Equations::stiffness(op.area(POD,PID),E,L[i],op.inertia(POD,PID));

      Ke[i] = R[i].transpose() * Ke_prime * R[i];

      std::cout << Ke[i] << "\n\n";
    }

  }

private:
  double                       E  = 205e3; // MPa
  double                       Sy = 435;   // MPa
  std::vector<Node>            nodes;
  std::vector<Element>         elements;
  std::vector<double>          L;
  std::vector<double>          l;
  std::vector<double>          m;
  std::vector<Eigen::MatrixXd> R;
  std::vector<Eigen::MatrixXd> Ke;
  double POD = 25.4;
  double PID = 19.304;
  double SOD = 25.4;
  double SID = 20.638;
  double md  = 110;
  
  /*
  struct Node{
    int id;
    double x;
    double y;
    double z;
  };
  
  struct Element{
    int id;
    int node0;
    int node1;
    int matflag;
  };
  */

};



int main()
{

#ifdef TESTING
  double POD = 25.4;
  double PID = 19.304;
  double SOD = 25.4;
  double SID = 20.638;
  double md  = 110;

  auto newsol = Solver<TwoDBeam>(POD,PID,SOD,SID,md);
#else
  auto newsol = Solver<TwoDBeam>();
#endif
 
#ifdef TESTING
    std::vector<Node> nodes;
    std::vector<Element> elements;
    std::string nodal_filename = "nodes.csv";
    std::string elemental_filename = "elements.csv";
    std::tie(nodes,elements) = read_csv(nodal_filename,elemental_filename);
#endif

    newsol.preprocessing(nodes,elements);
    auto operators = operations<double>();

  return 0;
}
