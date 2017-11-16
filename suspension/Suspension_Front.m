%%% Front Suspension MATLAB code

close all;
clc;

%% Parametrized Variables
% Desired Natural Frequency [Hz]
freq = 1.5;

%%
% Desired Damping Ratio
zeta=0.3;

%%
% Height of Bump [m]
y0=0.15;

%% Constant Variables
% Mass Single Wheel and Suspension Assembly [kg]
m1=21;

%%
% Mass of the Rest of the Vehicle Inlcuding the Drivetrain [kg]
m2=111;

%%
% Mass of the Driver [kg]
md=110;

%%
% Tire Spring Rate [N/m]
k1=200000;

%%
% Front Weight Distribution (60\%)
dist=0.4;

%% Variable Calculation
% Natural Frequency [rad/s]
omega_n=freq*2*pi;

%%
% Total Sprung Mass Acting on Quarter Car Model [kg]
mc=(m2+md)*dist/2;

%%
% Front Shock Spring Rate [N/m]
k2=(omega_n^2)*mc

%%
% Front Damping Coefficient [Ns/m]
c2 = 2*zeta*sqrt(k2*mc);

%% Vibrational Analysis
% Front Mass Matrix
M=[mc 0; 0 m1];

%%
% Front Damping Matrix
C=[c2 -c2; -c2 c2];

%%
% Front Stiffness Matrix
K=[k2 -k2;-k2 k2+k1];

%%
% Solve System
syms s
eqn = det(M*s^2+K) == 0;
omega_nf = solve(eqn,s)

x = 0:0.01:120;
y2 = k1*sqrt(c2.^2*x.^2+k2.^2)./(sqrt((m1*mc*x.^4-k1*mc*x.^2-k2*m1*x.^2-k2*mc*x.^2+k1*k2).^2+(-c2*m1*x.^3-c2*mc*x.^3+c2*k1*x).^2));

%%
% Plot Frequency Response
figure(1)
plot(x,y2,'Red');
xlabel('Frequency omega [rad/s]')
ylabel('Magnitude of Y2/Y0')

%% Systems approach
% Declare State-Space Matrices
A=[-c2/mc c2/mc -k2/mc k2/mc;
    c2/m1 -c2/m1 k2/m1 -(k2+k1)/m1
    1 0 0 0;
    0 1 0 0];                           %state matrix
B=[0; k1/m1; 0; 0];                     %force matrix
CC=[0 0 1 0; 0 0 0 1; 0 0 1 -1];        %sprung, unsprung, relative
D=0;

%%
% Declare as system
sys=ss(A,B,CC,D);       %state-space representation

%%
% Calculate Step and Impulse Response
opt = stepDataOptions('StepAmplitude',0.1);
[uy,t] = step(sys,opt);
[iy,u] = impulse(sys);

%%
% Plot Step Response
figure(2)
plot(t,uy);
title('Step Response');
legend('Sprung','Unsprung','Relative');

%%
% Plot Impulse Response
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
