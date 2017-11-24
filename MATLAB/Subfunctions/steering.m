%% steering
% STEERING Calculations

function steering(FW,TW,WB,SR,FL,Weight,CG)%add weight and center of mass 
clc;
clear

if nargin < 7
    warning(['Number of arguments input to function not sufficient,',...
             ' using default values']);
    FW = 36*0.0254;
    TW = 55*0.0254;
    WB = 64*0.0254;
    SR = 4;
    FL = WB + 8*0.0254;
    Weight = 305; %kg
    CG=0.4;
end

addpath('../Database');

%% Declare global variables
% Length of steering arm [m]
Lknuckle = 3*0.0254;

%%
% Length from front of roll cage to rack and pinion [m]
Lfromfront=2*0.0254;

%%
% Length from center of tire to kingpin pivot point [m]
Lkp = 4.5*0.0254; %m

%%
% Material Properties
Sy = 276*10^6; %Sy of aluminum 6061 in Pa 
E  = 68.9*10^9; %E of aluminum 6061 in Pa
syb = 240*10^6; %sy of bolt in Pa

[ltr,ackangle,Pr,stclength,racklength,rackboxlength] = steering_geometry(TW,Lkp,WB,SR,FW,Lfromfront,...
                                      Lknuckle);
[Ft,Fr,torin,torr] = steering_forces(Weight,CG,Pr,Lkp,Lknuckle);

h = steering_knuckle(Fr,Ft,Sy) 
%sends back new value of cross section height for steering arm

%%
% Calculates forces on ties rods. Returns safety factors, OD and ID of
% tie-rod tubes.
%[nt,nr,OD,ID] = Tie_Rod (Fr,Ft,Sy,ltr);

%%
% Calculates the shear on the bolts in the steering column and returns
% safety factors and slot size
%[slotsize,~,~] = column_bolt_shear(torin,torr,Sy);
    
%%
% Calculates the torsional stress on the inner rod in the steering column
% and returns ID and safety factors
%[ir_d,~,~] = column_inner(torin,torr,Sy,slotsize);
% ir_d = inner rod outside diameter

%%
% Calculates the torsional stress on the outer tube in the steering column
% and returns OD, ID and safety factors
%[ot_OD,ot_ID,~,~] = column_outer(torin,torr,Sy,ir_d);

%%
% Calculates the torsional stress on the outer tube sleeve in the steering 
% column and returns OD, ID and safety factors
%[os_OD,os_ID,nt,nr] = column_sleeve(torin,torr,Sy,ot_OD);

%%
% calculates the bending and wear stress on the gear and returns the safe
% gear size 
%[N,PD,bore,F]= gear_loop(Pr,torin,torr);
end

function [Ltierod,...
          ackangle,...
          Pr,stclength,...
          racklength,...
          rackboxlength] = steering_geometry(track,Lkp,WB,...
                                                   steeringratio,...
                                                   framewidth,...
                                                   lff,... % length from front
                                                   Lknuckle,...
                                                   firewalllength)

                                               
% TEMPORARY VARIABLE
firewalllength = 1.500;
%%
% Rack Offset [m]
roffset= 2*0.0254;

% Maximum tire turning angle [deg]
maxturn = 45;
%%
% Ackerman angle
ackangle = atand((((track/2)-Lkp)/WB));
% ** OUTPUT TO SOLIDWORKS **

%% 
% minimum turning radius
R = (WB/tand(maxturn))+(track/2); %minimum turning radius from center of vehicle

% %% 
% % outer tire turn angle 
% delta_o = atand(WB/(R+(track/2))) %outer tire turning angle

%%
% Length of the tie rod
Ltierod = sqrt((track/2-framewidth/2-Lkp-3*sind(ackangle))^2 ...
          +(abs(lff-roffset)^2));
%   ** output length of tie rod to solidworks **

%% Motion needed from Rack
% Distance between rack and pivot point @ ackangle
La = (Lknuckle*cosd(ackangle-90))+sqrt(Ltierod^2-(abs(lff-roffset)...
    +(Lknuckle*(cosd(ackangle-90))))^2);

%%
% Distance between rack and pivot point @ max turn angle (45deg)
Lm = (Lknuckle*cosd(ackangle-45))+sqrt(Ltierod^2-(abs(lff-roffset)...
    +(Lknuckle*(cosd(ackangle-45))))^2);

%%
% Difference between those lengths is the movement required by the rack
Lneeded = Lm - La;

%% Pinion Radius
% Calculated pinion radius required for desired steering ratio
Pr = (Lneeded/((maxturn*steeringratio)/360)*(2*pi)); 
%   ** output pinion radius to solidworks

