///////////////////////////////////////////////////////////////////////
//                      Euler Equations
///////////////////////////////////////////////////////////////////////

class EulerEquations {
public:

  using Node2D = Eigen::Vector2d;
  using Vector_type = Eigen::Vector4d;
  static constexpr int number_of_unknowns = 4;

  ////////////////////////////////////
  // density of the air
  template<typename Vec_in>
  static double rho(const Vec_in& U){
    return U[0];
  }

  ////////////////////////////////////
  // ux
  template<typename Vec_in>
  static double ux(const Vec_in& U){
    return U[1]/U[0];
  }

  ////////////////////////////////////
  // uy
  template<typename Vec_in>
  static double uy(const Vec_in& U){
    return U[2]/U[0];
  }

  ////////////////////////////////////
  // pressure
  template<typename Vec_in>
  static double p(const Vec_in& U){
    return (U[3] - 0.5*(U[1]*U[1]+U[2]*U[2])/U[0])*(k-1);
  }
 
  ////////////////////////////////////
  //  Flux x
  template<typename Vec_in>
  static Vector_type Fx(const Vec_in& U) {
    Vector_type F;
    auto u_x = ux(U);
    auto u_y = uy(U);
    auto pressure = p(U);
    auto dens = rho(U);
    F[0] = U[1];
    F[1] = dens*u_x*u_x + pressure;
    F[2] = dens*u_x*u_y;
    F[3] = u_x*(0.5*dens*(u_x*u_x + u_y*u_y) + k*pressure/(k-1));
    return F;
  }

  ////////////////////////////////////
  //  Rotate
  template<typename Vec_in>
  static Vector_type rotate(const Vec_in& U, Node2D n_hat) {
    Vector_type U_rot = U;
    U_rot[1] =  U[1]*n_hat.x() + U[2]*n_hat.y();
    U_rot[2] = -U[1]*n_hat.y() + U[2]*n_hat.x();
    return U_rot;
  }

  ////////////////////////////////////
  //  reflect_x
  template<typename Vec_in>
  static Vector_type reflect_x(const Vec_in& U) {
    Vector_type U_ref = U;
    U_ref[1] *= -1.0;
    return U_ref;
  }

  ////////////////////////////////////
  //  max_lambda_x
  template<typename Vec_in>
  static double max_lambda_x(const Vec_in& U) {
    return fabs(U[1]/U[0]) + sqrt(k*p(U)/U[0]);
  }

private:
  static constexpr double k = 1.4;
};
