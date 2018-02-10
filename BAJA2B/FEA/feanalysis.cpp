#include<iostream>
#include<Eigen/Core>

template<typename T>
auto get_length(const T& x1,const T& y1,
                const T& x2,const T& y2){
  T dx = x2-x1;
  T dy = y2-y1;
  return sqrt(dx*dx + dy*dy);
}

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

};

int main()
{
  auto newsol = Solver<TwoDBeam>();
  newsol.rotate_matrix();
  double len = get_length(2.0, 4.0, 0.0, 0.0);
  std::cout << "Length = " << len << '\n';
  return 0;
}
