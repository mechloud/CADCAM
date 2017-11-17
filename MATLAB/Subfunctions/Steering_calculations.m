clc;
clear

%% steering calculations
%

%% 
% Global variables

Lkp=4.5*0.0254; %meters  length from middle of tire to pivot point
WB=64*0.0254; %meters   wheelbase 
track=55*0.0254; %meters  track
maxturn=45;  %maximum tire turn in deg 
Lknuckle=3*0.0254; %length of arm on knuckle to attach tie rod
Ltierod=14.92*0.0254; % length of tie rod in meters
Lfromfront=2*0.0254;  %length from front of roll cage to rack and pinion in meters 
steeringratio=4;  % 4-deg input for 1-deg output
Sy=276*10^6; %Sy of aluminum 6061 in Pa 
E=68.9*10^9; %E of aluminum 6061 in Pa

%% 
% ackerman angle
ackangle=atand((((track/2)-Lkp)/WB))

%% 
% minimum turning radius
R=(WB/tand(maxturn))+(track/2) %minimum turning radius from center of vehicle

%% 
% outer tire turn angle 
do=atand(WB/(R+(track/2))) %outer tire turning angle

%% 
% needed motion from rack 
La=(Lknuckle*cosd(ackangle-90))+sqrt(Ltierod^2-(Lfromfront+(Lknuckle*(cosd(ackangle-90))))^2)
% distance between rack and pivot point @ ackangle
Lm=(Lknuckle*cosd(ackangle-45))+sqrt(Ltierod^2-(Lfromfront+(Lknuckle*(cosd(ackangle-45))))^2)
% distance between rack and pivot point @ max turn angle (45deg)
Lneeded=Lm-La
%difference between those lengths is the movement required by the rack

%% 
% required pinion size for desired steering ratio
Pr=(Lneeded*steeringratio)/(2*pi) %pinion radius
%

%%
% bending in initially curved beams 
h=1.5*0.0254; %height of cross section on the arm connecting to the tie rod
b=1*0.0254;     %width of base of the cross section 
ro=0.0508;  %outer radius of initially curved beam
ri=0.0254;  %inner radius of initially curved beam 
Fknuckle=174;  %force acting on arm ((will alter later))
rn=h/(log(ro/ri)); %radius of the neutral axis
rc=ri+(h/2); %radius of the centroidal axis
Ci=rn-ri;  %distance from neutral axis to inner fiber
Co=ro-rn;  %distance from neutral axis to outer fiber
e=rc-rn;  %distance from centroidal axis to neutral axis
A=b*h; %area of cross section 

sigmai=Fknuckle*Ci/(A*e*ri) % inner fiber stress
sigmao=-Fknuckle*Co/(A*e*ri) %outer fiber stress

ni=sigmai/Sy %safety factor of inner fiber 
no=sigmao/Sy %safety factor of outer fiber

%% 
%buckling stress tie rod
Ftie=174 % force compressing tie rod ((to be changed))
OD=19.05*0.0254 % outer diameter of tie rod 
ID=16.1*0.0254 %inner diameter of tie rod
A=((pi*OD^2)/4)-((pi*ID^2)/4) %cross sectional area
I=pi/64*(OD^4-ID^4) %momment of inertia 
Lc=Ltierod %corrected buckling tie rod length (tie rod length)
ratio=pi^2*E*I/(A*Lc^2) %comparisson to be compared with Sy/2

if (Sy/2>=ratio)
    Scr=(pi^2*E*I)/(A*Lc^2)
else  %depending on if its larger or smaller than the ratio Scr will change
    Scr=Sy*(1-((Sy*A*Lc^2)/(4*pi^2*E*I)))
end

sigmab=Ftie/A %buckling stress on the tie rod 
ntie=sigmab/Sy %buckling safety factor of the tie rod 
% ((need to calculate the tension in the tie rod))
%% 
% torsion on steering column part#1
torin=677.74; %torque in steering column ((need to change this))
OD=25.4/1000; %m outer diameter of rod
S=6.35/1000; %m size of slot in rod
R=OD/2;  %radius of rod 
J=((pi*OD^4)/32)-(2*(S^4/6)); %polar moment of inertia of rod 
tau=((torin*R)/J) %torsional stress on rod 
n=((Sy*.58)/tau) %torsional stress safety factor of rod