%%
% Print to log file 
fprintf('The minimum turning radius of the vehicle is %.1f [m]\n',R);

%%
%length of steering column
stclength = sqrt((firewalllength-(36*0.0254))^2+((48*0.0254)^2));

%%
% rack length 
racklength = framewidth + 2*0.0254;
rackboxlength = framewidth;

end
% **need to find max and min gear radius to create and use database** %
% *** also need to fix the values i use here *** %

function [N,PD,bore,F] = gear_loop(Pr,torin,torr)

gears = xlsread('gears.xlsx');

desired_PD = Pr * 2/0.0254;
N = gears(:,1);
PD = gears(:,2);
Bore = gears(:,3);
%F = gears(:,4);
OD = gears(:,5);

small_G = PD(PD < desired_PD);
big_G = PD(PD > desired_PD);

L = length(small_G);
L2 = length(big_G);

if abs(small_G(end)-desired_PD) < abs(big_G(1)-desired_PD)
  PD = small_G(end);
  Bore = gears(L,3);
  N = gears(L,1);

elseif abs(small_G(end)-desired_PD) > abs(big_G(1)-desired_PD)

  PD = big_G(1);
  Bore = gears(L+1,3);
  N = gears(L+1,1);

elseif any(desired_PD == PD)
  PD = desired_PD;
end

%%
% temporary variables
F = 0.75;
Pa=20; %pressure angle in deg
DP=16; %diametral pitch of the gear 
wt = torr*0.224809; % force transfered through the gear in foot pounds

ctr=1;

[sf,sh] = gear_calculations(wt,DP,N,PD,F,Pa);
while Sh < 2 && sf < 2
    if abs(small_G(end)-desired_PD) < abs(big_G(1)-desired_PD)
        PD = big_G(ctr);
        Bore = gears(L+1,3);
        N = gears(L+1,1);
    elseif abs(small_G(end)-desired_PD) > abs(big_G(1)-desired_PD)
        PD = big_G(1+ctr);
        Bore = gears(L+1+ctr,3);
        N = gears(L+1+ctr,1);
    elseif any(desired_PD == PD)
        PD = big_G(ctr);
    end
    [sf,sh] = gear_calculations(wt,DP,N,PD,F,Pa);
    ctr = ctr+1;
end
end

function [sf,sh] = gear_calculations(wt,DP,N,PD,F,Pa)

Mn = 1;   % constant for spur gears
V  = 2*196.85;   % m/s max velocity of gear 
Qv = 7;   % type of gearing constant 
Cp = 2300;
I=((cosd(Pa)*sind(Pa))/(2*Mn)); %contact ratio 

B1=0.25*((12-Qv)^(2/3));
A1=50+(56*(1-B1));
Kv=((A1+sqrt(V))/A1)^B1; %metric constant

Cpf=(F/(10*PD))-0.025;
Cmc=1; %uncrowned teeth
Cpm=1; %constant
A2=0.127;
B2=0.0158;   %values found froom a table for comercial enclosed units
C=-0.93e-4;
Cma=A2+B2*F+(C*F^2);
Ce=1; %constant
Km=1+(Cmc*((Cpf*Cpm)+(Cma*Ce)));

Ko=1.5;
Ks=1;
Cf=1;

sigmaw=Cp*(sqrt(wt*Ko*Kv*Ks*(Km/(PD*F))*(Cf/I)));

Zn=1.5;
Sc=225000;
Kt=1;
Kr=1.5;
Ch=1;

Sh=((Sc*Zn*Ch)/(Kt*Kr))/sigmaw;

%%
% bending stress in gear
J=0.22;
Kb=1;

sigmab = wt*Ko*Kv*Ks*(PD/F)*(((Km*Kb)/J));
St=65000;
Yn=2.5;
Sf=((St*Yn)/(1*1.5))/sigmab;

end


function [Ft,Fr,torin,torr] = steering_forces(Weight,CG,Pr,Lkp,Lknuckle)
%%
% determing the forces acting on the system
mu = 0.75; %friction coefficient between tire and track surface
G = 9.8; %garvity m/s^2
assumed_force = 750; %set impact force hitting the side of the tire 

%math

% ** outputed values **
Ft = ((Weight*CG*G*mu*Lkp)/Lknuckle);
Fr = (2225*(11*0.0254))/(Lkp); %2225 N is a set value that i chose 
torin = Ft*(Pr*0.0254);
torr = (Pr*0.0254)*Fr;

end




function h = steering_knuckle (Fr,Ft,Sy)

