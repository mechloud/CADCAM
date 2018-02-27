#include<iostream>
#include<Eigen/Core>
#include<Eigen/Dense>
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
    
    ss >> n.id >> n.x >> n.y;
    
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
  using vector_type = Eigen::VectorXd;
  static constexpr int number_of_unknowns = 3;

  /////////////////////////////////////////////////
  // Build Rotation Matrix
  /////////////////////////////////////////////////
  template<typename T>
  static matrix_type rotation(const T& l, const T& m){
    matrix_type R;
    R.resize(2*number_of_unknowns,2*number_of_unknowns);
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
    Ke.resize(2*number_of_unknowns,2*number_of_unknowns);
    Ke.fill(0.0);

    Ke(0,0) = A*E/L;
    Ke(0,3) = -A*E/L;

    Ke(1,1) = 12.0*E*I/(L*L*L);
    Ke(1,2) = 6.0*E*I/(L*L);
    Ke(1,4) = -Ke(1,1);
    Ke(1,5) = Ke(1,2);

    Ke(2,1) = Ke(1,2);
    Ke(2,2) = 4.0*E*I/L;
    Ke(2,4) = -Ke(1,2);
    Ke(2,5) = 0.5*Ke(2,2);

    Ke(3,0) = -Ke(0,0);
    Ke(3,3) = Ke(0,0);
    
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

  static vector_type force_vector(const double& m, const int& n){
    vector_type F(n*number_of_unknowns);   
    F.fill(0.0);
    // Might need to double check this, should be 5,8,12 and 13 according to MATLAB
    F(4*number_of_unknowns) = 20818.0;
    F(11*number_of_unknowns) = 20818.0;
    F(12*number_of_unknowns + 1) = -m * 9.81;
    F(7*number_of_unknowns + 1) = -26.0 * 9.81;
    
    return F;
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

    //std::cout << "x1 " << x1 << "\ty1 " << y1 << "\t\tx2 " << x2 << "\ty2 " << y2 << '\n'; 

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
  T PID = 19;
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

  auto SolveSystem (const std::vector<Node>& nodes, const std::vector<Element>& elements){
    auto Ka = preprocessing(nodes,elements);
    std::tie(U,F) = solve(Ka,nodes.size());
    auto SF = postprocessing(U,elements);

    return 69;
  }

  
  auto preprocessing(const std::vector<Node>& nodes,const std::vector<Element>& elements){

    operations<double> op;

    typename Equations::matrix_type rotated;
    typename Equations::matrix_type assembled;

    int nnodes = nodes.size();
    int nelements = elements.size();
    static constexpr int block_size = Equations::number_of_unknowns;
    int ka_size = nnodes * block_size;
    Ka.resize(ka_size,ka_size);
    Ka.fill(0.0);

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
      std::cout << "L[" << i << "] = " << L[i] << '\n';
      l.push_back((xj-xi)/L[i]);
      m.push_back((yj-yi)/L[i]);

      // Get rotation matrices
      R.push_back(Equations::rotation(l[i],m[i]));

      // Get local stiffness matrix
      Eigen::MatrixXd Ke_prime = Equations::stiffness(op.area(POD,PID),E,L[i],op.inertia(POD,PID));

      // Compute global stiffness matrix
      Ke.push_back(R[i].transpose() * Ke_prime * R[i]);

      // For indexing assemblage matrix
      int ni = block_size*(nodei - 1);
      int nj = block_size*(nodej - 1);

      Ka.block<block_size,block_size>(ni,ni) = Ke[i].block<block_size,block_size>(0,0);
      Ka.block<block_size,block_size>(ni,nj) = Ke[i].block<block_size,block_size>(0,block_size);
      Ka.block<block_size,block_size>(nj,ni) = Ke[i].block<block_size,block_size>(block_size,0);
      Ka.block<block_size,block_size>(nj,nj) = Ke[i].block<block_size,block_size>(block_size,block_size);
    }
    return Ka;
  }

  auto solve(Eigen::MatrixXd Ka,const int& nnodes){

    double beta = 10e9*Ka.maxCoeff();
    //std::cout << Ka << '\n';
    
    Eigen::MatrixXd Ka_sol = Ka;
    Ka_sol(15,15) += beta;
    Ka_sol(16,16) += beta;

    Ka_sol(18,18) += beta;
    Ka_sol(19,19) += beta;

    F = Equations::force_vector(md,nnodes);

    U = Ka_sol.inverse() * F;

    return std::make_pair(F,U);
  }

  auto postprocessing(Eigen::MatrixXd U,const std::vector<Element> elements){

    epsilon.resize(elements.size());
    
    for(int i = 0; i < elements.size(); ++i){
      
      int ni = elements[i].node0;
      int nj = elements[i].node1;

      // Nodal displacements
      double ui = U(Equations::number_of_unknowns*ni - 3);
      double vi = U(Equations::number_of_unknowns*ni - 2);
      double uj = U(Equations::number_of_unknowns*nj - 3);
      double vj = U(Equations::number_of_unknowns*nj - 2);
      
      double ui_prime = l[i]*ui + m[i]*vi;
      double uj_prime = l[i]*uj + m[i]*vj;

      // Elongation and strain
      double delta = uj_prime - ui_prime;
      epsilon(i) = delta/L[i];
    } // end loop through elements

    // Axial stress
    Eigen::VectorXd axial = E*epsilon;

    std::cout << "Axial stress\n\n" << axial << '\n';
    return axial.maxCoeff();
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
  Eigen::MatrixXd              Ka;
  Eigen::VectorXd              U;
  Eigen::VectorXd              F;
  Eigen::VectorXd              epsilon;
  double POD = 25.4;
  double PID = 19.0;
  double SOD = 25.4;
  double SID = 20.638;
  double md  = 110;

};

int main()
{

#ifdef TESTING
  double POD = 25.4;
  double PID = 19.0;
  double SOD = 25.4;
  double SID = 20.638;
  double md  = 110;
#endif
 
#ifdef TESTING
    std::vector<Node> nodes;
    std::vector<Element> elements;
    std::string nodal_filename = "nodes.csv";
    std::string elemental_filename = "elements.csv";
    std::tie(nodes,elements) = read_csv(nodal_filename,elemental_filename);
#endif

    auto newsol = Solver<TwoDBeam>(POD,PID,SOD,SID,md);
    auto SF = newsol.SolveSystem(nodes,elements);
    
  return 0;
}