%%
% torsion on steering column part#2
torin=677.74; %torque in steering column ((need to be changed))
OD=28.58/1000  %m Outer diameter of steering column sleev%torque in steering column ((need to be changed))e 
ID=25.63/1000 %m Inner diamter of steering column sleeve
R=OD/2; %radius of steering column sleeve
J=((pi*OD^4)/32)-((pi*ID^4)/32); %polar moment of inertia on steering column sleeve
tau=((torin*R)/J) % torsional stress on steering column upper sleeve
n=((Sy*.58)/tau) %torsional stress safety factor of rod  
%%
% torsion on steering column part#3
torin=677.74;  %torque in steering column ((need to be changed))
b=1.48/1000; % bolt hole thickness 
d=12/1000;  %bolt hole diameter
OD=(15.88*2)/1000;  %m outer diameter of bigger sleeve
ID=(14.40*2)/1000; %m inner diameter of bigger sleeve
R=OD/2; % radius of bigger sleeve
J=((pi*OD^4)/32)-((pi*ID^4)/32)-(((b*d)*(b^2+d^2))/12); %polar momment of inertia of bigger sleeve 
tau=((torin*R)/J) %torsional stress on bigger sleeve
n=((Sy*.58)/tau) %torsional stress on bigger sleeve safety factor 
%%
% shear on steering pins
torin=677.74; %torque in steering column ((need to be changed))
syb=240*10^6; %Sy of the bolt
OD=(15.88*2)/1000;  %m outer diameter of bolt 
R=OD/2;  %of outer tube sleeve
r=6.35/1000; %m radius of slot 
A=pi*r^2; % area of cross section of the bolt
tau=((torin/R)/A) %shear stress on the bolt
n=((syb*.58)/tau) %coresponding safety factor of the bolt

%%
%gear wear calculations
PDi=0.875; % pitch diameter of the gear in inch
PDm=0.875*0.0254; % pitch diamter of the gear in m
Bore=0.375*0.0254; %bore of the gear
DP=16; %diametral pitch of the gear 
%Module = something (metric)
Facei=0.75; %face width of gear in inch
Facem=0.75*0.0254; %face width of gear in m
OD=(PDi+0.125); %outer diameter of gear
Pa=20; %pressure angle in deg

Mn=1; % constant for spur gears
V=2;  %m/s max velocity of gear 
Qv=7; %type of gearing constant 
Wt=320; %force transfered through the gear in newtons i guess
Cp=191;
%Cp=sqrt((1/(pi*(2*(1-.3^2)/(200*10^9)))))


I=((cosd(Pa)*sind(Pa))/(2*Mn)); %contact ratio 

B=0.25*((12-Qv)^(2/3));
A=50+(56*(1-B));
Kv=((A+sqrt(200*V))/A)^B; %metric constant

Cpf=(Facei/(10*PDi))-0.025;
Cmc=1; %uncrowned teeth
Cpm=1; %constant
A=0.127;
B=0.0158;   %values found froom a table for comercial enclosed units
C=-0.93*10^(-4);
Cma=A+B*Facei+(C*Facei^2);
Ce=1; %constant
Km=1+(Cmc*((Cpf*Cpm)+(Cma*Ce)));

Ko=1.5;
Ks=1;
Cf=1;

sigmaw=Cp*(sqrt(Wt*Ko*Kv*Ks*(Km/((PDi*25.4)*(Facei*25.4)))*(Cf/I)))

Zn=1.5;
Sc=1896;
Kt=1;
Kr=1.5;
Ch=1;

Sh=((Sc*Zn*Ch)/(Kt*Kr))/sigmaw

%%
% bending stress in gear
J=0.22;
Kb=1;
Wt=7.106;
simgmab=Wt*Ko*Kv*Ks*(PDi/Facei)*(((Km*Kb)/J));
St=482.63*10^6;
Yn=2.5;
Sf=(St*Yn/1*1.5)/sigmab
