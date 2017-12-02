%% Suspension
% Suspension determines all the characteristics of the front and rear
% suspension
function [bdia,k2] = Suspension(tag,log_id,location,freq,zeta,md)
%% Constant Variables
% Mass Single Wheel [kg]
mw=14;

%%
% Mass of  the Vehicle Inlcuding the Drivetrain [kg]
mv=215;

%%
% Tire Spring Rate [N/m]
k1=200000;
%%
% If the number of input arguments is less than three, declare defaults.
if nargin < 6
    clc
    close all
    tag = 'gui';
    log_id = 0;
    zeta = 0.3;     
    freq = 1.5; %Hz
    md = 110; %kg
    location = 'f';
end

if location == 'f'
    dist = 0.4;
    string = 'front';
else 
    dist = 0.6;
    string = 'rear';
end

%% Variable Calculation
% Natural Frequency [rad/s]
omega_n=freq*2*pi;

%%
% Mass on single corner including Wheel
m1 = ((0.15*mv)/4) + mw;

%%
% Mass of car without Wheels and Suspension
m2 = mv - (m1*4);

%%
% Total Sprung Mass Acting on Quarter Car Model [kg]
mc=(m2+md)*dist/2;

%%
% Front Shock Spring Rate [N/m]
k2=(omega_n^2)*mc;

if ~strcmp(tag,'gui') && log_id ~= 0
    fprintf(log_id,'The desired %s spring rate is %.2f N/m.\n', string, k2);
else
    fprintf('The desired %s spring rate is %.2f N/m.\n', string, k2);
end
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
tic;
syms s;
eqn = det(M*s^2+K) == 0;
omega_nm = solve(eqn,s);
omega_nf = abs(imag(omega_nm));
omega_nf = double(omega_nf);

if ~strcmp(tag,'gui') && log_id ~= 0
    fprintf(log_id,['The obtained %s system natural frequency',...
                    ' is %.2f and %.2f rad/s.\n'], string, max(omega_nf), min(omega_nf));
else
    fprintf('The obtained %s system natural frequency is %.2f and %.2f rad/s.\n', string, max(omega_nf), min(omega_nf));
end
x = 0:0.01:120;
y2 = k1*sqrt(c2.^2*x.^2+k2.^2)./(sqrt((m1*mc*x.^4-k1*mc*x.^2-k2*m1*x.^2-k2*mc*x.^2+k1*k2).^2+(-c2*m1*x.^3-c2*mc*x.^3+c2*k1*x).^2));

%%
% Plot Frequency Response
% figure(1)
% plot(x,y2,'Red');
% xlabel('Frequency omega [rad/s]')
% ylabel('Magnitude of Y2/Y0')

%% Systems approach
% Declare State-Space Matrices
A=[-c2/mc c2/mc -k2/mc k2/mc;
    c2/m1 -c2/m1 k2/m1 -(k2+k1)/m1
    1 0 0 0;
    0 1 0 0];                           %state matrix
B=[0; k1/m1; 0; 0];                     %force matrix
CC=[0 0 1 0];        %sprung, unsprung, relative
D=0;

%%
% Declare as system
sys=ss(A,B,CC,D);       %state-space representation
%%
% Calculate Step and Impulse Response
opt = stepDataOptions('StepAmplitude',0.15);
[uy,t] = step(sys,opt);
%[iy,u] = impulse(sys);

%%
% Plot Step Response
% figure(2)
plot(t,uy);
title('Step Response');
legend('Chassis');
S = stepinfo(sys);
ST = S.SettlingTime;

if ~strcmp(tag,'gui') && log_id ~= 0
    if ~isnan(ST)
        fprintf(log_id,'The %s settling time is %.2f s.\n', string, ST);
    else
        fprintf(log_id,'The %s does not settle.\n',string);
    end
else
    if ~isnan(ST)
        fprintf('The %s settling time is %.2f s.\n', string, ST);
    else
        fprintf('The %s does not settle.\n',string);
    end
end

%%
% Plot Impulse Response
%figure(3)
% plot(u,0.15*iy);
% title('Impulse Response');
% legend('Chassis');

%% Post-Processing
% Differentiate twice to find acceleration
% acc_imp = diff(diff(iy(:,1)));
% acc_step = diff(diff(uy(:,1)));
% 
% max_accel = max(max(acc_imp),max(acc_step));
% fprintf('Maximum acceleration is %.1f m/s^2.\n', max_accel);

%% Bolt Size
% Checking to see if bolt size is correct
F=k2*0.152; %Spring rate times maximum spring compression of 152 mm (6in)
n=2.0;
b = struct(   'F',F,...    % Shearing Force in N
              't',6.08,...    % Thickness of clamped parts
              'mxA',237.12,...   % Cross sectional area of weakeast connected member
              'SyM',250);     % Yield Strength of weakest clamped part);
bdia = tools.BoltTool(b,n);
if ~strcmp(tag,'gui') && log_id ~= 0
    fprintf(log_id,'Minimum Required %s Suspension Mounting Bolt Diameter = %.1f mm\n',string,bdia);
end
end