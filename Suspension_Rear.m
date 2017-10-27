close all;
clear all;

%PARAMETRIZED VARIABLES%
freq = 1.7; %desired natural frequency [Hz]
zeta=0.3;   %desired damping ratio
y0=0.2;    %height of bump [m]

%CONSTANT VARIABLES%
m1=21;      %mass single wheel and suspension assembly [kg]
m2=111;     %mass of rest of vehicle including drivetrain [kg]
md=110;     %mass of driver [kg]
k1=200000;  %tire spring rate [N/m]
dist=0.6;   %rear weight distribution = 40%

%VARAIBLE CALCULATION%
omega_n=freq*2*pi;          %natural frequency [rad/s]
mc=(m2+md)*dist/2;          %total sprung mass acting on quarter car model [kg]
k2=(omega_n^2)*mc           %rear shock spring rate [N/m]
c2 = 2*zeta*sqrt(k2*mc);    %rear damping coefficient [Ns/m]

M=[mc 0; 0 m1];             %rear mass matrix
C=[c2 -c2; -c2 c2];         %rear damping matrix
K=[k2 -k2;-k2 k2+k1];       %rear spring matrix

syms s
eqn = det(M*s^2+K) == 0;
omega_nr = solve(eqn,s)

x = 0:0.01:120;
y2 = k1*sqrt(c2.^2*x.^2+k2.^2)./(sqrt((m1*mc*x.^4-k1*mc*x.^2-k2*m1*x.^2-k2*mc*x.^2+k1*k2).^2+(-c2*m1*x.^3-c2*mc*x.^3+c2*k1*x).^2));
figure(1)
plot(x,y2,'Red');
xlabel('Frequency omega [rad/s]')
ylabel('Magnitude of Y2/Y0')

A=[-c2/mc c2/mc -k2/mc k2/mc;
    c2/m1 -c2/m1 k2/m1 -(k2+k1)/m1
    1 0 0 0;
    0 1 0 0]                            %state matrix
B=[0; k1/m1; 0; 0];                     %force matrix
CC=[0 0 1 0; 0 0 0 1; 0 0 1 -1];
D=0;

sys=ss(A,B,CC,D);
[uy,t]=step(sys);
[iy,u]=impulse(sys);

figure(2)
plot(t,uy);

figure(3)
plot(u,iy);