%%
% bending in initially curved beams 
h = 1.5*0.0254; %height of cross section on the arm connecting to the tie rod
b = 1*0.0254;     %width of base of the cross section 
ro = 0.0508;  %outer radius of initially curved beam
ri = 0.0254;  %inner radius of initially curved beam 
Ft = 174;  %force acting on arm ((will alter later))
Fr = 200;
rn = b/(log(ro/ri)); %radius of the neutral axis
rc = ri+(b/2); %radius of the centroidal axis
Ci = rn-ri;  %distance from neutral axis to inner fiber
Co = ro-rn;  %distance from neutral axis to outer fiber
e = rc-rn;  %distance from centroidal axis to neutral axis

A = b*h; %area of cross section 

sigmait = Ft*Ci/(A*e*ri); % inner fiber stress
sigmaot = -Ft*Co/(A*e*ro); %outer fiber stress

sigmair = Fr*Ci/(A*e*ri);
sigmaor = -Fr*Co/(A*e*ro);

nit = abs(Sy/sigmait); %safety factor of inner fiber 
not = abs(Sy/sigmaot); %safety factor of outer fiber

nir = abs(Sy/sigmair);
nor = abs(Sy/sigmaor);

while nir < 2 && nor < 2 && nit < 2 && not < 2 
    h=h+(0.125*0.0254);
    A=b*h;

    sigmaid = Ft*Ci/(A*e*ri); % inner fiber stress
    sigmaod = -Ft*Co/(A*e*ri); %outer fiber stress
    
    sigmair = Fr*Ci/(A*e*ri);
    sigmaor = -Fr*Co/(A*e*ri);
    
    nid = sigmaid/Sy; %safety factor of inner fiber 
    nod = sigmaod/Sy; %safety factor of outer fiber
    
    nir = sigmair/Sy;
    nor = sigmaor/Sy;
end
end




function [nt,nr,OD,ID] = Tie_Rod (Fr,Ft,Sy,Ltierod)
%% 
%buckling stress tie rod
tubes = load('tube_sizes.mat');
tube_sizes = tubes.tube_sizes;
ODs = tube_sizes(:,1)/1000;
IDs = ODs - 0.002*tube_sizes(:,2);

od = OD(1);
id = ID(1);
%OD = 19.05/1000; % outer diameter of tie rod 
%ID = 16.1/1000; %inner diameter of tie rod

A = ((pi*od^2)/4)-((pi*id^2)/4); %cross sectional area
I = pi/64*(od^4-id^4); %momment of inertia 
Lc = Ltierod; %corrected buckling tie rod length (tie rod length)
E = 68.9e9;
ratio = pi^2*E*I/(A*Lc^2); %comparisson to be compared with Sy/2


if (Sy/2 >= ratio)
    Scr = (pi^2*E*I)/(A*Lc^2);
else  %depending on if its larger or smaller than the ratio Scr will change
    Scr = Sy*(1-((Sy*A*Lc^2)/(4*pi^2*E*I)));
end

sigmat = Ft/A; %buckling stress on the tie rod 
sigmar = Fr/A;
nt = sigmat/Scr; %buckling safety factor of the tie rod 
nr = sigmar/Scr;

ctr = 1
while nt < 2 && nr < 2 && ctr < length(ID)
    
    od = OD(ctr+1);
    id = ID(ctr+1);
    
    A     = ((pi*od^2)/4)-((pi*id^2)/4); %cross sectional area
    I     = pi/64*(od^4-id^4); %momment of inertia 
    Lc    = Ltierod; %corrected buckling tie rod length (tie rod length)
    E     = 68.9e9;
    ratio = pi^2*E*I/(A*Lc^2); %comparisson to be compared with Sy/2


    if  (Sy/2 >= ratio)
        Scr = (pi^2*E*I)/(A*Lc^2);
    else  %depending on if its larger or smaller than the ratio Scr will change
        Scr = Sy*(1-((Sy*A*Lc^2)/(4*pi^2*E*I)));
    end

    sigmat = Ft/A; %buckling stress on the tie rod 
    sigmar = Fr/A;
    nt = sigmat/Scr; %buckling safety factor of the tie rod 
    nr = sigmar/Scr;
    
    ctr = ctr + 1;
end

end

    


function [OD,nin,nr] = column_inner(torin,torr,Sy,slotsize)
%% 
% torsion on steering column part#1
OD = 25.4/1000; %m outer diameter of rod
R = OD/2;  %radius of rod 
J = ((pi*OD^4)/32)-(2*(slotsize^4/6)); %polar moment of inertia of rod 
tauin = ((torin*R)/J); %torsional stress on rod 
nin = ((Sy*.58)/tauin); %torsional stress safety factor of rod
taur = ((torr*R)/J); %torsional stress on rod 
nr = ((Sy*.58)/taur); %torsional stress safety factor of rod

