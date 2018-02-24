#include<iostream>
#include<Eigen/Core>
#include<math.h> // needed for M_PI in operations class
#include<string>
#include<sstream>
#include<fstream>
#include<algorithm>

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
    return sqrt(dx*dx + dy*dy);
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

  void rotate_matrix(){
    double l = 2.0;
    double m = 5.0;

    typename Equations::matrix_type rotated;
    typename Equations::matrix_type assembled;

    rotated = Equations::rotation(l,m);
    std::cout << "Rotation matrix\n" << rotated << '\n';

    assembled = Equations::stiffness(1.0,2.0,3.0,1.0);
    std::cout << "Assemblage matrix\n" << assembled << '\n';
  }

private:
  double E  = 205e3; // MPa
  double Sy = 435;   // MPa

};

auto read_csv(const std::string& nodal, std::string& elemental){

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
  
} // end read_csv function


int main()
{
  auto newsol = Solver<TwoDBeam>();
  newsol.rotate_matrix();
  auto operators = operations<double>();
  
  double len = operators.get_length(2.0, 4.0, 0.0, 0.0);
  std::cout << "Length = " << len << '\n';
  
  double area = operators.area(25.4,19.304);
  std::cout << "Area = " << area << '\n';
  
  double inertia = operators.inertia(25.4,19.304);
  std::cout << "Inertia = " << inertia << '\n';

  std::string nodal_filename = "nodes.csv";
  std::string elemental_filename = "elements.csv";
  read_csv(nodal_filename,elemental_filename);
  
  return 0;
}
