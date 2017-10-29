close all;
clear all;
clc;

%PARAMETRIZED VARIABLES%
freq = 1.5; %desired natural frequency [Hz]
zeta=0.3;   %desired damping ratio
y0=0.15;    %height of bump [m]

%CONSTANT VARIABLES%
m1=21;      %mass single wheel and suspension assembly [kg]
m2=111;     %mass of rest of vehicle including drivetrain [kg]
md=110;     %mass of driver [kg]
k1=200000;  %tire spring rate [N/m]
dist=0.4;   %front weight distribution = 40%

%VARAIBLE CALCULATION%
omega_n=freq*2*pi;          %natural frequency [rad/s]
mc=(m2+md)*dist/2;          %total sprung mass acting on quarter car model [kg]
k2=(omega_n^2)*mc           %front shock spring rate [N/m]
c2 = 2*zeta*sqrt(k2*mc);    %front damping coefficient [Ns/m]

M=[mc 0; 0 m1];             %front mass matrix
C=[c2 -c2; -c2 c2];         %front damping matrix
K=[k2 -k2;-k2 k2+k1];       %front spring matrix

syms s
eqn = det(M*s^2+K) == 0;
omega_nf = solve(eqn,s)

x = 0:0.01:120;
y2 = k1*sqrt(c2.^2*x.^2+k2.^2)./(sqrt((m1*mc*x.^4-k1*mc*x.^2-k2*m1*x.^2-k2*mc*x.^2+k1*k2).^2+(-c2*m1*x.^3-c2*mc*x.^3+c2*k1*x).^2));
figure(1)
plot(x,y2,'Red');
xlabel('Frequency omega [rad/s]')
ylabel('Magnitude of Y2/Y0')

A=[-c2/mc c2/mc -k2/mc k2/mc;
    c2/m1 -c2/m1 k2/m1 -(k2+k1)/m1
    1 0 0 0;
    0 1 0 0];                           %state matrix
B=[0; k1/m1; 0; 0];                     %force matrix
CC=[0 0 1 0; 0 0 0 1; 0 0 1 -1];        %sprung, unsprung, relative
D=0;

sys=ss(A,B,CC,D);       %state-space representation

opt = stepDataOptions('StepAmplitude',0.1);
[uy,t] = step(sys,opt);       %step response
[iy,u] = impulse(sys);    %impulse response

%%
% Plot Step Response
figure(2)
plot(t,uy);
title('Step Response');
legend('Sprung','Unsprung','Relative');

%%
%
figure(3)
plot(u,iy);
title('Impulse Response');
legend('Sprung','Unsprung','Relative');

%% Post-Processing
% Differentiate twice to find acceleration
acc_imp = diff(diff(iy(:,1)));
acc_imp_t = u(1:end-2);
acc_step = diff(diff(uy(:,1)));
acc_step_t = t(1:end-2);

% figure;
% plot(acc_imp_t, acc_imp);
% title('Impulse Acceleration');
% 
% figure;
% plot(acc_step_t,acc_step);
% title('Step Acceleration');

max_accel = max(max(acc_imp),max(acc_step));
fprintf('Maximum acceleration is %d m/s^2', max_accel);