while nin < 2 && nr < 2
    
    OD = OD + 0.001;
    R = OD/2;  %radius of rod 
    J = ((pi*OD^4)/32)-(2*(slotsize^4/6)); %polar moment of inertia of rod 
    tauin = ((torin*R)/J); %torsional stress on rod 
    nin = ((Sy*.58)/tauin); %torsional stress safety factor of rod
    taur = ((torr*R)/J); %torsional stress on rod 
    nr = ((Sy*.58)/taur); %torsional stress safety factor of rod
end

end


function [od,id,nin,nr] = column_outer(torin,torr,Sy,rod_dia)

%%
% torsion on steering column part#2
tubes = load('tube_sizes.mat');
tube_sizes = tubes.tube_sizes;
ODs = tube_sizes(:,1)/1000;
IDs = ODs - 0.002*tube_sizes(:,2);

ID = IDs(IDs > rod_dia);
OD = ODs(IDs > rod_dia);

od = OD(1);
id = ID(1);

R = OD(1)/2; %radius of steering column sleeve
J = ((pi*OD(1)^4)/32)-((pi*ID(1)^4)/32); %polar moment of inertia on steering column sleeve
taur = ((torin*R)/J); % torsional stress on steering column upper sleeve
nr = ((Sy*.58)/taur); %torsional stress safety factor of rod  
tauin = ((torin*R)/J); % torsional stress on steering column upper sleeve
nin = ((Sy*.58)/tauin); %torsional stress safety factor of rod  

ctr = 1;

while nr < 2 && nin < 2 && ctr < length(ID)
    od = OD(ctr + 1);
    id = ID(ctr + 1);
    R = od/2;
    J = ((pi*od^4)/32)-((pi*id^4)/32);
    taur = ((torin*R)/J);
    nr = ((Sy*.58)/taur);
    tauin = ((torr*R)/J);
    nin = ((Sy*.58)/tauin);
    
    ctr = ctr + 1;
end % end while


end 



function [OD,ID,nin,nr] = column_sleeve(torin,torr,Sy,ot_od)
%%
% torsion on steering column part#3
tubes = load('tube_sizes.mat');
tube_sizes = tubes.tube_sizes;
ODs = tube_sizes(:,1)/1000;
IDs = ODs - 0.002*tube_sizes(:,2);

ID = IDs(IDs > ot_od);
OD = ODs(IDs > ot_od);

b  = 1.48/1000; % bolt hole thickness 
d  = 12/1000;  %bolt hole diameter
R  = OD(1)/2; % radius of bigger sleeve
J  = ((pi*OD(1)^4)/32)-((pi*ID(1)^4)/32)-(((b*d)*(b^2+d^2))/12); %polar momment of inertia of bigger sleeve 

tauin = ((torin*R)/J); %torsional stress on bigger sleeve
nin   = ((Sy*.58)/tauin); %torsional stress on bigger sleeve safety factor 
taur  = ((torr*R)/J); %torsional stress on bigger sleeve
nr    = ((Sy*.58)/taur); %torsional stress on bigger sleeve safety factor 

ctr = 1;
while nin < 2 && nr < 2 && ctr < length(ID)
    od = OD(ctr + 1);
    id = ID(ctr + 1);
    R = OD/2;
    J = ((pi*od^4)/32)-((pi*id^4)/32);
    tauin = ((torin*R)/J);
    nin = ((Sy*.58)/tauin);
    taur = ((torr*R)/J);
    nr = ((Sy*.58)/taur);
    
    ctr = ctr +1;
end    
 
end


function [r,nin,nr] = column_bolt_shear(torin,torr,syb)
%%
% shear on steering pins
OD=10/1000;  %m outer diameter of bolt 
R=OD/2;  %of outer tube sleeve
r=6.35/1000; %m radius of slot 
A=pi*r^2; % area of cross section of the bolt
tauin=((torin/R)/A); %shear stress on the bolt
nin=((syb*.58)/tauin); %coresponding safety factor of the bolt
taur=((torr/R)/A); %shear stress on the bolt
nr=((syb*.58)/taur); %coresponding safety factor of the bolt

while nin < 2 && nr < 2
    %increase slot size
    r = r + 0.001; %m radius of slot 
    A = pi * r^2; % area of cross section of the bolt
    
    tauin = ((torin/R)/A); %shear stress on the bolt
    nin   = ((syb*.58)/tauin); %coresponding safety factor of the bolt
    taur  = ((torr/R)/A); %shear stress on the bolt
    nr    = ((syb*.58)/taur); %coresponding safety factor of the bolt
end

end
